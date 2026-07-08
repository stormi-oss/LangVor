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

/// Result of comparing the user's translation against a real machine
/// translation of the source text, rather than a fixed word-pair lookup.
class OnlineCheckResult {
  final CheckSource source;
  final String? referenceTranslation;

  /// Content words present in the reference translation but not found
  /// (even fuzzily) in the user's text — surfaced as gentle suggestions,
  /// not hard errors, since the reference is just one possible phrasing.
  final List<String> missingContentWords;

  /// Rough content-word overlap between reference and user text (0–1),
  /// presented in the UI as an estimate, not an exact grade.
  final double similarity;

  final OnlineCheckFailureReason? failureReason;

  const OnlineCheckResult({
    required this.source,
    this.referenceTranslation,
    this.missingContentWords = const [],
    this.similarity = 0.0,
    this.failureReason,
  });

  bool get isAvailable => failureReason == null;
}

/// Compares a user's English translation against a live machine translation
/// of the Russian source (via [MyMemoryClient]) instead of a fixed
/// word-for-word dictionary — this is the "real translator" check.
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
        .toSet();
    final userWords =
        Tokenizer.tokenize(userEnglish).map((t) => t.normalized).toSet();

    final missing = <String>[];
    for (final word in refContentWords) {
      if (userWords.contains(word)) continue;
      // Fuzzy-match near forms (e.g. "go" vs "went") before flagging —
      // a single machine translation is only one valid phrasing.
      final hasCloseMatch = userWords
          .any((userWord) => SpellChecker.levenshtein(word, userWord) <= 2);
      if (!hasCloseMatch) missing.add(word);
    }

    final union = refContentWords.union(userWords);
    final intersection = refContentWords.intersection(userWords);
    final similarity =
        union.isEmpty ? 0.0 : intersection.length / union.length;

    return OnlineCheckResult(
      source: source,
      referenceTranslation: reference,
      missingContentWords: missing,
      similarity: similarity.clamp(0.0, 1.0),
    );
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
