import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/database.dart';
import '../../domain/srs_engine.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../bloc/vocabulary/vocabulary_bloc.dart';
import '../widgets/flip_flash_card.dart';
import '../widgets/state_placeholders.dart';

/// Vocabulary screen with card list, search, and SRS review mode.
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VocabularyBloc>().add(const LoadVocabulary());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabularyBloc, VocabularyState>(
      builder: (context, state) {
        if (state.status == VocabularyStatus.reviewing) {
          return _ReviewMode(state: state);
        }
        return _CardListMode(state: state);
      },
    );
  }
}

// ─── Card List Mode ─────────────────────────────────────────────────────────

class _CardListMode extends StatelessWidget {
  final VocabularyState state;
  const _CardListMode({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vocabulary', style: theme.textTheme.displayLarge)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Your personal flashcard deck with spaced repetition',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      _VocabStat(
                        icon: Icons.style_rounded,
                        value: '${state.totalCards}',
                        label: 'Total',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _VocabStat(
                        icon: Icons.schedule_rounded,
                        value: '${state.dueCards}',
                        label: 'Due',
                        color: state.dueCards > 0
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Review button
                  if (state.dueCards > 0)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context
                            .read<VocabularyBloc>()
                            .add(const StartReview()),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                            'Review ${state.dueCards} card${state.dueCards != 1 ? 's' : ''}'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.accent,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .shimmer(delay: 800.ms, duration: 1500.ms),

                  const SizedBox(height: 16),

                  // Export / Import row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context
                              .read<VocabularyBloc>()
                              .add(const ExportVocabulary()),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Export'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showImportDialog(context),
                          icon: const Icon(Icons.upload_rounded, size: 18),
                          label: const Text('Import'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 380.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Search
                  TextField(
                    onChanged: (q) => context
                        .read<VocabularyBloc>()
                        .add(SearchVocabulary(q)),
                    decoration: InputDecoration(
                      hintText: 'Search vocabulary…',
                      prefixIcon:
                          const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: state.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 18),
                              onPressed: () => context
                                  .read<VocabularyBloc>()
                                  .add(const SearchVocabulary('')),
                            )
                          : null,
                    ),
                  ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                ],
              ),
            ),
          ),

          // Card list
          if (state.filteredCards.isEmpty)
            SliverFillRemaining(
              child: EmptyStateView(
                icon: state.searchQuery.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.style_outlined,
                title: state.searchQuery.isNotEmpty
                    ? 'No cards match your search'
                    : 'No vocabulary cards yet',
                description: state.searchQuery.isNotEmpty
                    ? 'Try a different search term.'
                    : 'Double-tap a word while translating to look it up '
                        'and add it here.',
                accentColor: AppColors.accent,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList.builder(
                itemCount: state.filteredCards.length,
                itemBuilder: (context, index) {
                  final card = state.filteredCards[index];
                  final delayMs = (50 * index).clamp(0, 500);
                  return _VocabCardTile(card: card)
                      .animate()
                      .fadeIn(
                          delay: Duration(milliseconds: delayMs),
                          duration: 300.ms)
                      .slideY(begin: 0.05, end: 0);
                },
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> _showImportDialog(BuildContext context) async {
    final bloc = context.read<VocabularyBloc>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
      dialogTitle: 'Select a vocabulary file to import',
    );
    final path = result?.files.single.path;
    if (path == null) return; // user cancelled the picker
    bloc.add(ImportVocabulary(path));
  }
}

class _VocabStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _VocabStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(label, style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VocabCardTile extends StatelessWidget {
  final VocabularyCard card;
  const _VocabCardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.englishWord,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.russianTranslation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  if (card.definition.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      card.definition,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (card.contextSentence.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.lightSurfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '📝 ${card.contextSentence}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // SRS info
            Column(
              children: [
                Text(
                  SrsEngine.intervalLabel(card.interval),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  onPressed: () => context
                      .read<VocabularyBloc>()
                      .add(DeleteVocabularyCard(card.id)),
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Review Mode ────────────────────────────────────────────────────────────

class _ReviewMode extends StatelessWidget {
  final VocabularyState state;
  const _ReviewMode({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isReviewComplete) {
      return _ReviewComplete(
        reviewedCount: state.reviewedCount,
        onExit: () =>
            context.read<VocabularyBloc>().add(const ExitReview()),
      );
    }

    final card = state.currentReviewCard!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () =>
              context.read<VocabularyBloc>().add(const ExitReview()),
        ),
        title: Text(
          'Review ${state.currentReviewIndex + 1}/${state.reviewQueue.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: LinearProgressIndicator(
                value: state.reviewQueue.isEmpty
                    ? 0
                    : state.currentReviewIndex / state.reviewQueue.length,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D Flashcard with flip animation
              Expanded(
                child: FlipFlashCard(
                  card: card,
                  isFlipped: state.isCardFlipped,
                  onFlip: () => context
                      .read<VocabularyBloc>()
                      .add(const FlipCard()),
                ),
              ),
              const SizedBox(height: 24),

              // Rating buttons (shown after flip)
              if (state.isCardFlipped)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RatingButton(
                      label: 'Again',
                      subtitle: '1d',
                      color: AppColors.srsAgain,
                      onPressed: () => context
                          .read<VocabularyBloc>()
                          .add(RateCard(card.id, 1)),
                    ),
                    _RatingButton(
                      label: 'Hard',
                      subtitle: SrsEngine.intervalLabel(
                        max(1, (card.interval * 1.2).round()),
                      ),
                      color: AppColors.srsHard,
                      onPressed: () => context
                          .read<VocabularyBloc>()
                          .add(RateCard(card.id, 3)),
                    ),
                    _RatingButton(
                      label: 'Good',
                      subtitle: SrsEngine.intervalLabel(
                        max(1, (card.interval * card.easeFactor).round()),
                      ),
                      color: AppColors.srsGood,
                      onPressed: () => context
                          .read<VocabularyBloc>()
                          .add(RateCard(card.id, 4)),
                    ),
                    _RatingButton(
                      label: 'Easy',
                      subtitle: SrsEngine.intervalLabel(
                        max(1, (card.interval * card.easeFactor * 1.3).round()),
                      ),
                      color: AppColors.srsEasy,
                      onPressed: () => context
                          .read<VocabularyBloc>()
                          .add(RateCard(card.id, 5)),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2, end: 0)
              else
                Text(
                  'Tap the card to reveal the answer',
                  style: theme.textTheme.bodySmall,
                ).animate().fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// _FlashCard removed — replaced by FlipFlashCard widget with 3D animation

class _RatingButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _RatingButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
}

class _ReviewComplete extends StatelessWidget {
  final int reviewedCount;
  final VoidCallback onExit;

  const _ReviewComplete({
    required this.reviewedCount,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  size: 40,
                  color: AppColors.success,
                ),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Review Complete! 🎉',
                style: theme.textTheme.headlineLarge,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'You reviewed $reviewedCount card${reviewedCount != 1 ? 's' : ''}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.success,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onExit,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Vocabulary'),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
