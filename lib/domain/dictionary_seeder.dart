import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import '../data/database.dart';

/// Seeds the dictionary_entries and grammar_rules tables from bundled
/// JSON assets on first launch.
///
/// Loads a 50k+ bilingual EN-RU dictionary and ~200 grammar rules.
class DictionarySeeder {
  final AppDatabase _db;

  DictionarySeeder(this._db);

  /// Check whether the dictionary has already been seeded.
  Future<bool> isDictionarySeeded() async {
    final entries = await (_db.select(_db.dictionaryEntries)..limit(1)).get();
    return entries.isNotEmpty;
  }

  /// Check whether grammar rules have been seeded.
  Future<bool> areGrammarRulesSeeded() async {
    final rules = await (_db.select(_db.grammarRules)..limit(1)).get();
    return rules.isNotEmpty;
  }

  /// Seeds the dictionary from the bundled JSON asset.
  /// Returns the number of entries inserted.
  ///
  /// Processes entries in batches of 500 to avoid memory spikes.
  Future<int> seedDictionary({
    String assetPath = 'assets/dictionary/en_ru_50k.json',
    void Function(int inserted, int total)? onProgress,
  }) async {
    if (await isDictionarySeeded()) return 0;

    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> entries = jsonDecode(jsonString) as List<dynamic>;

    const batchSize = 500;
    int totalInserted = 0;

    for (int i = 0; i < entries.length; i += batchSize) {
      final end = (i + batchSize).clamp(0, entries.length);
      final batch = entries.sublist(i, end);

      final companions = batch.map((entry) {
        final map = entry as Map<String, dynamic>;
        return DictionaryEntriesCompanion.insert(
          word: (map['word'] as String? ?? '').toLowerCase().trim(),
          definition: map['definition'] as String? ?? '',
          partOfSpeech: Value(map['partOfSpeech'] as String? ?? ''),
          russianTranslation:
              Value(map['russianTranslation'] as String? ?? ''),
          synonyms: Value(map['synonyms'] as String? ?? ''),
          frequencyRank: Value(map['frequencyRank'] as int? ?? 99999),
          cefrLevel: Value(map['cefrLevel'] as String? ?? ''),
          exampleSentence: Value(map['exampleSentence'] as String? ?? ''),
        );
      }).toList();

      await _db.insertDictionaryEntries(companions);
      totalInserted += companions.length;

      onProgress?.call(totalInserted, entries.length);
    }

    return totalInserted;
  }

  /// Seeds grammar rules from the bundled JSON asset.
  /// Returns the number of rules inserted.
  Future<int> seedGrammarRules({
    String assetPath = 'assets/grammar/grammar_rules.json',
  }) async {
    if (await areGrammarRulesSeeded()) return 0;

    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> rules = jsonDecode(jsonString) as List<dynamic>;

    final companions = rules.map((rule) {
      final map = rule as Map<String, dynamic>;
      return GrammarRulesCompanion.insert(
        category: map['category'] as String? ?? '',
        pattern: map['pattern'] as String? ?? '',
        correction: map['correction'] as String? ?? '',
        explanation: map['explanation'] as String? ?? '',
        exampleWrong: Value(map['exampleWrong'] as String? ?? ''),
        exampleCorrect: Value(map['exampleCorrect'] as String? ?? ''),
      );
    }).toList();

    await _db.insertGrammarRules(companions);
    return companions.length;
  }

  /// Seeds both dictionary and grammar rules.
  Future<void> seedAll({
    void Function(int inserted, int total)? onDictionaryProgress,
  }) async {
    await seedDictionary(onProgress: onDictionaryProgress);
    await seedGrammarRules();
  }
}
