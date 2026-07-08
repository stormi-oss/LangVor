import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:excel/excel.dart' as xls;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' show Value;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../data/database.dart';
import '../../../domain/srs_engine.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class VocabularyEvent extends Equatable {
  const VocabularyEvent();
  @override
  List<Object?> get props => [];
}

class LoadVocabulary extends VocabularyEvent {
  const LoadVocabulary();
}

class AddVocabularyCard extends VocabularyEvent {
  final String englishWord;
  final String russianTranslation;
  final String definition;
  final String contextSentence;
  final String partOfSpeech;
  final int? folderId;

  const AddVocabularyCard({
    required this.englishWord,
    required this.russianTranslation,
    this.definition = '',
    this.contextSentence = '',
    this.partOfSpeech = '',
    this.folderId,
  });

  @override
  List<Object?> get props =>
      [englishWord, russianTranslation, definition, contextSentence, folderId];
}

class UpdateVocabularyCardEvent extends VocabularyEvent {
  final VocabularyCard card;
  const UpdateVocabularyCardEvent(this.card);
  @override
  List<Object?> get props => [card];
}

class DeleteVocabularyCard extends VocabularyEvent {
  final int cardId;
  const DeleteVocabularyCard(this.cardId);
  @override
  List<Object?> get props => [cardId];
}

class ToggleFavorite extends VocabularyEvent {
  final int cardId;
  const ToggleFavorite(this.cardId);
  @override
  List<Object?> get props => [cardId];
}

class MoveCard extends VocabularyEvent {
  final int cardId;
  final int? folderId; // null = unfiled
  const MoveCard(this.cardId, this.folderId);
  @override
  List<Object?> get props => [cardId, folderId];
}

// ── Folder events ──

class CreateFolder extends VocabularyEvent {
  final String name;
  const CreateFolder(this.name);
  @override
  List<Object?> get props => [name];
}

class RenameFolder extends VocabularyEvent {
  final int folderId;
  final String name;
  const RenameFolder(this.folderId, this.name);
  @override
  List<Object?> get props => [folderId, name];
}

class DeleteFolderEvent extends VocabularyEvent {
  final int folderId;
  const DeleteFolderEvent(this.folderId);
  @override
  List<Object?> get props => [folderId];
}

class SelectFolder extends VocabularyEvent {
  final int? folderId; // null = All
  final bool favoritesOnly;
  const SelectFolder(this.folderId, {this.favoritesOnly = false});
  @override
  List<Object?> get props => [folderId, favoritesOnly];
}

class SetViewMode extends VocabularyEvent {
  final VocabViewMode mode;
  const SetViewMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

// ── Review events ──

class StartReview extends VocabularyEvent {
  /// If set, review only cards in this folder; otherwise all due cards.
  final int? folderId;
  const StartReview({this.folderId});
  @override
  List<Object?> get props => [folderId];
}

class RateCard extends VocabularyEvent {
  final int cardId;
  final int quality; // 0-5 SM-2 quality rating
  const RateCard(this.cardId, this.quality);
  @override
  List<Object?> get props => [cardId, quality];
}

class FlipCard extends VocabularyEvent {
  const FlipCard();
}

class ExitReview extends VocabularyEvent {
  const ExitReview();
}

class SearchVocabulary extends VocabularyEvent {
  final String query;
  const SearchVocabulary(this.query);
  @override
  List<Object?> get props => [query];
}

class ExportVocabulary extends VocabularyEvent {
  final ExportFormat format;
  const ExportVocabulary({this.format = ExportFormat.json});
  @override
  List<Object?> get props => [format];
}

/// Imports words from a file. If [asNewFolder] is true, a folder named after
/// the file is created and the imported cards are placed in it.
class ImportVocabulary extends VocabularyEvent {
  final String filePath;
  final bool asNewFolder;
  const ImportVocabulary(this.filePath, {this.asNewFolder = true});
  @override
  List<Object?> get props => [filePath, asNewFolder];
}

enum ExportFormat { json, csv }

enum VocabViewMode { list, grid, column }

// ─── State ──────────────────────────────────────────────────────────────────

enum VocabularyStatus { initial, loading, loaded, reviewing, error }

class VocabularyState extends Equatable {
  final VocabularyStatus status;
  final List<VocabularyFolder> folders;
  final List<VocabularyCard> allCards;
  final List<VocabularyCard> filteredCards;
  final int? selectedFolderId; // null = All
  final bool favoritesOnly;
  final VocabViewMode viewMode;
  final List<VocabularyCard> reviewQueue;
  final int currentReviewIndex;
  final bool isCardFlipped;
  final int totalCards;
  final int dueCards;
  final String searchQuery;
  final String? errorMessage;
  final String? exportedFilePath;
  final int? importedCount;

  const VocabularyState({
    this.status = VocabularyStatus.initial,
    this.folders = const [],
    this.allCards = const [],
    this.filteredCards = const [],
    this.selectedFolderId,
    this.favoritesOnly = false,
    this.viewMode = VocabViewMode.list,
    this.reviewQueue = const [],
    this.currentReviewIndex = 0,
    this.isCardFlipped = false,
    this.totalCards = 0,
    this.dueCards = 0,
    this.searchQuery = '',
    this.errorMessage,
    this.exportedFilePath,
    this.importedCount,
  });

  VocabularyCard? get currentReviewCard {
    if (reviewQueue.isEmpty || currentReviewIndex >= reviewQueue.length) {
      return null;
    }
    return reviewQueue[currentReviewIndex];
  }

  bool get isReviewComplete =>
      reviewQueue.isEmpty || currentReviewIndex >= reviewQueue.length;

  int get reviewedCount => currentReviewIndex;
  int get remainingReviewCount => reviewQueue.length - currentReviewIndex;

  /// A word is considered "learned" once it has survived a few successful
  /// SM-2 repetitions.
  int get learnedCount => allCards.where((c) => c.repetitions >= 3).length;
  double get learnedPercent =>
      allCards.isEmpty ? 0 : learnedCount / allCards.length;

  int countInFolder(int? folderId) =>
      allCards.where((c) => c.folderId == folderId).length;

  VocabularyState copyWith({
    VocabularyStatus? status,
    List<VocabularyFolder>? folders,
    List<VocabularyCard>? allCards,
    List<VocabularyCard>? filteredCards,
    int? selectedFolderId,
    bool clearSelectedFolder = false,
    bool? favoritesOnly,
    VocabViewMode? viewMode,
    List<VocabularyCard>? reviewQueue,
    int? currentReviewIndex,
    bool? isCardFlipped,
    int? totalCards,
    int? dueCards,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    String? exportedFilePath,
    bool clearExport = false,
    int? importedCount,
    bool clearImport = false,
  }) {
    return VocabularyState(
      status: status ?? this.status,
      folders: folders ?? this.folders,
      allCards: allCards ?? this.allCards,
      filteredCards: filteredCards ?? this.filteredCards,
      selectedFolderId:
          clearSelectedFolder ? null : (selectedFolderId ?? this.selectedFolderId),
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      viewMode: viewMode ?? this.viewMode,
      reviewQueue: reviewQueue ?? this.reviewQueue,
      currentReviewIndex: currentReviewIndex ?? this.currentReviewIndex,
      isCardFlipped: isCardFlipped ?? this.isCardFlipped,
      totalCards: totalCards ?? this.totalCards,
      dueCards: dueCards ?? this.dueCards,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      exportedFilePath:
          clearExport ? null : (exportedFilePath ?? this.exportedFilePath),
      importedCount:
          clearImport ? null : (importedCount ?? this.importedCount),
    );
  }

  @override
  List<Object?> get props => [
        status,
        folders,
        allCards,
        filteredCards,
        selectedFolderId,
        favoritesOnly,
        viewMode,
        reviewQueue,
        currentReviewIndex,
        isCardFlipped,
        totalCards,
        dueCards,
        searchQuery,
        errorMessage,
        exportedFilePath,
        importedCount,
      ];
}

// ─── BLoC ───────────────────────────────────────────────────────────────────

class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  final AppDatabase _db;

  VocabularyBloc(this._db) : super(const VocabularyState()) {
    on<LoadVocabulary>(_onLoadVocabulary);
    on<AddVocabularyCard>(_onAddCard);
    on<UpdateVocabularyCardEvent>(_onUpdateCard);
    on<DeleteVocabularyCard>(_onDeleteCard);
    on<ToggleFavorite>(_onToggleFavorite);
    on<MoveCard>(_onMoveCard);
    on<CreateFolder>(_onCreateFolder);
    on<RenameFolder>(_onRenameFolder);
    on<DeleteFolderEvent>(_onDeleteFolder);
    on<SelectFolder>(_onSelectFolder);
    on<SetViewMode>(_onSetViewMode);
    on<StartReview>(_onStartReview);
    on<RateCard>(_onRateCard);
    on<FlipCard>(_onFlipCard);
    on<ExitReview>(_onExitReview);
    on<SearchVocabulary>(_onSearch);
    on<ExportVocabulary>(_onExport);
    on<ImportVocabulary>(_onImport);
  }

  /// Recomputes [VocabularyState.filteredCards] from the current folder,
  /// favorites, and search selections.
  List<VocabularyCard> _applyFilters(
    List<VocabularyCard> all, {
    required int? folderId,
    required bool favoritesOnly,
    required String query,
    required bool allFolders,
  }) {
    var cards = all;
    if (!allFolders) {
      cards = cards.where((c) => c.folderId == folderId).toList();
    }
    if (favoritesOnly) {
      cards = cards.where((c) => c.favorite).toList();
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      cards = cards.where((c) {
        return c.englishWord.toLowerCase().contains(q) ||
            c.russianTranslation.toLowerCase().contains(q) ||
            c.definition.toLowerCase().contains(q);
      }).toList();
    }
    return cards;
  }

  Future<void> _reload(Emitter<VocabularyState> emit,
      {VocabularyStatus status = VocabularyStatus.loaded}) async {
    final folders = await _db.getAllFolders();
    final allCards = await _db.getAllVocabularyCards();
    final due = await _db.getCardsDueForReview();
    // `selectedFolderId == null` means "All" unless favoritesOnly is set.
    final filtered = _applyFilters(
      allCards,
      folderId: state.selectedFolderId,
      favoritesOnly: state.favoritesOnly,
      query: state.searchQuery,
      allFolders: state.selectedFolderId == null && !state.favoritesOnly,
    );
    emit(state.copyWith(
      status: status,
      folders: folders,
      allCards: allCards,
      filteredCards: filtered,
      totalCards: allCards.length,
      dueCards: due.length,
    ));
  }

  Future<void> _onLoadVocabulary(
    LoadVocabulary event,
    Emitter<VocabularyState> emit,
  ) async {
    emit(state.copyWith(status: VocabularyStatus.loading));
    try {
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(
          status: VocabularyStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddCard(
    AddVocabularyCard event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      await _db.insertVocabularyCard(
        VocabularyCardsCompanion.insert(
          englishWord: event.englishWord,
          russianTranslation: event.russianTranslation,
          definition: Value(event.definition),
          contextSentence: Value(event.contextSentence),
          partOfSpeech: Value(event.partOfSpeech),
          folderId: Value(event.folderId ?? state.selectedFolderId),
        ),
      );
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add card: $e'));
    }
  }

  Future<void> _onUpdateCard(
    UpdateVocabularyCardEvent event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      await _db.updateVocabularyCard(event.card);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update card: $e'));
    }
  }

  Future<void> _onDeleteCard(
    DeleteVocabularyCard event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      await _db.deleteVocabularyCard(event.cardId);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete card: $e'));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      final card = state.allCards.firstWhere((c) => c.id == event.cardId);
      await _db.setCardFavorite(event.cardId, !card.favorite);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed: $e'));
    }
  }

  Future<void> _onMoveCard(
    MoveCard event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      await _db.moveCardToFolder(event.cardId, event.folderId);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to move card: $e'));
    }
  }

  Future<void> _onCreateFolder(
    CreateFolder event,
    Emitter<VocabularyState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    try {
      final id = await _db.insertFolder(
        VocabularyFoldersCompanion.insert(name: name),
      );
      emit(state.copyWith(selectedFolderId: id, favoritesOnly: false));
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to create folder: $e'));
    }
  }

  Future<void> _onRenameFolder(
    RenameFolder event,
    Emitter<VocabularyState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    try {
      final folder = state.folders.firstWhere((f) => f.id == event.folderId);
      await _db.updateFolder(folder.copyWith(name: name));
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to rename folder: $e'));
    }
  }

  Future<void> _onDeleteFolder(
    DeleteFolderEvent event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      await _db.deleteFolder(event.folderId);
      if (state.selectedFolderId == event.folderId) {
        emit(state.copyWith(clearSelectedFolder: true, favoritesOnly: false));
      }
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete folder: $e'));
    }
  }

  Future<void> _onSelectFolder(
    SelectFolder event,
    Emitter<VocabularyState> emit,
  ) async {
    final filtered = _applyFilters(
      state.allCards,
      folderId: event.folderId,
      favoritesOnly: event.favoritesOnly,
      query: state.searchQuery,
      allFolders: event.folderId == null && !event.favoritesOnly,
    );
    emit(state.copyWith(
      selectedFolderId: event.folderId,
      clearSelectedFolder: event.folderId == null,
      favoritesOnly: event.favoritesOnly,
      filteredCards: filtered,
    ));
  }

  void _onSetViewMode(
    SetViewMode event,
    Emitter<VocabularyState> emit,
  ) {
    emit(state.copyWith(viewMode: event.mode));
  }

  Future<void> _onStartReview(
    StartReview event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      var due = await _db.getCardsDueForReview();
      if (event.folderId != null) {
        due = due.where((c) => c.folderId == event.folderId).toList();
      }
      emit(state.copyWith(
        status: VocabularyStatus.reviewing,
        reviewQueue: due,
        currentReviewIndex: 0,
        isCardFlipped: false,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to start review: $e'));
    }
  }

  Future<void> _onRateCard(
    RateCard event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      final card = state.reviewQueue.firstWhere((c) => c.id == event.cardId);
      final result = SrsEngine.calculate(
        quality: event.quality,
        currentRepetitions: card.repetitions,
        currentInterval: card.interval,
        currentEaseFactor: card.easeFactor,
      );
      await _db.updateVocabularyCard(card.copyWith(
        nextReviewAt: result.nextReviewAt,
        easeFactor: result.easeFactor,
        interval: result.interval,
        repetitions: result.repetitions,
      ));

      final nextIndex = state.currentReviewIndex + 1;
      emit(state.copyWith(currentReviewIndex: nextIndex, isCardFlipped: false));
      if (nextIndex >= state.reviewQueue.length) {
        await _reload(emit, status: VocabularyStatus.reviewing);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to rate card: $e'));
    }
  }

  void _onFlipCard(FlipCard event, Emitter<VocabularyState> emit) {
    emit(state.copyWith(isCardFlipped: !state.isCardFlipped));
  }

  Future<void> _onExitReview(
    ExitReview event,
    Emitter<VocabularyState> emit,
  ) async {
    emit(state.copyWith(
      status: VocabularyStatus.loaded,
      reviewQueue: [],
      currentReviewIndex: 0,
      isCardFlipped: false,
    ));
    await _reload(emit);
  }

  void _onSearch(SearchVocabulary event, Emitter<VocabularyState> emit) {
    final filtered = _applyFilters(
      state.allCards,
      folderId: state.selectedFolderId,
      favoritesOnly: state.favoritesOnly,
      query: event.query,
      allFolders: state.selectedFolderId == null && !state.favoritesOnly,
    );
    emit(state.copyWith(filteredCards: filtered, searchQuery: event.query));
  }

  // ── Export ─────────────────────────────────────────────────────────────

  Future<void> _onExport(
    ExportVocabulary event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      final cards = await _db.getAllVocabularyCards();
      if (cards.isEmpty) {
        emit(state.copyWith(errorMessage: 'No cards to export.'));
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory(p.join(dir.path, 'langvor', 'exports'));
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      String filePath;
      if (event.format == ExportFormat.csv) {
        filePath = p.join(exportDir.path, 'vocabulary_$timestamp.csv');
        await File(filePath).writeAsString(_cardsToCSV(cards));
      } else {
        filePath = p.join(exportDir.path, 'vocabulary_$timestamp.json');
        await File(filePath).writeAsString(_cardsToJSON(cards));
      }
      emit(state.copyWith(exportedFilePath: filePath));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Export failed: $e'));
    }
  }

  String _cardsToJSON(List<VocabularyCard> cards) {
    final list = cards
        .map((c) => {
              'englishWord': c.englishWord,
              'russianTranslation': c.russianTranslation,
              'definition': c.definition,
              'contextSentence': c.contextSentence,
              'partOfSpeech': c.partOfSpeech,
              'easeFactor': c.easeFactor,
              'interval': c.interval,
              'repetitions': c.repetitions,
              'nextReviewAt': c.nextReviewAt.toIso8601String(),
              'createdAt': c.createdAt.toIso8601String(),
            })
        .toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  String _cardsToCSV(List<VocabularyCard> cards) {
    final buffer = StringBuffer();
    buffer.writeln(
        'englishWord,russianTranslation,definition,contextSentence,partOfSpeech,easeFactor,interval,repetitions');
    for (final c in cards) {
      buffer.writeln(
          '${_csvEscape(c.englishWord)},${_csvEscape(c.russianTranslation)},${_csvEscape(c.definition)},${_csvEscape(c.contextSentence)},${_csvEscape(c.partOfSpeech)},${c.easeFactor},${c.interval},${c.repetitions}');
    }
    return buffer.toString();
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  // ── Import ─────────────────────────────────────────────────────────────

  Future<void> _onImport(
    ImportVocabulary event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      final file = File(event.filePath);
      if (!await file.exists()) {
        emit(state.copyWith(errorMessage: 'Import file not found.'));
        return;
      }

      // Optionally create a folder named after the imported file.
      int? folderId;
      if (event.asNewFolder) {
        final base = p.basenameWithoutExtension(event.filePath);
        folderId = await _db.insertFolder(
          VocabularyFoldersCompanion.insert(name: base),
        );
      }

      final ext = p.extension(event.filePath).toLowerCase();
      int imported;
      switch (ext) {
        case '.xlsx':
        case '.xls':
          imported = await _importXlsx(file, folderId);
          break;
        case '.csv':
          imported = await _importCSV(await file.readAsString(), folderId);
          break;
        case '.json':
          imported = await _importJSON(await file.readAsString(), folderId);
          break;
        default: // .txt and anything else: line-based
          imported = await _importTxt(await file.readAsString(), folderId);
      }

      emit(state.copyWith(
        importedCount: imported,
        selectedFolderId: folderId,
        favoritesOnly: false,
      ));
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Import failed: $e'));
    }
  }

  Future<void> _insertCard(
    String english,
    String russian, {
    String definition = '',
    String context = '',
    String pos = '',
    int? folderId,
  }) async {
    if (english.trim().isEmpty && russian.trim().isEmpty) return;
    await _db.insertVocabularyCard(
      VocabularyCardsCompanion.insert(
        englishWord: english.trim(),
        russianTranslation: russian.trim(),
        definition: Value(definition.trim()),
        contextSentence: Value(context.trim()),
        partOfSpeech: Value(pos.trim()),
        folderId: Value(folderId),
      ),
    );
  }

  Future<int> _importJSON(String content, int? folderId) async {
    final list = jsonDecode(content) as List;
    int count = 0;
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      await _insertCard(
        map['englishWord'] as String? ?? map['english'] as String? ?? '',
        map['russianTranslation'] as String? ??
            map['russian'] as String? ??
            map['translation'] as String? ??
            '',
        definition: map['definition'] as String? ?? '',
        context: map['contextSentence'] as String? ?? '',
        pos: map['partOfSpeech'] as String? ?? '',
        folderId: folderId,
      );
      count++;
    }
    return count;
  }

  Future<int> _importCSV(String content, int? folderId) async {
    final lines = const LineSplitter().convert(content);
    if (lines.isEmpty) return 0;
    // Detect and skip a header row if the first cell isn't a plain word pair.
    int start = 0;
    final firstLower = lines.first.toLowerCase();
    if (firstLower.contains('english') || firstLower.contains('word')) {
      start = 1;
    }
    int count = 0;
    for (int i = start; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      final fields = _parseCSVLine(lines[i]);
      if (fields.isEmpty) continue;
      await _insertCard(
        fields[0],
        fields.length > 1 ? fields[1] : '',
        definition: fields.length > 2 ? fields[2] : '',
        context: fields.length > 3 ? fields[3] : '',
        pos: fields.length > 4 ? fields[4] : '',
        folderId: folderId,
      );
      count++;
    }
    return count;
  }

  /// Plain-text import: one entry per line, `word` then `translation` split
  /// on a tab, " - ", " — ", ";" or ",". Single-word lines are ok.
  Future<int> _importTxt(String content, int? folderId) async {
    final lines = const LineSplitter().convert(content);
    int count = 0;
    final sep = RegExp(r'\t| — | - |;|,|\||=');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final parts = trimmed.split(sep);
      await _insertCard(
        parts[0],
        parts.length > 1 ? parts.sublist(1).join(' ').trim() : '',
        folderId: folderId,
      );
      count++;
    }
    return count;
  }

  Future<int> _importXlsx(File file, int? folderId) async {
    final bytes = await file.readAsBytes();
    final book = xls.Excel.decodeBytes(bytes);
    int count = 0;
    for (final table in book.tables.values) {
      bool headerSkipped = false;
      for (final row in table.rows) {
        final cells =
            row.map((c) => c?.value?.toString().trim() ?? '').toList();
        if (cells.every((c) => c.isEmpty)) continue;
        // Skip a header row that names columns.
        if (!headerSkipped) {
          headerSkipped = true;
          final joined = cells.join(' ').toLowerCase();
          if (joined.contains('english') || joined.contains('word')) continue;
        }
        await _insertCard(
          cells.isNotEmpty ? cells[0] : '',
          cells.length > 1 ? cells[1] : '',
          definition: cells.length > 2 ? cells[2] : '',
          context: cells.length > 3 ? cells[3] : '',
          pos: cells.length > 4 ? cells[4] : '',
          folderId: folderId,
        );
        count++;
      }
    }
    return count;
  }

  /// Simple CSV line parser that handles quoted fields.
  List<String> _parseCSVLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    fields.add(buffer.toString());
    return fields;
  }
}
