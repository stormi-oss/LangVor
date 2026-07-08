import '../../data/database.dart';
import 'tokenizer.dart';
import 'spell_checker.dart';

/// Cross-lingual token matcher: Russian source → expected English → user comparison.
///
/// Tokenizes the Russian source, looks up expected English translations from
/// the dictionary, and compares against what the user actually wrote.
/// Flags missing key terms and potential mistranslations.
class TranslationMatcher {
  /// Analyze translation coverage.
  static Future<TranslationMatchResult> match({
    required String sourceRussian,
    required String userEnglish,
    required AppDatabase db,
  }) async {
    // Tokenize both texts
    final russianTokens = Tokenizer.tokenize(sourceRussian);
    final englishTokens = Tokenizer.tokenize(userEnglish);
    final userWords = englishTokens.map((t) => t.normalized).toSet();

    // Filter to Russian tokens only (Cyrillic)
    final cyrillicTokens = russianTokens.where((t) =>
        RegExp(r'^[а-яё]', caseSensitive: false).hasMatch(t.raw)).toList();

    if (cyrillicTokens.isEmpty) {
      return TranslationMatchResult(
        missingTerms: [],
        potentialMistranslations: [],
        coverageScore: userEnglish.trim().isNotEmpty ? 1.0 : 0.0,
        totalSourceTerms: 0,
        coveredTerms: 0,
      );
    }

    // Russian stop words to skip (function words, particles)
    final russianStopWords = <String>{
      'и', 'в', 'на', 'не', 'что', 'он', 'она', 'оно', 'они',
      'это', 'с', 'по', 'а', 'но', 'к', 'от', 'за', 'из',
      'у', 'о', 'об', 'до', 'для', 'при', 'про', 'без', 'под',
      'над', 'как', 'то', 'так', 'же', 'ещё', 'еще', 'уже',
      'я', 'мы', 'вы', 'ты', 'их', 'его', 'её', 'ее',
      'мой', 'моя', 'моё', 'мое', 'мои',
      'свой', 'своя', 'своё', 'свое', 'свои',
      'этот', 'эта', 'этих', 'этим', 'этой',
      'тот', 'та', 'те', 'тех', 'том', 'той',
      'быть', 'был', 'была', 'было', 'были', 'будет',
      'есть', 'нет', 'да', 'ли', 'бы',
      'все', 'всё', 'весь', 'вся', 'всех',
      'кто', 'где', 'когда', 'чем', 'чего',
      'себя', 'себе', 'собой',
      'очень', 'тоже', 'также', 'только', 'ведь',
    };

    // Look up each content Russian word's expected English translation
    final missingTerms = <MissingTerm>[];
    final potentialMistranslations = <PotentialMistranslation>[];
    int totalContent = 0;
    int covered = 0;

    for (final token in cyrillicTokens) {
      if (russianStopWords.contains(token.normalized)) continue;
      if (token.normalized.length <= 1) continue;

      totalContent++;

      // Look up this Russian word in dictionary (by russian_translation field)
      final entries = await _findEnglishForRussian(token.normalized, db);
      if (entries.isEmpty) {
        // Word not in our dictionary — skip (can't verify)
        covered++; // Don't penalize for unknown words
        continue;
      }

      // Check if any expected English word is present in user's text
      bool found = false;
      for (final entry in entries) {
        final expectedWords = _extractWords(entry.word);
        for (final expected in expectedWords) {
          if (userWords.contains(expected)) {
            found = true;
            break;
          }
          // Also check for close matches (Levenshtein ≤ 1)
          for (final userWord in userWords) {
            if (SpellChecker.levenshtein(expected, userWord) <= 1) {
              found = true;
              break;
            }
          }
          if (found) break;
        }
        if (found) break;
      }

      if (found) {
        covered++;
      } else {
        // Check for potential mistranslation (close but wrong word)
        String? closestMiss;
        int closestDist = 999;
        final expectedEnglish = entries.map((e) => e.word).toList();

        for (final expected in expectedEnglish) {
          for (final userWord in userWords) {
            final dist = SpellChecker.levenshtein(expected, userWord);
            if (dist > 1 && dist <= 3 && dist < closestDist) {
              closestDist = dist;
              closestMiss = userWord;
            }
          }
        }

        if (closestMiss != null) {
          potentialMistranslations.add(PotentialMistranslation(
            russianWord: token.raw,
            userWord: closestMiss,
            expectedWords: expectedEnglish,
          ));
        } else {
          missingTerms.add(MissingTerm(
            russianWord: token.raw,
            expectedEnglish: expectedEnglish,
            russianOffset: token.startOffset,
          ));
        }
      }
    }

    final score = totalContent > 0 ? covered / totalContent : 1.0;

    return TranslationMatchResult(
      missingTerms: missingTerms,
      potentialMistranslations: potentialMistranslations,
      coverageScore: score.clamp(0.0, 1.0),
      totalSourceTerms: totalContent,
      coveredTerms: covered,
    );
  }

  /// Search dictionary for entries whose russianTranslation contains the word.
  static Future<List<DictionaryEntry>> _findEnglishForRussian(
    String russianWord,
    AppDatabase db,
  ) async {
    // Use the database to search — look for the Russian word in translations
    final allEntries = await db.searchDictionary('', 5000);
    final matches = <DictionaryEntry>[];

    for (final entry in allEntries) {
      final translations = entry.russianTranslation.toLowerCase();
      if (translations.contains(russianWord)) {
        matches.add(entry);
        if (matches.length >= 5) break;
      }
    }
    return matches;
  }

  /// Extract individual words from a potentially multi-word entry.
  static List<String> _extractWords(String entry) {
    return entry
        .toLowerCase()
        .split(RegExp(r'[\s,/]+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }
}

/// Result of translation matching analysis.
class TranslationMatchResult {
  final List<MissingTerm> missingTerms;
  final List<PotentialMistranslation> potentialMistranslations;
  final double coverageScore; // 0.0–1.0
  final int totalSourceTerms;
  final int coveredTerms;

  const TranslationMatchResult({
    required this.missingTerms,
    required this.potentialMistranslations,
    required this.coverageScore,
    required this.totalSourceTerms,
    required this.coveredTerms,
  });
}

/// A Russian content word whose English equivalent is missing.
class MissingTerm {
  final String russianWord;
  final List<String> expectedEnglish;
  final int russianOffset;

  const MissingTerm({
    required this.russianWord,
    required this.expectedEnglish,
    required this.russianOffset,
  });
}

/// A word that's close to but not quite the expected translation.
class PotentialMistranslation {
  final String russianWord;
  final String userWord;
  final List<String> expectedWords;

  const PotentialMistranslation({
    required this.russianWord,
    required this.userWord,
    required this.expectedWords,
  });
}
