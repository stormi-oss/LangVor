import '../nlp/levenshtein.dart';
import '../nlp/spell_checker.dart';
import '../nlp/tokenizer.dart';
import 'mymemory_client.dart';
import 'translation_cache.dart';

/// Where an [OnlineCheckResult] came from.
enum CheckSource { online, cache, offlineFallback }

/// Why an online check could not be completed — always recoverable by
/// falling back to the offline analyzer.
enum OnlineCheckFailureReason {
  disabled,
  network,
  timeout,
  quotaExceeded,
  textTooLong,
  malformedResponse,
}

/// Coarse quality bands for a translation, mirroring how a human reviewer
/// would summarize it.
enum TranslationGrade { exact, good, partial, poor }

extension TranslationGradeInfo on TranslationGrade {
  String get label => switch (this) {
        TranslationGrade.exact => 'Excellent match',
        TranslationGrade.good => 'Good — minor differences',
        TranslationGrade.partial => 'Partially correct',
        TranslationGrade.poor => 'Needs work',
      };
}

/// Per-source-word assessment used to give detailed, word-level feedback.
class WordAssessment {
  final String expected; // word from the reference translation
  final MatchLevel level;
  final String? userWord; // the user's word that matched, if any

  const WordAssessment({
    required this.expected,
    required this.level,
    this.userWord,
  });
}

enum MatchLevel { exact, synonymOrFuzzy, missing }

/// Result of comparing the user's English translation against a live machine
/// translation of the Russian source — a multi-level, graded assessment.
class OnlineCheckResult {
  final CheckSource source;
  final String? referenceTranslation;

  /// 0–1 semantic overlap score used to blend into the overall score.
  final double similarity;

  /// The coarse quality band derived from [similarity] and coverage.
  final TranslationGrade grade;

  /// Word-level breakdown against the reference translation.
  final List<WordAssessment> wordAssessments;

  /// Short human-readable feedback lines (what's good / what to fix).
  final List<String> feedback;

  final OnlineCheckFailureReason? failureReason;

  const OnlineCheckResult({
    required this.source,
    this.referenceTranslation,
    this.similarity = 0.0,
    this.grade = TranslationGrade.poor,
    this.wordAssessments = const [],
    this.feedback = const [],
    this.failureReason,
  });

  bool get isAvailable => failureReason == null;

  List<String> get missingContentWords => wordAssessments
      .where((a) => a.level == MatchLevel.missing)
      .map((a) => a.expected)
      .toList();
}

/// Compares a user's English translation against a live machine translation
/// of the Russian source (via [MyMemoryClient]) and grades it on multiple
/// levels — this is the "real translator" check.
class OnlineTranslationChecker {
  final MyMemoryClient _client;
  final TranslationCache _cache;
  static const _langpair = 'ru|en';

  OnlineTranslationChecker({MyMemoryClient? client, TranslationCache? cache})
      : _client = client ?? MyMemoryClient(),
        _cache = cache ?? TranslationCache();

  Future<OnlineCheckResult> check({
    required String sourceRussian,
    required String userEnglish,
    String? contactEmail,
  }) async {
    if (sourceRussian.trim().isEmpty || userEnglish.trim().isEmpty) {
      return const OnlineCheckResult(
        source: CheckSource.offlineFallback,
        failureReason: OnlineCheckFailureReason.disabled,
      );
    }

    String reference;
    CheckSource source;

    final cached = await _cache.get(sourceRussian, _langpair);
    if (cached != null && cached.isNotEmpty) {
      reference = cached;
      source = CheckSource.cache;
    } else {
      try {
        reference = await _client.translate(
          sourceRussian,
          langpair: _langpair,
          contactEmail: contactEmail,
        );
        if (reference.trim().isEmpty) {
          return const OnlineCheckResult(
            source: CheckSource.offlineFallback,
            failureReason: OnlineCheckFailureReason.malformedResponse,
          );
        }
        await _cache.put(sourceRussian, _langpair, reference);
        source = CheckSource.online;
      } on MyMemoryException catch (e) {
        return OnlineCheckResult(
          source: CheckSource.offlineFallback,
          failureReason: _mapFailure(e.reason),
        );
      } catch (_) {
        return const OnlineCheckResult(
          source: CheckSource.offlineFallback,
          failureReason: OnlineCheckFailureReason.network,
        );
      }
    }

    return _compare(reference, userEnglish, source);
  }

  OnlineCheckResult _compare(
    String reference,
    String userEnglish,
    CheckSource source,
  ) {
    final refContentWords = Tokenizer.tokenize(reference)
        .map((t) => t.normalized)
        .where((w) => w.length > 2 && !SpellChecker.stopWords.contains(w))
        .toList();
    final userWords =
        Tokenizer.tokenize(userEnglish).map((t) => t.normalized).toList();
    final userSet = userWords.toSet();

    // Word-level grading: exact hit, fuzzy/near hit, or missing.
    final assessments = <WordAssessment>[];
    int exact = 0, fuzzy = 0, missing = 0;
    final seen = <String>{};
    for (final word in refContentWords) {
      if (!seen.add(word)) continue; // dedupe
      if (userSet.contains(word)) {
        exact++;
        assessments.add(WordAssessment(
            expected: word, level: MatchLevel.exact, userWord: word));
        continue;
      }
      String? near;
      for (final u in userWords) {
        if (levenshteinDistance(word, u) <= 2) {
          near = u;
          break;
        }
      }
      if (near != null) {
        fuzzy++;
        assessments.add(WordAssessment(
            expected: word, level: MatchLevel.synonymOrFuzzy, userWord: near));
      } else {
        missing++;
        assessments.add(
            WordAssessment(expected: word, level: MatchLevel.missing));
      }
    }

    final totalContent = exact + fuzzy + missing;
    // Weighted coverage: exact = full credit, fuzzy = partial credit.
    final coverage = totalContent == 0
        ? 1.0
        : (exact + fuzzy * 0.6) / totalContent;

    // Jaccard token overlap as a second, holistic signal.
    final refSet = refContentWords.toSet();
    final union = refSet.union(userSet);
    final jaccard =
        union.isEmpty ? 0.0 : refSet.intersection(userSet).length / union.length;

    final similarity = (coverage * 0.7 + jaccard * 0.3).clamp(0.0, 1.0);
    final grade = _grade(similarity, missing, totalContent);
    final feedback =
        _buildFeedback(grade, assessments, similarity);

    return OnlineCheckResult(
      source: source,
      referenceTranslation: reference,
      similarity: similarity,
      grade: grade,
      wordAssessments: assessments,
      feedback: feedback,
    );
  }

  TranslationGrade _grade(double similarity, int missing, int total) {
    if (similarity >= 0.9 || (total > 0 && missing == 0 && similarity >= 0.8)) {
      return TranslationGrade.exact;
    }
    if (similarity >= 0.7) return TranslationGrade.good;
    if (similarity >= 0.4) return TranslationGrade.partial;
    return TranslationGrade.poor;
  }

  List<String> _buildFeedback(
    TranslationGrade grade,
    List<WordAssessment> assessments,
    double similarity,
  ) {
    final lines = <String>[];
    final missing =
        assessments.where((a) => a.level == MatchLevel.missing).toList();
    final fuzzy = assessments
        .where((a) => a.level == MatchLevel.synonymOrFuzzy)
        .toList();

    switch (grade) {
      case TranslationGrade.exact:
        lines.add('Your translation closely matches the reference. 🎉');
        break;
      case TranslationGrade.good:
        lines.add('Solid translation — it captures the meaning well.');
        break;
      case TranslationGrade.partial:
        lines.add('You got part of the meaning across, but some key '
            'words are missing or off.');
        break;
      case TranslationGrade.poor:
        lines.add('This differs a lot from the reference — compare it '
            'below and try again.');
        break;
    }

    if (missing.isNotEmpty) {
      final words = missing.take(6).map((a) => a.expected).join(', ');
      lines.add('Consider including: $words'
          '${missing.length > 6 ? '…' : ''}.');
    }
    if (fuzzy.isNotEmpty && grade != TranslationGrade.exact) {
      final pairs = fuzzy
          .take(4)
          .map((a) => '"${a.userWord}" → "${a.expected}"')
          .join(', ');
      lines.add('Close, but check word choice: $pairs.');
    }
    return lines;
  }

  OnlineCheckFailureReason _mapFailure(MyMemoryFailure reason) {
    switch (reason) {
      case MyMemoryFailure.network:
        return OnlineCheckFailureReason.network;
      case MyMemoryFailure.timeout:
        return OnlineCheckFailureReason.timeout;
      case MyMemoryFailure.quotaExceeded:
        return OnlineCheckFailureReason.quotaExceeded;
      case MyMemoryFailure.textTooLong:
        return OnlineCheckFailureReason.textTooLong;
      case MyMemoryFailure.malformedResponse:
        return OnlineCheckFailureReason.malformedResponse;
    }
  }

  void dispose() => _client.dispose();
}
