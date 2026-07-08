import '../../data/database.dart';
import 'tokenizer.dart';

/// Pattern-based grammar rule engine loaded from SQLite.
///
/// Applies rules from the GrammarRules table to detect common
/// English grammar mistakes: article misuse, preposition errors,
/// tense inconsistencies, double negatives, and subject-verb agreement.
class GrammarChecker {
  /// Run all grammar checks against the tokenized text.
  static Future<List<GrammarError>> check(
    String text,
    List<WordToken> tokens,
    AppDatabase db,
  ) async {
    final errors = <GrammarError>[];

    // Load all grammar rules from DB
    final rules = await db.getAllGrammarRules();

    // Apply regex-based rules from DB
    for (final rule in rules) {
      try {
        final regex = RegExp(rule.pattern, caseSensitive: false);
        for (final match in regex.allMatches(text)) {
          errors.add(GrammarError(
            startOffset: match.start,
            endOffset: match.end,
            message: rule.explanation,
            suggestion: rule.correction,
            category: rule.category,
            matchedText: match.group(0) ?? '',
          ));
        }
      } catch (_) {
        // Skip invalid regex patterns
      }
    }

    // Apply built-in heuristic checks
    errors.addAll(_checkArticleUsage(tokens));
    errors.addAll(_checkDoubleNegatives(tokens));
    errors.addAll(_checkSubjectVerbAgreement(tokens));

    // Deduplicate overlapping errors (keep the most specific)
    return _deduplicateErrors(errors);
  }

  /// Check a/an usage: "a" before vowel sounds, "an" before consonant sounds.
  static List<GrammarError> _checkArticleUsage(List<WordToken> tokens) {
    final errors = <GrammarError>[];
    final vowels = {'a', 'e', 'i', 'o', 'u'};
    // Words starting with silent 'h' or special vowel sounds
    final anExceptions = {'hour', 'honest', 'honor', 'honour', 'heir', 'herb'};
    // Words starting with vowel but consonant sound
    final aExceptions = {'university', 'uniform', 'union', 'unique', 'unit',
        'united', 'universal', 'use', 'used', 'useful', 'user', 'usual',
        'usually', 'european', 'one', 'once'};

    for (int i = 0; i < tokens.length - 1; i++) {
      final current = tokens[i];
      final next = tokens[i + 1];

      if (current.normalized == 'a') {
        final nextFirst = next.normalized.isNotEmpty
            ? next.normalized[0]
            : '';
        if (vowels.contains(nextFirst) &&
            !aExceptions.contains(next.normalized)) {
          errors.add(GrammarError(
            startOffset: current.startOffset,
            endOffset: next.endOffset,
            message: 'Use "an" before words starting with a vowel sound.',
            suggestion: 'an ${next.raw}',
            category: 'article',
            matchedText: '${current.raw} ${next.raw}',
          ));
        }
        if (anExceptions.contains(next.normalized)) {
          errors.add(GrammarError(
            startOffset: current.startOffset,
            endOffset: next.endOffset,
            message:
                'Use "an" before "${next.raw}" (silent h / vowel sound).',
            suggestion: 'an ${next.raw}',
            category: 'article',
            matchedText: '${current.raw} ${next.raw}',
          ));
        }
      }

      if (current.normalized == 'an') {
        final nextFirst = next.normalized.isNotEmpty
            ? next.normalized[0]
            : '';
        if (!vowels.contains(nextFirst) &&
            !anExceptions.contains(next.normalized)) {
          errors.add(GrammarError(
            startOffset: current.startOffset,
            endOffset: next.endOffset,
            message: 'Use "a" before words starting with a consonant sound.',
            suggestion: 'a ${next.raw}',
            category: 'article',
            matchedText: '${current.raw} ${next.raw}',
          ));
        }
        if (aExceptions.contains(next.normalized)) {
          errors.add(GrammarError(
            startOffset: current.startOffset,
            endOffset: next.endOffset,
            message:
                'Use "a" before "${next.raw}" (consonant sound despite vowel letter).',
            suggestion: 'a ${next.raw}',
            category: 'article',
            matchedText: '${current.raw} ${next.raw}',
          ));
        }
      }
    }
    return errors;
  }

  /// Detect double negatives: "don't ... no/nothing/nobody/never/neither".
  static List<GrammarError> _checkDoubleNegatives(List<WordToken> tokens) {
    final errors = <GrammarError>[];
    final negators = {"don't", "doesn't", "didn't", "won't", "wouldn't",
        "can't", "couldn't", "shouldn't", "isn't", "aren't", "wasn't",
        "weren't", 'not', 'never'};
    final negativeWords = {'no', 'nothing', 'nobody', 'nowhere', 'neither',
        'none', 'never'};

    for (int i = 0; i < tokens.length; i++) {
      if (negators.contains(tokens[i].normalized)) {
        // Look ahead within 5 words for another negative
        for (int j = i + 1; j < tokens.length && j <= i + 5; j++) {
          if (negativeWords.contains(tokens[j].normalized)) {
            errors.add(GrammarError(
              startOffset: tokens[i].startOffset,
              endOffset: tokens[j].endOffset,
              message:
                  'Double negative detected. In standard English, two negatives make a positive.',
              suggestion: null,
              category: 'grammar',
              matchedText: tokens
                  .sublist(i, j + 1)
                  .map((t) => t.raw)
                  .join(' '),
            ));
            break;
          }
        }
      }
    }
    return errors;
  }

  /// Basic subject-verb agreement checks.
  static List<GrammarError> _checkSubjectVerbAgreement(
      List<WordToken> tokens) {
    final errors = <GrammarError>[];
    final singularPronouns = {'he', 'she', 'it'};
    final pluralPronouns = {'they', 'we'};

    for (int i = 0; i < tokens.length - 1; i++) {
      final subject = tokens[i].normalized;
      final verb = tokens[i + 1].normalized;

      // "he/she/it are" → should be "is"
      if (singularPronouns.contains(subject) && verb == 'are') {
        errors.add(GrammarError(
          startOffset: tokens[i].startOffset,
          endOffset: tokens[i + 1].endOffset,
          message:
              'Subject-verb agreement: "$subject" requires "is", not "are".',
          suggestion: '${tokens[i].raw} is',
          category: 'grammar',
          matchedText: '${tokens[i].raw} ${tokens[i + 1].raw}',
        ));
      }

      // "he/she/it were" → should be "was" (unless subjunctive)
      if (singularPronouns.contains(subject) && verb == 'were') {
        errors.add(GrammarError(
          startOffset: tokens[i].startOffset,
          endOffset: tokens[i + 1].endOffset,
          message:
              'Subject-verb agreement: "$subject" typically requires "was".',
          suggestion: '${tokens[i].raw} was',
          category: 'grammar',
          matchedText: '${tokens[i].raw} ${tokens[i + 1].raw}',
        ));
      }

      // "they/we is" → should be "are"
      if (pluralPronouns.contains(subject) && verb == 'is') {
        errors.add(GrammarError(
          startOffset: tokens[i].startOffset,
          endOffset: tokens[i + 1].endOffset,
          message:
              'Subject-verb agreement: "$subject" requires "are", not "is".',
          suggestion: '${tokens[i].raw} are',
          category: 'grammar',
          matchedText: '${tokens[i].raw} ${tokens[i + 1].raw}',
        ));
      }

      // "they/we was" → should be "were"
      if (pluralPronouns.contains(subject) && verb == 'was') {
        errors.add(GrammarError(
          startOffset: tokens[i].startOffset,
          endOffset: tokens[i + 1].endOffset,
          message:
              'Subject-verb agreement: "$subject" requires "were", not "was".',
          suggestion: '${tokens[i].raw} were',
          category: 'grammar',
          matchedText: '${tokens[i].raw} ${tokens[i + 1].raw}',
        ));
      }

      // "I is" → should be "am"
      if (subject == 'i' && verb == 'is') {
        errors.add(GrammarError(
          startOffset: tokens[i].startOffset,
          endOffset: tokens[i + 1].endOffset,
          message: 'Subject-verb agreement: "I" requires "am", not "is".',
          suggestion: '${tokens[i].raw} am',
          category: 'grammar',
          matchedText: '${tokens[i].raw} ${tokens[i + 1].raw}',
        ));
      }

      // "I were" → should be "was" (in indicative)
      if (subject == 'i' && verb == 'are') {
        errors.add(GrammarError(
          startOffset: tokens[i].startOffset,
          endOffset: tokens[i + 1].endOffset,
          message: 'Subject-verb agreement: "I" requires "am", not "are".',
          suggestion: '${tokens[i].raw} am',
          category: 'grammar',
          matchedText: '${tokens[i].raw} ${tokens[i + 1].raw}',
        ));
      }
    }

    return errors;
  }

  /// Remove duplicate/overlapping errors, keeping the most specific one.
  static List<GrammarError> _deduplicateErrors(List<GrammarError> errors) {
    if (errors.length <= 1) return errors;

    // Sort by start offset
    errors.sort((a, b) => a.startOffset.compareTo(b.startOffset));

    final deduplicated = <GrammarError>[];
    for (final error in errors) {
      // Check if overlaps with the last added error
      if (deduplicated.isNotEmpty) {
        final last = deduplicated.last;
        if (error.startOffset < last.endOffset) {
          // Overlap — keep the shorter (more specific) one
          if ((error.endOffset - error.startOffset) <
              (last.endOffset - last.startOffset)) {
            deduplicated.removeLast();
            deduplicated.add(error);
          }
          continue;
        }
      }
      deduplicated.add(error);
    }

    return deduplicated;
  }
}

/// A grammar error with position and correction info.
class GrammarError {
  final int startOffset;
  final int endOffset;
  final String message;
  final String? suggestion;
  final String category;
  final String matchedText;

  const GrammarError({
    required this.startOffset,
    required this.endOffset,
    required this.message,
    this.suggestion,
    required this.category,
    required this.matchedText,
  });
}
