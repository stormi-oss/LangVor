import 'english_wordlist.dart';
import 'levenshtein.dart';
import 'tokenizer.dart';

/// Wordlist-based spell checker with Levenshtein distance suggestions.
///
/// Looks up each token in [EnglishWordlist] — a monolingual English
/// vocabulary, independent of the RU-EN [DictionaryEntries] translation
/// pairs table (which is far too small to double as a spelling reference).
class SpellChecker {
  /// Common English function words — reused elsewhere to filter content
  /// words out of comparisons (e.g. [OnlineTranslationChecker]).
  static Set<String> get stopWords => _stopWords;

  /// Common English words that should never be flagged as misspelled.
  /// These are function words, pronouns, determiners, etc. that may not
  /// appear in a content-word dictionary.
  static final Set<String> _stopWords = {
    // Articles & determiners
    'a', 'an', 'the', 'this', 'that', 'these', 'those',
    'my', 'your', 'his', 'her', 'its', 'our', 'their',
    'some', 'any', 'no', 'every', 'each', 'all', 'both',
    'few', 'many', 'much', 'more', 'most', 'other', 'another',
    // Pronouns
    'i', 'me', 'we', 'us', 'you', 'he', 'him', 'she',
    'it', 'they', 'them', 'myself', 'yourself', 'himself',
    'herself', 'itself', 'ourselves', 'themselves',
    'who', 'whom', 'whose', 'which', 'what', 'where',
    'when', 'why', 'how',
    // Prepositions
    'in', 'on', 'at', 'to', 'for', 'with', 'by', 'from',
    'up', 'out', 'off', 'of', 'into', 'over', 'under',
    'about', 'above', 'below', 'between', 'through', 'during',
    'before', 'after', 'against', 'among', 'around', 'along',
    'across', 'behind', 'beyond', 'within', 'without',
    'upon', 'toward', 'towards', 'until', 'since', 'beside',
    'besides', 'despite', 'near', 'past',
    // Conjunctions
    'and', 'but', 'or', 'nor', 'so', 'yet',
    'because', 'although', 'though', 'while', 'if', 'unless',
    'than', 'whether', 'either', 'neither',
    // Common verbs
    'is', 'am', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'having',
    'do', 'does', 'did', 'doing', 'done',
    'will', 'would', 'shall', 'should',
    'can', 'could', 'may', 'might', 'must',
    'get', 'got', 'go', 'went', 'gone', 'going',
    'come', 'came', 'say', 'said', 'make', 'made',
    'take', 'took', 'taken', 'give', 'gave', 'given',
    'know', 'knew', 'known', 'think', 'thought',
    'see', 'saw', 'seen', 'want', 'wanted',
    'use', 'used', 'find', 'found',
    'tell', 'told', 'ask', 'asked',
    'work', 'worked', 'seem', 'seemed',
    'feel', 'felt', 'try', 'tried',
    'leave', 'left', 'call', 'called',
    'need', 'needed', 'keep', 'kept',
    'let', 'begin', 'began', 'begun',
    'show', 'showed', 'shown',
    'hear', 'heard', 'play', 'played',
    'run', 'ran', 'move', 'moved',
    'live', 'lived', 'believe', 'believed',
    'bring', 'brought', 'happen', 'happened',
    'write', 'wrote', 'written',
    'sit', 'sat', 'stand', 'stood',
    'lose', 'lost', 'pay', 'paid',
    'meet', 'met', 'include', 'included',
    'continue', 'continued', 'set',
    'learn', 'learned', 'change', 'changed',
    'lead', 'led', 'understand', 'understood',
    'watch', 'watched', 'follow', 'followed',
    'stop', 'stopped', 'create', 'created',
    'speak', 'spoke', 'spoken',
    'read', 'allow', 'allowed',
    'add', 'added', 'spend', 'spent',
    'grow', 'grew', 'grown',
    'open', 'opened', 'walk', 'walked',
    'win', 'won', 'offer', 'offered',
    'remember', 'remembered',
    'love', 'loved', 'consider', 'considered',
    'appear', 'appeared', 'buy', 'bought',
    'wait', 'waited', 'serve', 'served',
    'die', 'died', 'send', 'sent',
    'expect', 'expected', 'build', 'built',
    'stay', 'stayed', 'fall', 'fell', 'fallen',
    'cut', 'reach', 'reached',
    'kill', 'killed', 'remain', 'remained',
    // Adverbs
    'not', 'also', 'very', 'often', 'however', 'too',
    'usually', 'really', 'already', 'always', 'never',
    'sometimes', 'still', 'just', 'now', 'then',
    'here', 'there', 'well', 'only', 'even',
    'back', 'again', 'away', 'quite', 'rather',
    'almost', 'enough', 'ever', 'soon', 'perhaps',
    'maybe', 'else', 'instead', 'anyway',
    // Other common words
    'yes', 'like', 'as',
    'own', 'same', 'such',
    'new', 'old', 'big', 'small', 'long', 'great',
    'good', 'bad', 'right', 'wrong', 'best', 'worst',
    'first', 'last', 'next', 'able',
    'little', 'far', 'high', 'low',
    'man', 'men', 'woman', 'women', 'child', 'children',
    'world', 'life', 'hand', 'part', 'place',
    'case', 'week', 'company', 'system', 'program',
    'question', 'home', 'government', 'number',
    'night', 'point', 'head', 'house', 'story',
    'fact', 'thing', 'eye', 'game', 'end',
    'line', 'city', 'time', 'day', 'year',
    'way', 'people', 'water', 'room', 'mother',
    'area', 'money', 'word', 'family', 'side',
    'kind', 'door', 'name', 'power', 'friend',
    'car', 'book', 'food', 'face', 'state',
    'boy', 'girl', 'lot', 'group', 'school',
    'country', 'problem', 'job', 'war',
    'ago', 'oh', 'ok', 'okay',
  };

  /// Check spelling of all tokens against [EnglishWordlist].
  /// Returns a list of [SpellError]s for misspelled words. If the wordlist
  /// hasn't finished loading yet, returns no errors rather than false
  /// positives.
  static Future<List<SpellError>> check(List<WordToken> tokens) async {
    final errors = <SpellError>[];
    final wordlist = EnglishWordlist.instance;
    if (!wordlist.isLoaded) return errors;

    // Filter to English tokens only (no Cyrillic)
    final englishTokens = tokens.where((t) =>
        RegExp(r'^[a-z]', caseSensitive: false).hasMatch(t.raw)).toList();

    for (final token in englishTokens) {
      if (_stopWords.contains(token.normalized)) continue;
      if (token.normalized.length <= 1) continue;
      if (wordlist.contains(token.normalized)) continue;

      errors.add(SpellError(
        token: token,
        suggestions: wordlist.near(token.normalized),
      ));
    }

    return errors;
  }

  /// Compute Levenshtein distance between two strings.
  static int levenshtein(String a, String b) => levenshteinDistance(a, b);
}

/// A spelling error with position and suggestions.
class SpellError {
  final WordToken token;
  final List<String> suggestions;

  const SpellError({
    required this.token,
    required this.suggestions,
  });
}
