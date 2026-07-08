import 'package:flutter/services.dart' show rootBundle;
import 'levenshtein.dart';

/// In-memory English wordlist for offline spell-checking, decoupled from
/// the RU-EN [DictionaryEntries] table (which only holds curated
/// translation pairs, not a full monolingual vocabulary).
///
/// Sourced from assets/dictionary/en_words.txt — see
/// assets/dictionary/en_words.LICENSE.txt for provenance.
class EnglishWordlist {
  EnglishWordlist._();
  static final EnglishWordlist instance = EnglishWordlist._();

  Set<String>? _words;

  /// Maps first letter -> words starting with it, for fast fuzzy-suggestion
  /// candidate generation without scanning the whole set.
  Map<String, List<String>>? _byFirstLetter;

  bool get isLoaded => _words != null;

  Future<void> load() async {
    if (_words != null) return;
    final raw = await rootBundle.loadString('assets/dictionary/en_words.txt');
    final words = raw
        .split('\n')
        .map((w) => w.trim().toLowerCase())
        .where((w) => w.isNotEmpty)
        .toSet();

    final byFirstLetter = <String, List<String>>{};
    for (final word in words) {
      byFirstLetter.putIfAbsent(word[0], () => []).add(word);
    }

    _words = words;
    _byFirstLetter = byFirstLetter;
  }

  bool contains(String word) => _words?.contains(word.toLowerCase()) ?? false;

  /// Words within Levenshtein distance <= [maxDistance] of [word],
  /// closest first, capped at [limit]. Ties are broken by shorter length
  /// (a cheap proxy for commonness — this wordlist has no frequency data,
  /// and shorter words tend to be the more everyday ones) then
  /// alphabetically.
  List<String> near(String word, {int maxDistance = 2, int limit = 5}) {
    final byFirstLetter = _byFirstLetter;
    if (byFirstLetter == null || word.isEmpty) return const [];

    final candidates = byFirstLetter[word.toLowerCase()[0]] ?? const [];
    final scored = <MapEntry<String, int>>[];
    for (final candidate in candidates) {
      final dist = levenshteinDistance(word.toLowerCase(), candidate);
      if (dist > 0 && dist <= maxDistance) {
        scored.add(MapEntry(candidate, dist));
      }
    }
    scored.sort((a, b) {
      final cmp = a.value.compareTo(b.value);
      if (cmp != 0) return cmp;
      final lengthCmp = a.key.length.compareTo(b.key.length);
      return lengthCmp != 0 ? lengthCmp : a.key.compareTo(b.key);
    });
    return scored.take(limit).map((e) => e.key).toList();
  }
}
