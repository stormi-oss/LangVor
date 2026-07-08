/// Utility to split Russian text into individual sentences for translation.
///
/// Handles common Russian punctuation patterns including:
/// - Standard sentence endings (. ! ?)
/// - Ellipsis (...)
/// - Quoted dialogue with dashes (—)
/// - Multi-line poetry/verse splitting
class TextSplitter {
  /// Split a block of Russian text into individual sentences.
  ///
  /// Returns a list of trimmed, non-empty sentences preserving
  /// original punctuation.
  static List<String> splitIntoSentences(String text) {
    if (text.trim().isEmpty) return [];

    // Normalize line breaks
    String normalized = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    final List<String> sentences = [];

    // Split by sentence-ending punctuation, keeping the punctuation
    // Regex handles: . ! ? ... and combinations like ?! !?
    // Lookbehind for sentence enders, lookahead for whitespace or end
    final sentencePattern = RegExp(
      r'[^.!?…]*[.!?…]+(?:\s|$)|[^.!?…]+$',
      multiLine: true,
    );

    // First, split by paragraph breaks (double newlines)
    final paragraphs = normalized.split(RegExp(r'\n\s*\n'));

    for (final paragraph in paragraphs) {
      if (paragraph.trim().isEmpty) continue;

      // Check if this looks like poetry (short lines)
      final lines = paragraph.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final avgLineLength =
          lines.fold<int>(0, (sum, l) => sum + l.trim().length) /
              (lines.isEmpty ? 1 : lines.length);

      if (lines.length > 1 && avgLineLength < 60) {
        // Treat as poetry/verse — each line is a segment
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty) {
            sentences.add(trimmed);
          }
        }
      } else {
        // Normal prose — split by sentence boundaries
        final matches = sentencePattern.allMatches(paragraph.replaceAll('\n', ' '));
        for (final match in matches) {
          final sentence = match.group(0)?.trim();
          if (sentence != null && sentence.isNotEmpty) {
            sentences.add(sentence);
          }
        }

        // Fallback: if regex found nothing, add the whole paragraph
        if (matches.isEmpty && paragraph.trim().isNotEmpty) {
          sentences.add(paragraph.trim());
        }
      }
    }

    return sentences;
  }

  /// Generate a short title from the first sentence of the text.
  static String generateTitle(String text, {int maxLength = 50}) {
    final sentences = splitIntoSentences(text);
    if (sentences.isEmpty) return 'Untitled';

    final first = sentences.first;
    if (first.length <= maxLength) return first;
    return '${first.substring(0, maxLength - 3)}...';
  }

  /// Count total words in a text.
  static int countWords(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
  }
}
