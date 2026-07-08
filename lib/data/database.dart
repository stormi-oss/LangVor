import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ─── Tables ───────────────────────────────────────────────────────────────────

/// Stores entire Russian source texts with continuous user translations (v2).
class TranslationProjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get sourceText => text()();
  TextColumn get userTranslation =>
      text().withDefault(const Constant(''))();
  TextColumn get sourceFormatted =>
      text().withDefault(const Constant(''))();
  TextColumn get translationFormatted =>
      text().withDefault(const Constant(''))();
  BoolColumn get isVerseMode =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Vocabulary flashcards with SM-2 spaced repetition metadata.
class VocabularyCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get englishWord => text()();
  TextColumn get russianTranslation => text()();
  TextColumn get definition => text().withDefault(const Constant(''))();
  TextColumn get contextSentence => text().withDefault(const Constant(''))();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // SM-2 SRS fields
  DateTimeColumn get nextReviewAt =>
      dateTime().withDefault(currentDateAndTime)();
  RealColumn get easeFactor =>
      real().withDefault(const Constant(2.5))();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
}

/// Local dictionary entries for instant lookup (bundled with the app).
class DictionaryEntries extends Table {
  TextColumn get word => text()();
  TextColumn get definition => text()();
  TextColumn get synonyms => text().withDefault(const Constant(''))();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  IntColumn get frequencyRank =>
      integer().withDefault(const Constant(99999))();
  TextColumn get russianTranslation =>
      text().withDefault(const Constant(''))();
  TextColumn get cefrLevel =>
      text().withDefault(const Constant(''))();
  TextColumn get exampleSentence =>
      text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {word};
}

/// Grammar rules for offline pattern-based checking.
class GrammarRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  TextColumn get pattern => text()();
  TextColumn get correction => text()();
  TextColumn get explanation => text()();
  TextColumn get exampleWrong =>
      text().withDefault(const Constant(''))();
  TextColumn get exampleCorrect =>
      text().withDefault(const Constant(''))();
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  TranslationProjects,
  VocabularyCards,
  DictionaryEntries,
  GrammarRules,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Constructor for testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Add new columns to TranslationProjects
            await m.addColumn(
                translationProjects, translationProjects.userTranslation);
            await m.addColumn(
                translationProjects, translationProjects.sourceFormatted);
            await m.addColumn(
                translationProjects, translationProjects.translationFormatted);

            // Add new columns to DictionaryEntries
            await m.addColumn(
                dictionaryEntries, dictionaryEntries.cefrLevel);
            await m.addColumn(
                dictionaryEntries, dictionaryEntries.exampleSentence);

            // Create GrammarRules table
            await m.createTable(grammarRules);

            // Drop TranslationSegments table (old schema)
            await customStatement('DROP TABLE IF EXISTS translation_segments');
          }
          if (from < 3) {
            // Add isVerseMode column to TranslationProjects
            await m.addColumn(
                translationProjects, translationProjects.isVerseMode);
          }
        },
      );

  // ── Project Queries ──

  Future<List<TranslationProject>> getAllProjects() =>
      (select(translationProjects)
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.updatedAt, mode: OrderingMode.desc)
            ]))
          .get();

  Stream<List<TranslationProject>> watchAllProjects() =>
      (select(translationProjects)
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.updatedAt, mode: OrderingMode.desc)
            ]))
          .watch();

  Future<int> insertProject(TranslationProjectsCompanion project) =>
      into(translationProjects).insert(project);

  Future<bool> updateProject(TranslationProject project) =>
      update(translationProjects).replace(project);

  Future<int> deleteProject(int id) =>
      (delete(translationProjects)..where((t) => t.id.equals(id))).go();

  // ── Vocabulary Queries ──

  Future<List<VocabularyCard>> getAllVocabularyCards() =>
      (select(vocabularyCards)
            ..orderBy([
              (c) => OrderingTerm(
                  expression: c.createdAt, mode: OrderingMode.desc)
            ]))
          .get();

  Stream<List<VocabularyCard>> watchAllVocabularyCards() =>
      (select(vocabularyCards)
            ..orderBy([
              (c) => OrderingTerm(
                  expression: c.createdAt, mode: OrderingMode.desc)
            ]))
          .watch();

  Future<List<VocabularyCard>> getCardsDueForReview() {
    final now = DateTime.now();
    return (select(vocabularyCards)
          ..where((c) => c.nextReviewAt.isSmallerOrEqualValue(now))
          ..orderBy([(c) => OrderingTerm(expression: c.nextReviewAt)]))
        .get();
  }

  Stream<List<VocabularyCard>> watchCardsDueForReview() {
    final now = DateTime.now();
    return (select(vocabularyCards)
          ..where((c) => c.nextReviewAt.isSmallerOrEqualValue(now))
          ..orderBy([(c) => OrderingTerm(expression: c.nextReviewAt)]))
        .watch();
  }

  Future<int> insertVocabularyCard(VocabularyCardsCompanion card) =>
      into(vocabularyCards).insert(card);

  Future<bool> updateVocabularyCard(VocabularyCard card) =>
      update(vocabularyCards).replace(card);

  Future<int> deleteVocabularyCard(int id) =>
      (delete(vocabularyCards)..where((c) => c.id.equals(id))).go();

  Future<int> get totalVocabularyCount async {
    final count = countAll();
    final query = selectOnly(vocabularyCards)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // ── Dictionary Queries ──

  Future<List<DictionaryEntry>> lookupWord(String query) =>
      (select(dictionaryEntries)
            ..where((d) => d.word.like('$query%'))
            ..orderBy([(d) => OrderingTerm(expression: d.frequencyRank)])
            ..limit(20))
          .get();

  Future<DictionaryEntry?> getExactWord(String word) =>
      (select(dictionaryEntries)..where((d) => d.word.equals(word.toLowerCase())))
          .getSingleOrNull();

  /// Batch lookup: check which words exist in the dictionary.
  Future<List<DictionaryEntry>> batchLookupWords(List<String> words) async {
    if (words.isEmpty) return [];
    final lowerWords = words.map((w) => w.toLowerCase()).toList();
    return (select(dictionaryEntries)
          ..where((d) => d.word.isIn(lowerWords)))
        .get();
  }

  /// Search dictionary by prefix with limit.
  Future<List<DictionaryEntry>> searchDictionary(String prefix, int limit) =>
      (select(dictionaryEntries)
            ..where((d) => d.word.like('${prefix.toLowerCase()}%'))
            ..orderBy([(d) => OrderingTerm(expression: d.frequencyRank)])
            ..limit(limit))
          .get();

  Future<void> insertDictionaryEntries(
      List<DictionaryEntriesCompanion> entries) async {
    await batch((b) {
      b.insertAll(dictionaryEntries, entries,
          mode: InsertMode.insertOrReplace);
    });
  }

  // ── Grammar Rules Queries ──

  Future<List<GrammarRule>> getGrammarRulesByCategory(String category) =>
      (select(grammarRules)..where((r) => r.category.equals(category))).get();

  Future<List<GrammarRule>> getAllGrammarRules() =>
      select(grammarRules).get();

  Future<void> insertGrammarRules(
      List<GrammarRulesCompanion> rules) async {
    await batch((b) {
      b.insertAll(grammarRules, rules, mode: InsertMode.insertOrReplace);
    });
  }
}

// ─── Connection ───────────────────────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'langvor', 'langvor.db'));

    // Create directory if it doesn't exist
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    return NativeDatabase.createInBackground(file);
  });
}
