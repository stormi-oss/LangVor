import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../theme/app_colors.dart';
import '../bloc/translation/translation_bloc.dart';
import '../bloc/vocabulary/vocabulary_bloc.dart';
import '../widgets/formatting_toolbar.dart';
import '../widgets/error_tooltip.dart';
import '../widgets/new_project_dialog.dart';
import '../widgets/state_placeholders.dart';
import '../../domain/offline_analyzer.dart';
import '../../domain/online/online_translation_checker.dart' show CheckSource;

/// Rich-text translation workspace with dual Quill editors.
///
/// Replaces the old segment-based [TranslationWorkspaceScreen].
/// Layout: side-by-side Russian source + English translation with
/// inline error highlighting and formatting toolbar.
class RichTranslationWorkspace extends StatefulWidget {
  const RichTranslationWorkspace({super.key});

  @override
  State<RichTranslationWorkspace> createState() =>
      _RichTranslationWorkspaceState();
}

class _RichTranslationWorkspaceState extends State<RichTranslationWorkspace> {
  QuillController? _sourceController;
  QuillController? _translationController;
  QuillController? _activeController;
  final _sourceFocusNode = FocusNode();
  final _translationFocusNode = FocusNode();
  InlineError? _selectedError;
  final _sourceScrollController = ScrollController();
  final _translationScrollController = ScrollController();
  StreamSubscription<DocChange>? _sourceChangesSub;
  StreamSubscription<DocChange>? _translationChangesSub;

  @override
  void initState() {
    super.initState();
    context.read<TranslationBloc>().add(const LoadProjects());

    _sourceFocusNode.addListener(() {
      if (_sourceFocusNode.hasFocus) {
        setState(() => _activeController = _sourceController);
      }
    });
    _translationFocusNode.addListener(() {
      if (_translationFocusNode.hasFocus) {
        setState(() => _activeController = _translationController);
      }
    });
  }

  @override
  void dispose() {
    _sourceChangesSub?.cancel();
    _translationChangesSub?.cancel();
    _sourceController?.dispose();
    _translationController?.dispose();
    _sourceFocusNode.dispose();
    _translationFocusNode.dispose();
    _sourceScrollController.dispose();
    _translationScrollController.dispose();
    super.dispose();
  }

  void _initControllers(TranslationState state) {
    final bloc = context.read<TranslationBloc>();

    // Initialize source controller
    if (_sourceController == null ||
        _sourceController!.document.toPlainText().trim() !=
            state.sourceText.trim()) {
      _sourceChangesSub?.cancel();
      _sourceController?.dispose();
      _sourceController = QuillController(
        document: _documentFromState(state.sourceText, state.sourceDelta),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _sourceChangesSub = _sourceController!.document.changes.listen((_) {
        final text = _sourceController!.document.toPlainText();
        final delta =
            jsonEncode(_sourceController!.document.toDelta().toJson());
        bloc.add(UpdateSourceText(text, delta));
      });
    }

    // Initialize translation controller
    if (_translationController == null) {
      _translationController = QuillController(
        document: _documentFromState(
            state.translationText, state.translationDelta),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _translationChangesSub =
          _translationController!.document.changes.listen((_) {
        final text = _translationController!.document.toPlainText();
        final delta = jsonEncode(
            _translationController!.document.toDelta().toJson());
        bloc.add(UpdateTranslationText(text, delta));
      });
    }
  }

  void _applyAlignment(bool isVerse) {
    final attribute = isVerse
        ? Attribute.centerAlignment
        : Attribute.clone(Attribute.align, null);
    if (_sourceController != null) {
      _sourceController!
          .formatText(0, _sourceController!.document.length, attribute);
    }
    if (_translationController != null) {
      _translationController!
          .formatText(0, _translationController!.document.length, attribute);
    }
  }

  Document _documentFromState(String plainText, String deltaJson) {
    if (deltaJson.isNotEmpty) {
      try {
        final json = jsonDecode(deltaJson) as List;
        return Document.fromJson(json);
      } catch (_) {}
    }
    if (plainText.isNotEmpty) {
      return Document()..insert(0, plainText);
    }
    return Document();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state.selectedProject == null) {
          return _buildProjectList(context, state);
        }
        _initControllers(state);
        return _buildWorkspace(context, state);
      },
    );
  }

  // ── Project List ──

  Widget _buildProjectList(BuildContext context, TranslationState state) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Translation\nWorkspace',
                    style: theme.textTheme.displayLarge,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Paste Russian text and translate freely with real-time offline analysis',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.titleSmall?.color,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 24),
                  if (state.projects.isNotEmpty) ...[
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.article_outlined,
                          label: '${state.projects.length} projects',
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          if (state.projects.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  return _ProjectCard(
                    project: project,
                    onTap: () => context
                        .read<TranslationBloc>()
                        .add(SelectProject(project.id)),
                    onDelete: () => context
                        .read<TranslationBloc>()
                        .add(DeleteProject(project.id)),
                  )
                      .animate()
                      .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewProjectDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Text'),
      ).animate().scale(delay: 400.ms, duration: 300.ms),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const EmptyStateView(
      icon: Icons.translate_rounded,
      title: 'Start Your Translation Journey',
      description: 'Paste a Russian text and translate it freely. '
          'LangVor checks spelling and grammar locally, and compares your '
          'translation against a real reference translation in real time.',
    );
  }

  // ── Active Workspace ──

  Widget _buildWorkspace(BuildContext context, TranslationState state) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            _sourceChangesSub?.cancel();
            _sourceChangesSub = null;
            _sourceController?.dispose();
            _sourceController = null;
            _translationChangesSub?.cancel();
            _translationChangesSub = null;
            _translationController?.dispose();
            _translationController = null;
            context.read<TranslationBloc>().add(const LoadProjects());
          },
        ),
        title: Text(
          state.selectedProject?.title ?? 'Translation',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Book / Verse Mode Toggle
          if (state.selectedProject != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: ToggleButtons(
                isSelected: [
                  !state.selectedProject!.isVerseMode,
                  state.selectedProject!.isVerseMode,
                ],
                onPressed: (index) {
                  final isVerse = index == 1;
                  context
                      .read<TranslationBloc>()
                      .add(ToggleVerseMode(isVerse));
                  _applyAlignment(isVerse);
                },
                borderRadius: BorderRadius.circular(20),
                constraints: const BoxConstraints(minHeight: 32, minWidth: 64),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Книга', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Стих', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          // Analyze button
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              onPressed: state.isAnalyzing
                  ? null
                  : () => context
                      .read<TranslationBloc>()
                      .add(const RunAnalysis()),
              icon: state.isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text('Analyze'),
            ),
          ),
          // Score badge
          if (state.analysisResult != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _ScoreBadge(score: state.overallScore),
            ),
        ],
      ),
      body: Column(
        children: [
          // Formatting Toolbar
          FormattingToolbar(activeController: _activeController),
          // Editor panels
          Expanded(
            child: isWide
                ? _buildSideBySide(context, state)
                : _buildStacked(context, state),
          ),
          // Analysis bar at bottom
          if (state.analysisResult != null)
            _AnalysisBar(
              result: state.analysisResult!,
              isAnalyzing: state.isAnalyzing,
              isCheckingOnline: state.isCheckingOnline,
              onlineCheckingEnabled: state.onlineCheckingEnabled,
            ).animate().slideY(begin: 1, end: 0, duration: 300.ms),
          // Error tooltip overlay
          if (_selectedError != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ErrorTooltip(
                error: _selectedError!,
                onApplyFix: () {
                  context
                      .read<TranslationBloc>()
                      .add(ApplySuggestion(_selectedError!.id));
                  setState(() => _selectedError = null);
                },
                onDismiss: () {
                  context
                      .read<TranslationBloc>()
                      .add(DismissError(_selectedError!.id));
                  setState(() => _selectedError = null);
                },
                onClose: () => setState(() => _selectedError = null),
              ).animate().fadeIn(duration: 200.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildSideBySide(BuildContext context, TranslationState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _buildSourcePanel(context, state),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: theme.dividerTheme.color ??
              (isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
        Expanded(
          flex: 5,
          child: _buildTranslationPanel(context, state),
        ),
      ],
    );
  }

  Widget _buildStacked(BuildContext context, TranslationState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          flex: 4,
          child: _buildSourcePanel(context, state),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerTheme.color ??
              (isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
        Expanded(
          flex: 4,
          child: _buildTranslationPanel(context, state),
        ),
      ],
    );
  }

  // ── Source Panel (Russian) ──

  Widget _buildSourcePanel(BuildContext context, TranslationState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.04),
          ),
          child: Row(
            children: [
              const Icon(Icons.source_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'RUSSIAN SOURCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '${state.sourceText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
        ),
        // Quill Editor
        Expanded(
          child: GestureDetector(
            onDoubleTap: () {
              // Get selected word from controller for dictionary lookup
              if (_sourceController != null) {
                final selection = _sourceController!.selection;
                final text = _sourceController!.document.toPlainText();
                final word = _extractWordAtSelection(text, selection);
                if (word != null && word.isNotEmpty) {
                  _showWordLookup(context, word, text);
                }
              }
            },
            child: QuillEditor(
              controller: _sourceController!,
              focusNode: _sourceFocusNode,
              scrollController: _sourceScrollController,
              config: QuillEditorConfig(
                padding: const EdgeInsets.all(16),
                placeholder: 'Paste your Russian text here...',
                customStyles: _editorStyles(isDark, state.selectedProject?.isVerseMode ?? false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Translation Panel (English) ──

  Widget _buildTranslationPanel(
      BuildContext context, TranslationState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasErrors = state.activeErrorCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.accent.withValues(alpha: 0.08)
                : AppColors.accent.withValues(alpha: 0.04),
          ),
          child: Row(
            children: [
              const Icon(Icons.edit_note_rounded,
                  size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'ENGLISH TRANSLATION',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (hasErrors)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${state.activeErrorCount} ${state.activeErrorCount == 1 ? "issue" : "issues"}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!hasErrors && state.analysisResult != null)
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: AppColors.success),
            ],
          ),
        ),
        // Quill Editor with error overlay
        Expanded(
          child: Stack(
            children: [
              QuillEditor(
                controller: _translationController!,
                focusNode: _translationFocusNode,
                scrollController: _translationScrollController,
                config: QuillEditorConfig(
                  padding: const EdgeInsets.all(16),
                  placeholder: 'Type your English translation here...',
                  customStyles: _editorStyles(isDark, state.selectedProject?.isVerseMode ?? false),
                ),
              ),
              // Error indicators (tappable)
              if (state.inlineErrors.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: _ErrorIndicatorColumn(
                    errors: state.inlineErrors
                        .where((e) => !e.dismissed)
                        .toList(),
                    onErrorTap: (error) {
                      setState(() => _selectedError = error);
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  DefaultStyles _editorStyles(bool isDark, bool isVerseMode) {
    return DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        TextStyle(
          fontSize: 16,
          height: 1.6,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        HorizontalSpacing(isVerseMode ? 0 : 20.0, 0),
        VerticalSpacing(isVerseMode ? 6 : 12, isVerseMode ? 6 : 12),
        const VerticalSpacing(0, 0),
        null,
      ),
    );
  }


  String? _extractWordAtSelection(
      String text, TextSelection selection) {
    if (text.isEmpty) return null;
    int start = selection.baseOffset.clamp(0, text.length - 1);
    int end = start;

    // Expand to word boundaries
    final wordChars = RegExp(r'[a-zA-Zа-яА-ЯёЁ]');
    while (start > 0 && wordChars.hasMatch(text[start - 1])) {
      start--;
    }
    while (end < text.length && wordChars.hasMatch(text[end])) {
      end++;
    }

    if (start >= end) return null;
    return text.substring(start, end);
  }

  void _showWordLookup(
      BuildContext context, String word, String contextSentence) {
    context.read<TranslationBloc>().add(LookupWord(word));

    showDialog(
      context: context,
      builder: (_) => _WordLookupDialog(
        word: word,
        contextSentence: contextSentence,
        onAddToVocabulary: (eng, rus, def) {
          context.read<VocabularyBloc>().add(AddVocabularyCard(
                englishWord: eng,
                russianTranslation: rus,
                definition: def,
                contextSentence: contextSentence,
              ));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Added "$eng" to vocabulary')),
          );
        },
      ),
    );
  }

  void _showNewProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => NewProjectDialog(
        onSubmit: (text) {
          context.read<TranslationBloc>().add(CreateProject(text));
        },
      ),
    );
  }
}

// ─── Helper Widgets ─────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final percent = (score * 100).toInt();
    final color = score >= 0.8
        ? AppColors.success
        : score >= 0.5
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value: score,
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(color),
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisBar extends StatelessWidget {
  final AnalysisResult result;
  final bool isAnalyzing;
  final bool isCheckingOnline;
  final bool onlineCheckingEnabled;

  const _AnalysisBar({
    required this.result,
    required this.isAnalyzing,
    this.isCheckingOnline = false,
    this.onlineCheckingEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceElevated,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkDivider
                : AppColors.lightDivider,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isAnalyzing)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            Icon(
              result.errors.isEmpty
                  ? Icons.check_circle_outline_rounded
                  : Icons.info_outline_rounded,
              size: 16,
              color: result.errors.isEmpty
                  ? AppColors.success
                  : AppColors.warning,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAnalyzing ? 'Analyzing...' : result.feedback,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _OnlineStatusChip(
            isChecking: isCheckingOnline,
            checkSource: result.checkSource,
            enabled: onlineCheckingEnabled,
          ),
        ],
      ),
    );
  }
}

/// Small status indicator for the MyMemory-backed translation check.
class _OnlineStatusChip extends StatelessWidget {
  final bool isChecking;
  final CheckSource checkSource;
  final bool enabled;

  const _OnlineStatusChip({
    required this.isChecking,
    required this.checkSource,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    if (!enabled) {
      return _chip(
        context,
        icon: Icons.cloud_off_rounded,
        label: 'Offline',
        color: mutedColor,
      );
    }
    if (isChecking) {
      return _chip(
        context,
        icon: Icons.cloud_sync_rounded,
        label: 'Checking online…',
        color: AppColors.info,
      );
    }
    switch (checkSource) {
      case CheckSource.online:
        return _chip(
          context,
          icon: Icons.cloud_done_rounded,
          label: 'Checked online',
          color: AppColors.success,
        );
      case CheckSource.cache:
        return _chip(
          context,
          icon: Icons.cloud_done_rounded,
          label: 'Checked (cached)',
          color: AppColors.success,
        );
      case CheckSource.offlineFallback:
        return _chip(
          context,
          icon: Icons.cloud_off_rounded,
          label: 'Offline checks only',
          color: mutedColor,
        );
    }
  }

  Widget _chip(BuildContext context,
      {required IconData icon, required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final dynamic project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.article_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(project.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _ErrorIndicatorColumn extends StatelessWidget {
  final List<InlineError> errors;
  final void Function(InlineError) onErrorTap;

  const _ErrorIndicatorColumn({
    required this.errors,
    required this.onErrorTap,
  });

  @override
  Widget build(BuildContext context) {
    // Show at most 5 error indicators
    final display = errors.take(5).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: display.map((error) {
        final color = _severityColor(error.severity);
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Tooltip(
            message: error.message,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onErrorTap(error),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  _severityIcon(error.severity),
                  size: 14,
                  color: color,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _severityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.error:
        return const Color(0xFFFF6B6B);
      case ErrorSeverity.warning:
        return const Color(0xFFFFB74D);
      case ErrorSeverity.suggestion:
        return const Color(0xFF64B5F6);
    }
  }

  IconData _severityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.error:
        return Icons.error_outline_rounded;
      case ErrorSeverity.warning:
        return Icons.warning_amber_rounded;
      case ErrorSeverity.suggestion:
        return Icons.info_outline_rounded;
    }
  }
}

/// Dialog for looking up a word in the dictionary.
class _WordLookupDialog extends StatelessWidget {
  final String word;
  final String contextSentence;
  final void Function(String eng, String rus, String def) onAddToVocabulary;

  const _WordLookupDialog({
    required this.word,
    required this.contextSentence,
    required this.onAddToVocabulary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        return AlertDialog(
          title: Text(
            word,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SizedBox(
            width: 360,
            child: state.isLookupLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : state.lookupResults.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Word not found in dictionary.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.lookupResults.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, index) {
                          final entry = state.lookupResults[index];
                          return ListTile(
                            title: Text(entry.word),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.definition,
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (entry.russianTranslation.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '🇷🇺 ${entry.russianTranslation}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                if (entry.partOfSpeech.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      entry.partOfSpeech,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: isDark
                                            ? AppColors.darkTextTertiary
                                            : AppColors.lightTextTertiary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.accent,
                              ),
                              tooltip: 'Add to Vocabulary',
                              onPressed: () {
                                onAddToVocabulary(
                                  entry.word,
                                  entry.russianTranslation,
                                  entry.definition,
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context
                    .read<TranslationBloc>()
                    .add(const DismissLookup());
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

