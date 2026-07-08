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
import 'vocabulary_study_screen.dart';

/// Vocabulary section: a Finder-style browser (folders + list/grid/column
/// views, inline rename, context menus, drag & drop) plus the SRS study
/// modes.
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
        return _BrowseView(state: state);
      },
    );
  }
}

// ─── Browse view ─────────────────────────────────────────────────────────────

class _BrowseView extends StatefulWidget {
  final VocabularyState state;
  const _BrowseView({required this.state});

  @override
  State<_BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<_BrowseView> {
  int? _selectedCardId; // for column-view detail pane
  int? _editingFolderId; // inline rename target

  VocabularyBloc get _bloc => context.read<VocabularyBloc>();
  VocabularyState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 760;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (isWide) ...[
              _FolderSidebar(
                state: state,
                editingFolderId: _editingFolderId,
                onStartRename: (id) => setState(() => _editingFolderId = id),
                onEndRename: () => setState(() => _editingFolderId = null),
              ),
              const VerticalDivider(width: 1),
            ],
            Expanded(
              child: Column(
                children: [
                  _Toolbar(state: state, compactFolders: !isWide),
                  Expanded(child: _content(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (state.status == VocabularyStatus.loading) {
      return const LoadingStateView(label: 'Loading your vocabulary…');
    }
    if (state.filteredCards.isEmpty) {
      return EmptyStateView(
        icon: state.searchQuery.isNotEmpty
            ? Icons.search_off_rounded
            : Icons.style_outlined,
        title: state.searchQuery.isNotEmpty
            ? 'No cards match your search'
            : 'No cards here yet',
        description: state.searchQuery.isNotEmpty
            ? 'Try a different search term.'
            : 'Add a word, or import a .txt/.csv/.json/.xlsx file to fill '
                'this folder.',
        accentColor: AppColors.primary,
        action: FilledButton.icon(
          onPressed: () => _showAddWordDialog(context, _bloc, state),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add a word'),
        ),
      );
    }

    switch (state.viewMode) {
      case VocabViewMode.grid:
        return _CardGridView(cards: state.filteredCards);
      case VocabViewMode.column:
        return _ColumnView(
          cards: state.filteredCards,
          selectedCardId: _selectedCardId,
          onSelect: (id) => setState(() => _selectedCardId = id),
        );
      case VocabViewMode.list:
        return _CardListView(cards: state.filteredCards);
    }
  }
}

// ─── Folder sidebar ──────────────────────────────────────────────────────────

class _FolderSidebar extends StatelessWidget {
  final VocabularyState state;
  final int? editingFolderId;
  final ValueChanged<int> onStartRename;
  final VoidCallback onEndRename;

  const _FolderSidebar({
    required this.state,
    required this.editingFolderId,
    required this.onStartRename,
    required this.onEndRename,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bloc = context.read<VocabularyBloc>();

    return Container(
      width: 240,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
            child: Text('Vocabulary', style: theme.textTheme.titleLarge),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: [
                _SmartRow(
                  icon: Icons.apps_rounded,
                  label: 'All Words',
                  count: state.allCards.length,
                  selected:
                      state.selectedFolderId == null && !state.favoritesOnly,
                  onTap: () => bloc.add(const SelectFolder(null)),
                ),
                _SmartRow(
                  icon: Icons.star_rounded,
                  label: 'Favorites',
                  count: state.allCards.where((c) => c.favorite).length,
                  selected: state.favoritesOnly,
                  onTap: () =>
                      bloc.add(const SelectFolder(null, favoritesOnly: true)),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
                  child: Text('FOLDERS',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700)),
                ),
                ...state.folders.map((f) => _FolderRow(
                      folder: f,
                      count: state.countInFolder(f.id),
                      selected: state.selectedFolderId == f.id &&
                          !state.favoritesOnly,
                      editing: editingFolderId == f.id,
                      onStartRename: () => onStartRename(f.id),
                      onEndRename: onEndRename,
                    )),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: OutlinedButton.icon(
                    onPressed: () => _showNewFolderDialog(context, bloc),
                    icon: const Icon(Icons.create_new_folder_outlined,
                        size: 18),
                    label: const Text('New Folder'),
                  ),
                ),
              ],
            ),
          ),
          // Stats footer
          _StatsFooter(state: state),
        ],
      ),
    );
  }
}

class _SmartRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SmartRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: selected
                      ? AppColors.primary
                      : theme.textTheme.bodySmall?.color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: selected ? AppColors.primary : null,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    )),
              ),
              Text('$count', style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// A folder row: selectable, a drop target for cards, inline-renamable, with
/// a right-click context menu.
class _FolderRow extends StatefulWidget {
  final VocabularyFolder folder;
  final int count;
  final bool selected;
  final bool editing;
  final VoidCallback onStartRename;
  final VoidCallback onEndRename;

  const _FolderRow({
    required this.folder,
    required this.count,
    required this.selected,
    required this.editing,
    required this.onStartRename,
    required this.onEndRename,
  });

  @override
  State<_FolderRow> createState() => _FolderRowState();
}

class _FolderRowState extends State<_FolderRow> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.folder.name);
  final _focus = FocusNode();
  bool _dragOver = false;

  @override
  void didUpdateWidget(_FolderRow old) {
    super.didUpdateWidget(old);
    if (widget.editing && !old.editing) {
      _controller.text = widget.folder.name;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focus.requestFocus();
        _controller.selection = TextSelection(
            baseOffset: 0, extentOffset: _controller.text.length);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit() {
    final bloc = context.read<VocabularyBloc>();
    bloc.add(RenameFolder(widget.folder.id, _controller.text));
    widget.onEndRename();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<VocabularyBloc>();

    return DragTarget<VocabularyCard>(
      onWillAcceptWithDetails: (_) {
        setState(() => _dragOver = true);
        return true;
      },
      onLeave: (_) => setState(() => _dragOver = false),
      onAcceptWithDetails: (d) {
        setState(() => _dragOver = false);
        bloc.add(MoveCard(d.data.id, widget.folder.id));
      },
      builder: (context, candidate, rejected) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            onTap: () => bloc.add(SelectFolder(widget.folder.id)),
            onDoubleTap: widget.onStartRename,
            onSecondaryTapDown: (d) =>
                _folderContextMenu(context, bloc, widget.folder, d.globalPosition),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 10),
              decoration: BoxDecoration(
                color: _dragOver
                    ? AppColors.primary.withValues(alpha: 0.22)
                    : widget.selected
                        ? AppColors.primary.withValues(alpha: 0.14)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: _dragOver
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_rounded,
                      size: 18,
                      color: widget.selected
                          ? AppColors.primary
                          : AppColors.warning),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: widget.editing
                        ? TextField(
                            controller: _controller,
                            focusNode: _focus,
                            style: theme.textTheme.titleSmall,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 2),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _commit(),
                            onTapOutside: (_) => _commit(),
                          )
                        : Text(widget.folder.name,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color:
                                  widget.selected ? AppColors.primary : null,
                              fontWeight: widget.selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            )),
                  ),
                  if (!widget.editing)
                    Text('${widget.count}',
                        style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatsFooter extends StatelessWidget {
  final VocabularyState state;
  const _StatsFooter({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (state.learnedPercent * 100).round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Learned', style: theme.textTheme.labelSmall),
              Text('$pct%',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.learnedPercent,
              minHeight: 6,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${state.learnedCount} of ${state.totalCards} words',
              style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

// ─── Toolbar ─────────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final VocabularyState state;
  final bool compactFolders;
  const _Toolbar({required this.state, required this.compactFolders});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VocabularyBloc>();
    final due = state.dueCards;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          // Search
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                onChanged: (q) => bloc.add(SearchVocabulary(q)),
                decoration: const InputDecoration(
                  hintText: 'Search…',
                  isDense: true,
                  prefixIcon: Icon(Icons.search_rounded, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // View switcher
          _ViewSwitcher(current: state.viewMode),
          const SizedBox(width: AppSpacing.md),
          // Actions
          IconButton(
            tooltip: 'Add word',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddWordDialog(context, bloc, state),
          ),
          IconButton(
            tooltip: 'Import file',
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () => _showImportDialog(context, bloc),
          ),
          IconButton(
            tooltip: 'Export',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => bloc.add(const ExportVocabulary()),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.icon(
            onPressed: due > 0
                ? () => _openStudy(context, state)
                : null,
            icon: const Icon(Icons.school_rounded, size: 18),
            label: Text(due > 0 ? 'Study ($due)' : 'Study'),
          ),
        ],
      ),
    );
  }
}

class _ViewSwitcher extends StatelessWidget {
  final VocabViewMode current;
  const _ViewSwitcher({required this.current});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VocabularyBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget btn(VocabViewMode mode, IconData icon, String tip) {
      final selected = current == mode;
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => bloc.add(SetViewMode(mode)),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn(VocabViewMode.list, Icons.view_list_rounded, 'List'),
        btn(VocabViewMode.grid, Icons.grid_view_rounded, 'Grid'),
        btn(VocabViewMode.column, Icons.view_column_rounded, 'Columns'),
      ]),
    );
  }
}

// ─── List / grid / column content ────────────────────────────────────────────

class _CardListView extends StatelessWidget {
  final List<VocabularyCard> cards;
  const _CardListView({required this.cards});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: cards.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: _DraggableCard(
          card: cards[i],
          child: _CardTile(card: cards[i]),
        ),
      ),
    );
  }
}

class _CardGridView extends StatelessWidget {
  final List<VocabularyCard> cards;
  const _CardGridView({required this.cards});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 132,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) => _DraggableCard(
        card: cards[i],
        child: _CardCell(card: cards[i]),
      ),
    );
  }
}

class _ColumnView extends StatelessWidget {
  final List<VocabularyCard> cards;
  final int? selectedCardId;
  final ValueChanged<int> onSelect;
  const _ColumnView({
    required this.cards,
    required this.selectedCardId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = cards.firstWhere(
      (c) => c.id == selectedCardId,
      orElse: () => cards.first,
    );
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.sm),
            itemCount: cards.length,
            itemBuilder: (context, i) {
              final c = cards[i];
              final isSel = c.id == selected.id;
              return _DraggableCard(
                card: c,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    onTap: () => onSelect(c.id),
                    onSecondaryTapDown: (d) => _cardContextMenu(
                        context,
                        context.read<VocabularyBloc>(),
                        c,
                        d.globalPosition),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Text(c.englishWord,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      color: isSel ? AppColors.primary : null)),
                        ),
                        if (c.favorite)
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.warning),
                        const Icon(Icons.chevron_right_rounded, size: 16),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _CardDetailPane(card: selected)),
      ],
    );
  }
}

class _CardDetailPane extends StatelessWidget {
  final VocabularyCard card;
  const _CardDetailPane({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(card.englishWord,
                    style: theme.textTheme.displayMedium),
              ),
              IconButton(
                tooltip: card.favorite ? 'Unfavorite' : 'Favorite',
                icon: Icon(
                    card.favorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.warning),
                onPressed: () => context
                    .read<VocabularyBloc>()
                    .add(ToggleFavorite(card.id)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(card.russianTranslation,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: AppColors.primary)),
          if (card.partOfSpeech.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Chip(label: Text(card.partOfSpeech)),
          ],
          if (card.definition.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Definition', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(card.definition, style: theme.textTheme.bodyLarge),
          ],
          if (card.contextSentence.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Example', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('“${card.contextSentence}”',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(children: [
            _MetaChip(
                icon: Icons.repeat_rounded,
                label: 'Reps: ${card.repetitions}'),
            const SizedBox(width: AppSpacing.sm),
            _MetaChip(
                icon: Icons.schedule_rounded,
                label: SrsEngine.intervalLabel(card.interval)),
          ]),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: AppColors.primary)),
      ]),
    );
  }
}

/// Wraps a card in a Draggable so it can be dropped onto folders.
class _DraggableCard extends StatelessWidget {
  final VocabularyCard card;
  final Widget child;
  const _DraggableCard({required this.card, required this.child});

  @override
  Widget build(BuildContext context) {
    return Draggable<VocabularyCard>(
      data: card,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            boxShadow: AppColors.hoverShadow(true),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.drag_indicator_rounded,
                size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(card.englishWord,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: child),
      child: child,
    );
  }
}

class _CardTile extends StatelessWidget {
  final VocabularyCard card;
  const _CardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bloc = context.read<VocabularyBloc>();

    return GestureDetector(
      onSecondaryTapDown: (d) =>
          _cardContextMenu(context, bloc, card, d.globalPosition),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: theme.dividerColor),
          boxShadow: AppColors.cardShadow(isDark),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(card.englishWord,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    if (card.favorite) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded,
                          size: 15, color: AppColors.warning),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Text(card.russianTranslation,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.primary)),
                  if (card.definition.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(card.definition,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Column(children: [
              Text(SrsEngine.intervalLabel(card.interval),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: AppColors.accent)),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox;
                  _cardContextMenu(context, bloc, card,
                      box.localToGlobal(box.size.center(Offset.zero)));
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _CardCell extends StatelessWidget {
  final VocabularyCard card;
  const _CardCell({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bloc = context.read<VocabularyBloc>();

    return GestureDetector(
      onSecondaryTapDown: (d) =>
          _cardContextMenu(context, bloc, card, d.globalPosition),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: theme.dividerColor),
          boxShadow: AppColors.cardShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(card.englishWord,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              if (card.favorite)
                const Icon(Icons.star_rounded,
                    size: 15, color: AppColors.warning),
            ]),
            const SizedBox(height: 4),
            Text(card.russianTranslation,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.primary)),
            const Spacer(),
            Text(SrsEngine.intervalLabel(card.interval),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: AppColors.accent)),
          ],
        ),
      ),
    );
  }
}

// ─── Context menus ───────────────────────────────────────────────────────────

Future<void> _cardContextMenu(BuildContext context, VocabularyBloc bloc,
    VocabularyCard card, Offset pos) async {
  final overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
        pos.dx, pos.dy, overlay.size.width - pos.dx, 0),
    items: [
      const PopupMenuItem(value: 'edit', child: Text('Edit')),
      PopupMenuItem(
          value: 'fav',
          child: Text(card.favorite
              ? 'Remove from favorites'
              : 'Add to favorites')),
      const PopupMenuItem(value: 'move', child: Text('Move to folder…')),
      const PopupMenuDivider(),
      const PopupMenuItem(value: 'delete', child: Text('Delete')),
    ],
  );
  if (selected == null || !context.mounted) return;
  switch (selected) {
    case 'edit':
      _showEditWordDialog(context, bloc, card);
      break;
    case 'fav':
      bloc.add(ToggleFavorite(card.id));
      break;
    case 'move':
      _showMoveToFolderDialog(context, bloc, card);
      break;
    case 'delete':
      bloc.add(DeleteVocabularyCard(card.id));
      break;
  }
}

Future<void> _folderContextMenu(BuildContext context, VocabularyBloc bloc,
    VocabularyFolder folder, Offset pos) async {
  final overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
        pos.dx, pos.dy, overlay.size.width - pos.dx, 0),
    items: const [
      PopupMenuItem(value: 'study', child: Text('Study this folder')),
      PopupMenuItem(value: 'delete', child: Text('Delete folder')),
    ],
  );
  if (selected == null || !context.mounted) return;
  if (selected == 'delete') {
    bloc.add(DeleteFolderEvent(folder.id));
  } else if (selected == 'study') {
    bloc.add(SelectFolder(folder.id));
  }
}

// ─── Dialogs ─────────────────────────────────────────────────────────────────

Future<void> _showNewFolderDialog(
    BuildContext context, VocabularyBloc bloc) async {
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New Folder'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Folder name'),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Create')),
      ],
    ),
  );
  if (name != null && name.trim().isNotEmpty) {
    bloc.add(CreateFolder(name.trim()));
  }
}

Future<void> _showImportDialog(
    BuildContext context, VocabularyBloc bloc) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['txt', 'csv', 'json', 'xlsx', 'xls'],
    dialogTitle: 'Import vocabulary (a new folder will be created)',
  );
  final path = result?.files.single.path;
  if (path == null) return;
  bloc.add(ImportVocabulary(path));
}

Future<void> _showAddWordDialog(
    BuildContext context, VocabularyBloc bloc, VocabularyState state) {
  return _showWordDialog(context, title: 'Add Word', onSubmit: (fields) {
    bloc.add(AddVocabularyCard(
      englishWord: fields[0],
      russianTranslation: fields[1],
      definition: fields[2],
      contextSentence: fields[3],
      folderId: state.selectedFolderId,
    ));
  });
}

Future<void> _showEditWordDialog(
    BuildContext context, VocabularyBloc bloc, VocabularyCard card) {
  return _showWordDialog(
    context,
    title: 'Edit Word',
    initial: [
      card.englishWord,
      card.russianTranslation,
      card.definition,
      card.contextSentence,
    ],
    onSubmit: (fields) {
      bloc.add(UpdateVocabularyCardEvent(card.copyWith(
        englishWord: fields[0],
        russianTranslation: fields[1],
        definition: fields[2],
        contextSentence: fields[3],
      )));
    },
  );
}

Future<void> _showWordDialog(
  BuildContext context, {
  required String title,
  List<String>? initial,
  required void Function(List<String> fields) onSubmit,
}) async {
  final ctrls = List.generate(
      4, (i) => TextEditingController(text: initial?[i] ?? ''));
  final labels = ['English word', 'Russian translation', 'Definition', 'Example'];

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: TextField(
                controller: ctrls[i],
                autofocus: i == 0,
                decoration: InputDecoration(labelText: labels[i]),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save')),
      ],
    ),
  );
  if (ok == true) {
    onSubmit(ctrls.map((c) => c.text.trim()).toList());
  }
}

Future<void> _showMoveToFolderDialog(
    BuildContext context, VocabularyBloc bloc, VocabularyCard card) async {
  final folders = bloc.state.folders;
  final target = await showDialog<int?>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Move to folder'),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, -1),
          child: const Text('Unfiled (no folder)'),
        ),
        ...folders.map((f) => SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, f.id),
              child: Row(children: [
                const Icon(Icons.folder_rounded,
                    size: 18, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Text(f.name),
              ]),
            )),
      ],
    ),
  );
  if (target == null) return;
  bloc.add(MoveCard(card.id, target == -1 ? null : target));
}

void _openStudy(BuildContext context, VocabularyState state) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: context.read<VocabularyBloc>(),
      child: VocabularyStudyScreen(folderId: state.selectedFolderId),
    ),
  ));
}

// ─── Review Mode (SRS flashcards) ────────────────────────────────────────────

class _ReviewMode extends StatelessWidget {
  final VocabularyState state;
  const _ReviewMode({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isReviewComplete) {
      return _ReviewComplete(
        reviewedCount: state.reviewedCount,
        onExit: () => context.read<VocabularyBloc>().add(const ExitReview()),
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
              child: SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: state.reviewQueue.isEmpty
                      ? 0
                      : state.currentReviewIndex / state.reviewQueue.length,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FlipFlashCard(
                    card: card,
                    isFlipped: state.isCardFlipped,
                    onFlip: () =>
                        context.read<VocabularyBloc>().add(const FlipCard()),
                  ),
                ),
                const SizedBox(height: 24),
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
                            max(1, (card.interval * 1.2).round())),
                        color: AppColors.srsHard,
                        onPressed: () => context
                            .read<VocabularyBloc>()
                            .add(RateCard(card.id, 3)),
                      ),
                      _RatingButton(
                        label: 'Good',
                        subtitle: SrsEngine.intervalLabel(
                            max(1, (card.interval * card.easeFactor).round())),
                        color: AppColors.srsGood,
                        onPressed: () => context
                            .read<VocabularyBloc>()
                            .add(RateCard(card.id, 4)),
                      ),
                      _RatingButton(
                        label: 'Easy',
                        subtitle: SrsEngine.intervalLabel(max(
                            1, (card.interval * card.easeFactor * 1.3).round())),
                        color: AppColors.srsEasy,
                        onPressed: () => context
                            .read<VocabularyBloc>()
                            .add(RateCard(card.id, 5)),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0)
                else
                  Text('Tap the card to reveal the answer',
                      style: theme.textTheme.bodySmall)
                      .animate()
                      .fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(subtitle,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color)),
      ],
    );
  }
}

class _ReviewComplete extends StatelessWidget {
  final int reviewedCount;
  final VoidCallback onExit;

  const _ReviewComplete({required this.reviewedCount, required this.onExit});

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
                child: const Icon(Icons.celebration_rounded,
                    size: 40, color: AppColors.success),
              ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text('Review Complete! 🎉', style: theme.textTheme.headlineLarge)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'You reviewed $reviewedCount card${reviewedCount != 1 ? 's' : ''}',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: AppColors.success),
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
