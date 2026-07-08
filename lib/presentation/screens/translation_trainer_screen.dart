import 'dart:async';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/nlp/spell_checker.dart';
import '../../domain/nlp/tokenizer.dart';
import '../../domain/online/online_translation_checker.dart';
import '../../domain/trainer/trainer_stats.dart';
import '../../utils/text_splitter.dart';
import '../bloc/settings/settings_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/state_placeholders.dart';

enum TrainerDifficulty { easy, medium, hard }

extension on TrainerDifficulty {
  String get label => switch (this) {
        TrainerDifficulty.easy => 'Easy',
        TrainerDifficulty.medium => 'Medium',
        TrainerDifficulty.hard => 'Hard',
      };
  String get hint => switch (this) {
        TrainerDifficulty.easy => 'Key words highlighted, one sentence at a time',
        TrainerDifficulty.medium => 'One sentence at a time, no hints',
        TrainerDifficulty.hard => 'The whole text at once',
      };
}

/// Sentence-by-sentence translation trainer with difficulty modes, a timer,
/// live grading, badges, and a local leaderboard.
class TranslationTrainerScreen extends StatefulWidget {
  final String title;
  final String sourceText;
  const TranslationTrainerScreen({
    super.key,
    required this.title,
    required this.sourceText,
  });

  @override
  State<TranslationTrainerScreen> createState() =>
      _TranslationTrainerScreenState();
}

class _TranslationTrainerScreenState extends State<TranslationTrainerScreen> {
  final _checker = OnlineTranslationChecker();
  final _store = TrainerStore();
  final _controller = TextEditingController();
  final _focus = FocusNode();

  TrainerDifficulty? _difficulty;
  late List<String> _segments;
  int _index = 0;
  int _correct = 0;
  int _streak = 0;
  int _bestStreak = 0;
  final List<double> _scores = [];
  bool _checking = false;
  OnlineCheckResult? _lastResult;
  Stopwatch? _stopwatch;
  Timer? _ticker;
  final Set<String> _sessionBadges = {};

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    _focus.dispose();
    _checker.dispose();
    super.dispose();
  }

  void _start(TrainerDifficulty d) {
    final sentences = TextSplitter.splitIntoSentences(widget.sourceText);
    setState(() {
      _difficulty = d;
      _segments = d == TrainerDifficulty.hard
          ? [widget.sourceText.trim()]
          : sentences;
      _index = 0;
      _correct = 0;
      _streak = 0;
      _bestStreak = 0;
      _scores.clear();
      _lastResult = null;
      _controller.clear();
      _sessionBadges.clear();
    });
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer · ${widget.title}',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (_difficulty != null && _stopwatch != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: _TimerChip(seconds: _stopwatch!.elapsed.inSeconds),
              ),
            ),
        ],
      ),
      body: _difficulty == null
          ? _difficultyPicker()
          : (_index >= _segments.length ? _results() : _round()),
    );
  }

  // ── Difficulty picker ──

  Widget _difficultyPicker() {
    final sentenceCount =
        TextSplitter.splitIntoSentences(widget.sourceText).length;
    if (sentenceCount == 0) {
      return const EmptyStateView(
        icon: Icons.fitness_center_rounded,
        title: 'Nothing to practice',
        description: 'This text has no sentences to translate.',
      );
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose a difficulty',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text('$sentenceCount sentences to translate',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              ...TrainerDifficulty.values.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: HoverCard(
                      onTap: () => _start(d),
                      child: Row(
                        children: [
                          Icon(_difficultyIcon(d),
                              color: AppColors.primary, size: 28),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text(d.hint,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  IconData _difficultyIcon(TrainerDifficulty d) => switch (d) {
        TrainerDifficulty.easy => Icons.spa_rounded,
        TrainerDifficulty.medium => Icons.trending_up_rounded,
        TrainerDifficulty.hard => Icons.local_fire_department_rounded,
      };

  // ── Active round ──

  Widget _round() {
    final theme = Theme.of(context);
    final segment = _segments[_index];

    return Column(
      children: [
        LinearProgressIndicator(
          value: _index / _segments.length,
          minHeight: 4,
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Sentence ${_index + 1} of ${_segments.length}',
                            style: theme.textTheme.labelMedium),
                        const Spacer(),
                        if (_streak > 1)
                          Text('🔥 $_streak streak',
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Source (with key-word highlight on Easy)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: _difficulty == TrainerDifficulty.easy
                          ? _highlightedSource(segment, theme)
                          : Text(segment, style: theme.textTheme.headlineMedium),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _controller,
                      focusNode: _focus,
                      autofocus: true,
                      maxLines: _difficulty == TrainerDifficulty.hard ? 8 : 3,
                      minLines: _difficulty == TrainerDifficulty.hard ? 5 : 2,
                      enabled: _lastResult == null,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Type your English translation…',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_lastResult == null)
                      FilledButton.icon(
                        onPressed: _checking ? null : _check,
                        icon: _checking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.fact_check_rounded, size: 18),
                        label: Text(_checking ? 'Checking…' : 'Check'),
                      )
                    else
                      _roundFeedback(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _highlightedSource(String segment, ThemeData theme) {
    final tokens = Tokenizer.tokenize(segment);
    final keyWords = tokens
        .where((t) =>
            t.normalized.length > 3 &&
            !SpellChecker.stopWords.contains(t.normalized))
        .map((t) => t.raw)
        .toSet();
    final spans = <TextSpan>[];
    final parts = segment.split(RegExp(r'(\s+)'));
    for (final part in parts) {
      final clean = part.replaceAll(RegExp(r'[^а-яёa-z]', caseSensitive: false), '');
      final isKey = keyWords.contains(clean) ||
          keyWords.any((k) => k.toLowerCase() == clean.toLowerCase());
      spans.add(TextSpan(
        text: '$part ',
        style: isKey
            ? theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w700)
            : theme.textTheme.headlineMedium,
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }

  Widget _roundFeedback(ThemeData theme) {
    final r = _lastResult!;
    final grade = r.grade;
    final color = switch (grade) {
      TranslationGrade.exact => AppColors.success,
      TranslationGrade.good => AppColors.info,
      TranslationGrade.partial => AppColors.warning,
      TranslationGrade.poor => AppColors.error,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.grade_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Text(grade.label,
                    style: theme.textTheme.titleSmall?.copyWith(color: color)),
                const Spacer(),
                Text('${(r.similarity * 100).round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(color: color)),
              ]),
              if (!r.isAvailable) ...[
                const SizedBox(height: 6),
                Text('Offline — scored with local heuristics.',
                    style: theme.textTheme.labelSmall),
              ],
              ...r.feedback.map((f) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('• $f', style: theme.textTheme.bodyMedium),
                  )),
              if (r.referenceTranslation != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Reference', style: theme.textTheme.labelSmall),
                Text(r.referenceTranslation!,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: _next,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(_index == _segments.length - 1
              ? 'Finish'
              : 'Next sentence'),
        ),
      ],
    );
  }

  Future<void> _check() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _checking = true);
    final email =
        context.read<SettingsBloc>().state.contactEmail;
    final result = await _checker.check(
      sourceRussian: _segments[_index],
      userEnglish: _controller.text,
      contactEmail: email,
    );
    if (!mounted) return;
    final passed = result.similarity >= 0.7;
    setState(() {
      _checking = false;
      _lastResult = result;
      _scores.add(result.similarity);
      if (passed) {
        _correct++;
        _streak++;
        _bestStreak = _streak > _bestStreak ? _streak : _bestStreak;
      } else {
        _streak = 0;
      }
    });
  }

  void _next() {
    setState(() {
      _index++;
      _lastResult = null;
      _controller.clear();
    });
    if (_index >= _segments.length) {
      _finish();
    } else {
      _focus.requestFocus();
    }
  }

  // ── Results ──

  Future<void> _finish() async {
    _stopwatch?.stop();
    _ticker?.cancel();
    final duration = _stopwatch?.elapsed.inSeconds ?? 0;
    final accuracy =
        _scores.isEmpty ? 0.0 : _scores.reduce((a, b) => a + b) / _scores.length;

    // Award badges.
    final earned = <String>{};
    if (await _store.earnedBadges().then((b) => b.isEmpty)) {
      earned.add(Badges.first.id);
    }
    if (accuracy >= 0.95) earned.add(Badges.perfect.id);
    if (_bestStreak >= 5) earned.add(Badges.streak5.id);
    if (_segments.length >= 10) earned.add(Badges.marathon.id);
    if (_segments.isNotEmpty &&
        duration / _segments.length <= 12 &&
        accuracy >= 0.7) {
      earned.add(Badges.fast.id);
    }
    _sessionBadges.addAll(earned);
    await _store.awardBadges(earned);
    await _store.addResult(TrainerResult(
      title: widget.title,
      difficulty: _difficulty!.label,
      accuracy: accuracy,
      sentences: _segments.length,
      correctSentences: _correct,
      durationSeconds: duration,
      date: DateTime.now(),
    ));
    if (mounted) setState(() {});
  }

  Widget _results() {
    final theme = Theme.of(context);
    final accuracy =
        _scores.isEmpty ? 0.0 : _scores.reduce((a, b) => a + b) / _scores.length;
    final duration = _stopwatch?.elapsed.inSeconds ?? 0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(accuracy * 100).round()}%',
                  style: theme.textTheme.displayLarge
                      ?.copyWith(color: AppColors.primary)),
              Text('average accuracy', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                alignment: WrapAlignment.center,
                children: [
                  _StatTile(
                      label: 'Correct',
                      value: '$_correct/${_segments.length}'),
                  _StatTile(label: 'Best streak', value: '$_bestStreak'),
                  _StatTile(label: 'Time', value: _fmt(duration)),
                  _StatTile(
                      label: 'Difficulty', value: _difficulty!.label),
                ],
              ),
              if (_sessionBadges.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text('Badges earned', style: theme.textTheme.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  alignment: WrapAlignment.center,
                  children: _sessionBadges
                      .map(Badges.byId)
                      .whereType<Badge>()
                      .map((b) => _BadgeChip(badge: b))
                      .toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              _Leaderboard(store: _store),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Done'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => setState(() => _difficulty = null),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }
}

class _TimerChip extends StatelessWidget {
  final int seconds;
  const _TimerChip({required this.seconds});
  @override
  Widget build(BuildContext context) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.timer_outlined, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text('${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.primary)),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Text(value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: AppColors.primary)),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final Badge badge;
  const _BadgeChip({required this.badge});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(badge.emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(badge.label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  final TrainerStore store;
  const _Leaderboard({required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<TrainerResult>>(
      future: store.leaderboard(),
      builder: (context, snap) {
        final results = snap.data ?? const [];
        if (results.isEmpty) return const SizedBox.shrink();
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(children: [
              const Icon(Icons.leaderboard_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Your best runs', style: theme.textTheme.titleSmall),
            ]),
            const SizedBox(height: AppSpacing.sm),
            ...results.take(5).toList().asMap().entries.map((e) {
              final r = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                        width: 24,
                        child: Text('${e.key + 1}',
                            style: theme.textTheme.labelMedium)),
                    Expanded(
                      child: Text(r.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium),
                    ),
                    Text('${(r.accuracy * 100).round()}%',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: AppColors.success)),
                    const SizedBox(width: 12),
                    Text(r.difficulty, style: theme.textTheme.labelSmall),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
