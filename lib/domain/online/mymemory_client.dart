import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Reasons a MyMemory request can fail — all recoverable by falling back
/// to the offline analyzer, never meant to crash the app.
enum MyMemoryFailure {
  network,
  timeout,
  quotaExceeded,
  textTooLong,
  malformedResponse,
}

class MyMemoryException implements Exception {
  final MyMemoryFailure reason;
  final String message;
  const MyMemoryException(this.reason, this.message);

  @override
  String toString() => 'MyMemoryException($reason): $message';
}

/// Thin client for the free, keyless MyMemory Translation API
/// (https://mymemory.translated.net/doc/spec.php).
///
/// MyMemory enforces a practical ~500-character limit per request and
/// signals failures (quota exhausted, query too long) via a non-200
/// `responseStatus` *and* by embedding a warning string inside
/// `responseData.translatedText` — both are checked, since relying on
/// the HTTP status code alone is not sufficient in practice.
class MyMemoryClient {
  static const _endpoint = 'https://api.mymemory.translated.net/get';
  static const _maxCharsPerSegment = 480;
  static const _warningMarkers = [
    'MYMEMORY WARNING',
    'QUERY LENGTH LIMIT EXCEEDED',
    'INVALID LANGUAGE',
    'AMOUNT OF WORDS LIMIT EXCEEDED',
    'IS AN INVALID TARGET LANGUAGE',
  ];

  final http.Client _httpClient;

  MyMemoryClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Translates [text], transparently splitting it into segments that fit
  /// MyMemory's per-request length limit and rejoining the results.
  Future<String> translate(
    String text, {
    String langpair = 'ru|en',
    String? contactEmail,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

    final segments = _splitIntoSegments(trimmed, _maxCharsPerSegment);
    final results = <String>[];
    for (final segment in segments) {
      results.add(await _translateSegment(segment, langpair, contactEmail));
    }
    return results.join(' ').trim();
  }

  Future<String> _translateSegment(
    String segment,
    String langpair,
    String? contactEmail,
  ) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'q': segment,
      'langpair': langpair,
      if (contactEmail != null && contactEmail.trim().isNotEmpty)
        'de': contactEmail.trim(),
    });

    late final http.Response response;
    try {
      response = await _httpClient.get(uri).timeout(const Duration(seconds: 8));
    } on TimeoutException {
      throw const MyMemoryException(
          MyMemoryFailure.timeout, 'MyMemory request timed out');
    } catch (e) {
      throw MyMemoryException(MyMemoryFailure.network, e.toString());
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw MyMemoryException(
          MyMemoryFailure.malformedResponse, 'Invalid JSON: $e');
    }

    final translatedText =
        (body['responseData'] as Map?)?['translatedText'] as String? ?? '';
    final statusRaw = body['responseStatus'];
    final statusCode = statusRaw is int
        ? statusRaw
        : int.tryParse('$statusRaw') ?? response.statusCode;
    final quotaFinished = body['quotaFinished'] == true;
    final upperText = translatedText.toUpperCase();
    final looksLikeWarning =
        _warningMarkers.any((marker) => upperText.contains(marker));

    if (statusCode != 200 || quotaFinished || looksLikeWarning) {
      final details =
          body['responseDetails']?.toString() ?? translatedText;
      final reason = quotaFinished || upperText.contains('MYMEMORY WARNING')
          ? MyMemoryFailure.quotaExceeded
          : upperText.contains('QUERY LENGTH')
              ? MyMemoryFailure.textTooLong
              : MyMemoryFailure.malformedResponse;
      throw MyMemoryException(reason, details);
    }

    return translatedText;
  }

  /// Splits [text] into chunks no longer than [maxChars], preferring
  /// sentence boundaries and hard-wrapping any single sentence that's
  /// still too long on its own.
  List<String> _splitIntoSegments(String text, int maxChars) {
    if (text.length <= maxChars) return [text];

    final sentences = text.split(RegExp(r'(?<=[.!?…])\s+'));
    final segments = <String>[];
    var current = StringBuffer();

    void flush() {
      final segment = current.toString().trim();
      if (segment.isNotEmpty) segments.add(segment);
      current = StringBuffer();
    }

    for (final sentence in sentences) {
      if (sentence.length > maxChars) {
        flush();
        for (var i = 0; i < sentence.length; i += maxChars) {
          segments.add(sentence.substring(i, min(i + maxChars, sentence.length)));
        }
        continue;
      }
      if (current.length + sentence.length + 1 > maxChars) flush();
      current.write('$sentence ');
    }
    flush();

    return segments.isEmpty ? [text.substring(0, maxChars)] : segments;
  }

  void dispose() => _httpClient.close();
}
