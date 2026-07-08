/// Word tokenizer with offset tracking, normalization, N-gram extraction,
/// and suffix-based POS tagging for the offline NLP engine.
library;

/// A single word token with position information.
class WordToken {
  final String raw;           // original text
  final String normalized;    // lowercase, stripped punctuation
  final int startOffset;      // char offset in source string
  final int endOffset;        // char offset end (exclusive)
  final String? posTag;       // suffix-based POS guess

  const WordToken({
    required this.raw,
    required this.normalized,
    required this.startOffset,
    required this.endOffset,
    this.posTag,
  });

  @override
  String toString() => 'Token($raw @$startOffset-$endOffset ${posTag ?? ''})';
}

/// N-gram (bigram, trigram) with position information.
class NGram {
  final List<WordToken> tokens;
  final String joined; // normalized joined text

  NGram(this.tokens) : joined = tokens.map((t) => t.normalized).join(' ');

  int get startOffset => tokens.first.startOffset;
  int get endOffset => tokens.last.endOffset;
}

/// Tokenizer for English and Russian text with offset tracking.
class Tokenizer {
  // Word boundary regex — matches words including apostrophes/hyphens
  static final _wordRegex = RegExp(r"[a-zA-Zа-яА-ЯёЁ][a-zA-Zа-яА-ЯёЁ'\-]*");

  /// Tokenize text into word tokens with offset tracking.
  static List<WordToken> tokenize(String text) {
    final tokens = <WordToken>[];
    for (final match in _wordRegex.allMatches(text)) {
      final raw = match.group(0)!;
      final normalized = _normalize(raw);
      if (normalized.isEmpty) continue;

      tokens.add(WordToken(
        raw: raw,
        normalized: normalized,
        startOffset: match.start,
        endOffset: match.end,
        posTag: _guessPos(normalized),
      ));
    }
    return tokens;
  }

  /// Tokenize and return only normalized word strings.
  static List<String> tokenizeToStrings(String text) {
    return tokenize(text).map((t) => t.normalized).toList();
  }

  /// Extract bigrams from token list.
  static List<NGram> extractBigrams(List<WordToken> tokens) {
    final bigrams = <NGram>[];
    for (int i = 0; i < tokens.length - 1; i++) {
      bigrams.add(NGram([tokens[i], tokens[i + 1]]));
    }
    return bigrams;
  }

  /// Extract trigrams from token list.
  static List<NGram> extractTrigrams(List<WordToken> tokens) {
    final trigrams = <NGram>[];
    for (int i = 0; i < tokens.length - 2; i++) {
      trigrams.add(NGram([tokens[i], tokens[i + 1], tokens[i + 2]]));
    }
    return trigrams;
  }

  /// Normalize: lowercase, strip leading/trailing punctuation.
  static String _normalize(String word) {
    return word.toLowerCase().replaceAll(RegExp(r"^['\-]+|['\-]+$"), '');
  }

  /// Suffix-based POS tagging (heuristic).
  static String? _guessPos(String normalized) {
    if (normalized.length < 3) return null;

    // Gerund / present participle
    if (normalized.endsWith('ing')) return 'VBG';
    // Past tense / past participle
    if (normalized.endsWith('ed')) return 'VBD';
    // Adverb
    if (normalized.endsWith('ly')) return 'RB';
    // Noun (abstract)
    if (normalized.endsWith('tion') || normalized.endsWith('sion')) return 'NN';
    if (normalized.endsWith('ment')) return 'NN';
    if (normalized.endsWith('ness')) return 'NN';
    if (normalized.endsWith('ity')) return 'NN';
    // Adjective
    if (normalized.endsWith('ful')) return 'JJ';
    if (normalized.endsWith('less')) return 'JJ';
    if (normalized.endsWith('ous')) return 'JJ';
    if (normalized.endsWith('ive')) return 'JJ';
    if (normalized.endsWith('able') || normalized.endsWith('ible')) return 'JJ';
    // Superlative
    if (normalized.endsWith('est')) return 'JJS';
    // Comparative
    if (normalized.endsWith('er') && normalized.length > 4) return 'JJR';
    // Plural / 3rd person singular
    if (normalized.endsWith('s') && !normalized.endsWith('ss')) return 'NNS';

    return null;
  }

  /// Split text into sentences (basic heuristic).
  static List<String> splitSentences(String text) {
    final sentenceRegex = RegExp(r'[^.!?]+[.!?]+\s*');
    final matches = sentenceRegex.allMatches(text.trim());
    if (matches.isEmpty) return [text.trim()];
    return matches.map((m) => m.group(0)!.trim()).toList();
  }
}
