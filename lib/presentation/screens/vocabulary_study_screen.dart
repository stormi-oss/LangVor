import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database.dart';
import '../../domain/tts_service.dart';
import '../bloc/vocabulary/vocabulary_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/state_placeholders.dart';

enum StudyMode { flashcards, quiz, typing, listening }

/// Multi-mode study session over a folder's (or all) vocabulary cards.
class VocabularyStudyScreen extends StatefulWidget {
  final int? folderId;
  const VocabularyStudyScreen({super.key, this.folderId});

  @override
  State<VocabularyStudyScreen> createState() => _VocabularyStudyScreenState();
}

class _VocabularyStudyScreenState extends State<VocabularyStudyScreen> {
  StudyMode? _mode;
  late List<VocabularyCard> _pool;

  @override
  void initState() {
    super.initState();
    final all = context.read<VocabularyBloc>().state.allCards;
    _pool = widget.folderId == null
        ? all
        : all.where((c) => c.folderId == widget.folderId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mode == null ? 'Study' : _modeTitle(_mode!)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_mode != null) {
              setState(() => _mode = null);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: _mode == null ? _picker() : _session(),
    );
  }

  String _modeTitle(StudyMode m) => switch (m) {
        StudyMode.flashcards => 'Flashcards',
        StudyMode.quiz => 'Quiz',
        StudyMode.typing => 'Typing',
        StudyMode.listening => 'Listening',
      };

  Widget _picker() {
    if (_pool.isEmpty) {
      return const EmptyStateView(
        icon: Icons.school_outlined,
        title: 'Nothing to study yet',
        description: 'Add some words to this folder first.',
      );
    }
    final options = [
      (StudyMode.flashcards, Icons.style_rounded, 'Flashcards',
          'Flip cards and rate yourself'),
      (StudyMode.quiz, Icons.quiz_rounded, 'Quiz',
          'Pick the right translation'),
      (StudyMode.typing, Icons.keyboard_rounded, 'Typing',
          'Type the English word'),
      (StudyMode.listening, Icons.headphones_rounded, 'Listening',
          'Hear it, then type it'),
    ];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${_pool.length} words in this set',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: options.map((o) {
                  final disabled = o.$1 == StudyMode.quiz && _pool.length < 4;
                  return HoverCard(
                    onTap: disabled ? null : () => setState(() => _mode = o.$1),
                    child: Opacity(
                      opacity: disabled ? 0.4 : 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(o.$2, size: 32, color: AppColors.primary),
                          const SizedBox(height: AppSpacing.sm),
                          Text(o.$3,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            disabled ? 'Needs 4+ words' : o.$4,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _session() {
    switch (_mode!) {
      case StudyMode.flashcards:
        return _FlashcardsSession(cards: _pool, onRestart: _restart);
      case StudyMode.quiz:
        return _QuizSession(cards: _pool, onRestart: _restart);
      case StudyMode.typing:
        return _TypingSession(cards: _pool, listening: false, onRestart: _restart);
      case StudyMode.listening:
        return _TypingSession(cards: _pool, listening: true, onRestart: _restart);
    }
  }

  void _restart() => setState(() {});
}

// ─── Shared results screen ───────────────────────────────────────────────────

class _StudyResults extends StatelessWidget {
  final int correct;
  final int total;
  final VoidCallback onRestart;
  const _StudyResults({
    required this.correct,
    required this.total,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wrong = total - correct;
    final pct = total == 0 ? 0 : (correct / total * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 2,
                      centerSpaceRadius: 62,
                      sections: [
                        PieChartSectionData(
                          value: correct.toDouble(),
                          color: AppColors.success,
                          radius: 20,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: wrong.toDouble().clamp(0, double.infinity),
                          color: AppColors.error.withValues(alpha: 0.5),
                          radius: 20,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$pct%',
                          style: theme.textTheme.displayMedium
                              ?.copyWith(color: AppColors.primary)),
                      Text('score', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('$correct correct · $wrong to review',
                style: theme.textTheme.titleMedium),
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
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Study again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _progressBar(BuildContext context, int index, int total) {
  return Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: total == 0 ? 0 : index / total,
        minHeight: 6,
      ),
    ),
  );
}

// ─── Flashcards ──────────────────────────────────────────────────────────────

class _FlashcardsSession extends StatefulWidget {
  final List<VocabularyCard> cards;
  final VoidCallback onRestart;
  const _FlashcardsSession({required this.cards, required this.onRestart});

  @override
  State<_FlashcardsSession> createState() => _FlashcardsSessionState();
}

class _FlashcardsSessionState extends State<_FlashcardsSession> {
  late final List<VocabularyCard> _cards =
      List.of(widget.cards)..shuffle();
  int _index = 0;
  bool _flipped = false;
  int _correct = 0;

  @override
  Widget build(BuildContext context) {
    if (_index >= _cards.length) {
      return _StudyResults(
          correct: _correct,
          total: _cards.length,
          onRestart: widget.onRestart);
    }
    final card = _cards[_index];
    final theme = Theme.of(context);

    return Column(
      children: [
        _progressBar(context, _index, _cards.length),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: GestureDetector(
                onTap: () => setState(() => _flipped = !_flipped),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  children: [
                    SizedBox(
                      height: 160,
                      child: Center(
                        child: Text(
                          _flipped ? card.russianTranslation : card.englishWord,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: _flipped ? AppColors.primary : null,
                          ),
                        ),
                      ),
                    ),
                    Text(_flipped ? 'translation' : 'tap to flip',
                        style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _flipped
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _next(false),
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.error),
                      label: const Text("Didn't know"),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: () => _next(true),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Knew it'),
                    ),
                  ],
                )
              : Text('Tap the card to see the translation',
                  style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }

  void _next(bool knew) {
    setState(() {
      if (knew) _correct++;
      _index++;
      _flipped = false;
    });
  }
}

// ─── Quiz (multiple choice) ──────────────────────────────────────────────────

class _QuizSession extends StatefulWidget {
  final List<VocabularyCard> cards;
  final VoidCallback onRestart;
  const _QuizSession({required this.cards, required this.onRestart});

  @override
  State<_QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends State<_QuizSession> {
  final _rng = Random();
  late final List<VocabularyCard> _cards = List.of(widget.cards)..shuffle();
  int _index = 0;
  int _correct = 0;
  int? _picked;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _buildOptions();
  }

  void _buildOptions() {
    final correct = _cards[_index].englishWord;
    final distractors = (List.of(widget.cards)..shuffle())
        .map((c) => c.englishWord)
        .where((w) => w != correct)
        .take(3)
        .toList();
    _options = [correct, ...distractors]..shuffle(_rng);
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= _cards.length) {
      return _StudyResults(
          correct: _correct,
          total: _cards.length,
          onRestart: widget.onRestart);
    }
    final theme = Theme.of(context);
    final card = _cards[_index];

    return Column(
      children: [
        _progressBar(context, _index, _cards.length),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Text('What is the English for',
                        style: theme.textTheme.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(card.russianTranslation,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium
                            ?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: AppSpacing.xl),
                    ..._options.map((opt) {
                      final isCorrect = opt == card.englishWord;
                      final picked = _picked != null;
                      Color? bg;
                      if (picked && isCorrect) {
                        bg = AppColors.success.withValues(alpha: 0.2);
                      } else if (picked &&
                          _options.indexOf(opt) == _picked &&
                          !isCorrect) {
                        bg = AppColors.error.withValues(alpha: 0.2);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: picked
                                ? null
                                : () => _pick(_options.indexOf(opt), isCorrect),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: bg,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.centerLeft,
                            ),
                            child: Text(opt,
                                style: theme.textTheme.titleMedium),
                          ),
                        ),
                      );
                    }),
                    if (_picked != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: _next,
                        child: Text(_index == _cards.length - 1
                            ? 'See results'
                            : 'Next'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _pick(int i, bool correct) {
    setState(() {
      _picked = i;
      if (correct) _correct++;
    });
  }

  void _next() {
    setState(() {
      _index++;
      _picked = null;
      if (_index < _cards.length) _buildOptions();
    });
  }
}

// ─── Typing / Listening ──────────────────────────────────────────────────────

class _TypingSession extends StatefulWidget {
  final List<VocabularyCard> cards;
  final bool listening;
  final VoidCallback onRestart;
  const _TypingSession({
    required this.cards,
    required this.listening,
    required this.onRestart,
  });

  @override
  State<_TypingSession> createState() => _TypingSessionState();
}

class _TypingSessionState extends State<_TypingSession> {
  late final List<VocabularyCard> _cards = List.of(widget.cards)..shuffle();
  final _controller = TextEditingController();
  final _focus = FocusNode();
  int _index = 0;
  int _correct = 0;
  bool? _lastCorrect;

  @override
  void initState() {
    super.initState();
    if (widget.listening) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _speak() => TtsService.instance.speak(_cards[_index].englishWord);

  bool _matches(String input, VocabularyCard card) {
    String norm(String s) =>
        s.toLowerCase().trim().replaceAll(RegExp(r'[^a-zа-яё ]'), '');
    final answer = norm(input);
    if (answer.isEmpty) return false;
    final candidates = <String>[
      norm(card.englishWord),
      ...card.englishWord.toLowerCase().split(RegExp(r'[,/]')).map(norm),
    ];
    return candidates.any((c) =>
        c.isNotEmpty && (c == answer || _levenshtein(c, answer) <= 1));
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [prev[j] + 1, curr[j - 1] + 1, prev[j - 1] + cost]
            .reduce(min);
      }
      final t = prev;
      prev = curr;
      curr = t;
    }
    return prev[b.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= _cards.length) {
      return _StudyResults(
          correct: _correct,
          total: _cards.length,
          onRestart: widget.onRestart);
    }
    final theme = Theme.of(context);
    final card = _cards[_index];

    return Column(
      children: [
        _progressBar(context, _index, _cards.length),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    if (widget.listening) ...[
                      IconButton.filled(
                        iconSize: 40,
                        onPressed: _speak,
                        icon: const Icon(Icons.volume_up_rounded),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Tap to hear it again',
                          style: theme.textTheme.labelSmall),
                    ] else ...[
                      Text('Type the English for',
                          style: theme.textTheme.labelMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(card.russianTranslation,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium
                              ?.copyWith(color: AppColors.primary)),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    TextField(
                      controller: _controller,
                      focusNode: _focus,
                      autofocus: true,
                      enabled: _lastCorrect == null,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                      decoration: const InputDecoration(
                        hintText: 'your answer',
                      ),
                      onSubmitted: (_) => _check(),
                      inputFormatters: const [],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_lastCorrect == null)
                      FilledButton(
                        onPressed: _check,
                        child: const Text('Check'),
                      )
                    else ...[
                      _feedback(theme, card),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: _next,
                        child: Text(_index == _cards.length - 1
                            ? 'See results'
                            : 'Next'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _feedback(ThemeData theme, VocabularyCard card) {
    final ok = _lastCorrect == true;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (ok ? AppColors.success : AppColors.error)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: ok ? AppColors.success : AppColors.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              ok ? 'Correct!' : 'Answer: ${card.englishWord}',
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }

  void _check() {
    final ok = _matches(_controller.text, _cards[_index]);
    setState(() {
      _lastCorrect = ok;
      if (ok) _correct++;
    });
  }

  void _next() {
    setState(() {
      _index++;
      _lastCorrect = null;
      _controller.clear();
    });
    if (_index < _cards.length && widget.listening) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
    }
    _focus.requestFocus();
  }
}
