/// Levenshtein edit distance between two strings — shared by
/// [EnglishWordlist], [SpellChecker], and [OnlineTranslationChecker] for
/// fuzzy word matching.
int levenshteinDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  // Optimization: if length difference is large, skip exact computation.
  if ((a.length - b.length).abs() > 3) return 4;

  final m = a.length;
  final n = b.length;

  var prev = List<int>.generate(n + 1, (i) => i);
  var curr = List<int>.filled(n + 1, 0);

  for (int i = 1; i <= m; i++) {
    curr[0] = i;
    for (int j = 1; j <= n; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      curr[j] = [
        prev[j] + 1, // deletion
        curr[j - 1] + 1, // insertion
        prev[j - 1] + cost, // substitution
      ].reduce((x, y) => x < y ? x : y);
    }
    final temp = prev;
    prev = curr;
    curr = temp;
  }

  return prev[n];
}
