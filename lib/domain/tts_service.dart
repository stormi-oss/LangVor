import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around flutter_tts for speaking English vocabulary words.
///
/// All calls are best-effort: if the platform has no English voice or TTS
/// fails, methods return quietly instead of throwing so the UI never breaks.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {
      // ignore — speak() will simply be a no-op
    }
    _configured = true;
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _ensureConfigured();
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // ignore
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
