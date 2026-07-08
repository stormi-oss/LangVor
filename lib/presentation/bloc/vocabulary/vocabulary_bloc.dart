import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
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

  const AddVocabularyCard({
    required this.englishWord,
    required this.russianTranslation,
    this.definition = '',
    this.contextSentence = '',
    this.partOfSpeech = '',
  });

  @override
  List<Object?> get props =>
      [englishWord, russianTranslation, definition, contextSentence];
}

class DeleteVocabularyCard extends VocabularyEvent {
  final int cardId;
  const DeleteVocabularyCard(this.cardId);
  @override
  List<Object?> get props => [cardId];
}

class StartReview extends VocabularyEvent {
  const StartReview();
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

class ImportVocabulary extends VocabularyEvent {
  final String filePath;
  const ImportVocabulary(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

enum ExportFormat { json, csv }

// ─── State ──────────────────────────────────────────────────────────────────

enum VocabularyStatus { initial, loading, loaded, reviewing, error }

class VocabularyState extends Equatable {
  final VocabularyStatus status;
  final List<VocabularyCard> allCards;
  final List<VocabularyCard> filteredCards;
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
    this.allCards = const [],
    this.filteredCards = const [],
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
  int get remainingReviewCount =>
      reviewQueue.length - currentReviewIndex;

  VocabularyState copyWith({
    VocabularyStatus? status,
    List<VocabularyCard>? allCards,
    List<VocabularyCard>? filteredCards,
    List<VocabularyCard>? reviewQueue,
    int? currentReviewIndex,
    bool? isCardFlipped,
    int? totalCards,
    int? dueCards,
    String? searchQuery,
    String? errorMessage,
    String? exportedFilePath,
    bool clearExport = false,
    int? importedCount,
    bool clearImport = false,
  }) {
    return VocabularyState(
      status: status ?? this.status,
      allCards: allCards ?? this.allCards,
      filteredCards: filteredCards ?? this.filteredCards,
      reviewQueue: reviewQueue ?? this.reviewQueue,
      currentReviewIndex: currentReviewIndex ?? this.currentReviewIndex,
      isCardFlipped: isCardFlipped ?? this.isCardFlipped,
      totalCards: totalCards ?? this.totalCards,
      dueCards: dueCards ?? this.dueCards,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      exportedFilePath:
          clearExport ? null : (exportedFilePath ?? this.exportedFilePath),
      importedCount:
          clearImport ? null : (importedCount ?? this.importedCount),
    );
  }

  @override
  List<Object?> get props => [
        status,
        allCards,
        filteredCards,
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
    on<DeleteVocabularyCard>(_onDeleteCard);
    on<StartReview>(_onStartReview);
    on<RateCard>(_onRateCard);
    on<FlipCard>(_onFlipCard);
    on<ExitReview>(_onExitReview);
    on<SearchVocabulary>(_onSearch);
    on<ExportVocabulary>(_onExport);
    on<ImportVocabulary>(_onImport);
  }

  Future<void> _onLoadVocabulary(
    LoadVocabulary event,
    Emitter<VocabularyState> emit,
  ) async {
    emit(state.copyWith(status: VocabularyStatus.loading));
    try {
      final allCards = await _db.getAllVocabularyCards();
      final dueCards = await _db.getCardsDueForReview();
      emit(state.copyWith(
        status: VocabularyStatus.loaded,
        allCards: allCards,
        filteredCards: allCards,
        totalCards: allCards.length,
        dueCards: dueCards.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VocabularyStatus.error,
        errorMessage: e.toString(),
      ));
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
        ),
      );
      add(const LoadVocabulary());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add card: $e'));
    }
  }

  Future<void> _onDeleteCard(
    DeleteVocabularyCard event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      await _db.deleteVocabularyCard(event.cardId);
      add(const LoadVocabulary());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete card: $e'));
    }
  }

  Future<void> _onStartReview(
    StartReview event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      final dueCards = await _db.getCardsDueForReview();
      emit(state.copyWith(
        status: VocabularyStatus.reviewing,
        reviewQueue: dueCards,
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
      final card =
          state.reviewQueue.firstWhere((c) => c.id == event.cardId);

      final result = SrsEngine.calculate(
        quality: event.quality,
        currentRepetitions: card.repetitions,
        currentInterval: card.interval,
        currentEaseFactor: card.easeFactor,
      );

      // Update the card in the database
      final updatedCard = VocabularyCard(
        id: card.id,
        englishWord: card.englishWord,
        russianTranslation: card.russianTranslation,
        definition: card.definition,
        contextSentence: card.contextSentence,
        partOfSpeech: card.partOfSpeech,
        createdAt: card.createdAt,
        nextReviewAt: result.nextReviewAt,
        easeFactor: result.easeFactor,
        interval: result.interval,
        repetitions: result.repetitions,
      );

      await _db.updateVocabularyCard(updatedCard);

      final nextIndex = state.currentReviewIndex + 1;
      emit(state.copyWith(
        currentReviewIndex: nextIndex,
        isCardFlipped: false,
      ));

      // If review complete, reload vocabulary
      if (nextIndex >= state.reviewQueue.length) {
        add(const LoadVocabulary());
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to rate card: $e'));
    }
  }

  void _onFlipCard(
    FlipCard event,
    Emitter<VocabularyState> emit,
  ) {
    emit(state.copyWith(isCardFlipped: !state.isCardFlipped));
  }

  void _onExitReview(
    ExitReview event,
    Emitter<VocabularyState> emit,
  ) {
    emit(state.copyWith(
      status: VocabularyStatus.loaded,
      reviewQueue: [],
      currentReviewIndex: 0,
      isCardFlipped: false,
    ));
    add(const LoadVocabulary());
  }

  void _onSearch(
    SearchVocabulary event,
    Emitter<VocabularyState> emit,
  ) {
    final query = event.query.toLowerCase();
    final filtered = query.isEmpty
        ? state.allCards
        : state.allCards.where((c) {
            return c.englishWord.toLowerCase().contains(query) ||
                c.russianTranslation.toLowerCase().contains(query) ||
                c.definition.toLowerCase().contains(query);
          }).toList();

    emit(state.copyWith(
      filteredCards: filtered,
      searchQuery: event.query,
    ));
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

      final timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      String filePath;

      if (event.format == ExportFormat.csv) {
        filePath = p.join(exportDir.path, 'vocabulary_$timestamp.csv');
        final csv = _cardsToCSV(cards);
        await File(filePath).writeAsString(csv);
      } else {
        filePath = p.join(exportDir.path, 'vocabulary_$timestamp.json');
        final json = _cardsToJSON(cards);
        await File(filePath).writeAsString(json);
      }

      emit(state.copyWith(exportedFilePath: filePath));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Export failed: $e'));
    }
  }

  String _cardsToJSON(List<VocabularyCard> cards) {
    final list = cards.map((c) => {
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
        }).toList();
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

      final content = await file.readAsString();
      int importedCount = 0;

      if (event.filePath.endsWith('.csv')) {
        importedCount = await _importCSV(content);
      } else {
        importedCount = await _importJSON(content);
      }

      emit(state.copyWith(importedCount: importedCount));
      add(const LoadVocabulary());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Import failed: $e'));
    }
  }

  Future<int> _importJSON(String content) async {
    final list = jsonDecode(content) as List;
    int count = 0;

    for (final item in list) {
      final map = item as Map<String, dynamic>;
      await _db.insertVocabularyCard(
        VocabularyCardsCompanion.insert(
          englishWord: map['englishWord'] as String? ?? '',
          russianTranslation: map['russianTranslation'] as String? ?? '',
          definition: Value(map['definition'] as String? ?? ''),
          contextSentence: Value(map['contextSentence'] as String? ?? ''),
          partOfSpeech: Value(map['partOfSpeech'] as String? ?? ''),
        ),
      );
      count++;
    }
    return count;
  }

  Future<int> _importCSV(String content) async {
    final lines = const LineSplitter().convert(content);
    if (lines.length < 2) return 0; // header only or empty

    int count = 0;
    // Skip header line
    for (int i = 1; i < lines.length; i++) {
      final fields = _parseCSVLine(lines[i]);
      if (fields.length < 2) continue;

      await _db.insertVocabularyCard(
        VocabularyCardsCompanion.insert(
          englishWord: fields[0],
          russianTranslation: fields[1],
          definition: Value(fields.length > 2 ? fields[2] : ''),
          contextSentence: Value(fields.length > 3 ? fields[3] : ''),
          partOfSpeech: Value(fields.length > 4 ? fields[4] : ''),
        ),
      );
      count++;
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
          i++; // skip escaped quote
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
