import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bounded cache of MyMemory results keyed by source-paragraph text, so the
/// same Russian paragraph isn't re-translated on every keystroke of the
/// user's English translation. Backed by [SharedPreferences] as a small
/// disposable JSON map — not a Drift table, since this data is safe to lose.
class TranslationCache {
  static const _prefsKey = 'online_translation_cache_v1';
  static const _maxEntries = 200;

  Future<String?> get(String sourceText, String langpair) async {
    final map = await _read();
    return map[_key(sourceText, langpair)] as String?;
  }

  Future<void> put(String sourceText, String langpair, String translation) async {
    final map = await _read();
    final key = _key(sourceText, langpair);
    map.remove(key); // reinsert at the end to approximate LRU eviction
    map[key] = translation;
    while (map.length > _maxEntries) {
      map.remove(map.keys.first);
    }
    await _write(map);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<Map<String, dynamic>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _write(Map<String, dynamic> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  String _key(String sourceText, String langpair) {
    final normalized = sourceText.trim().toLowerCase();
    return sha1.convert(utf8.encode('$langpair::$normalized')).toString();
  }
}
