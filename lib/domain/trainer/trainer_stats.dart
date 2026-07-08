import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// One completed translation-trainer run, stored for the local leaderboard.
class TrainerResult {
  final String title;
  final String difficulty;
  final double accuracy; // 0–1
  final int sentences;
  final int correctSentences;
  final int durationSeconds;
  final DateTime date;

  const TrainerResult({
    required this.title,
    required this.difficulty,
    required this.accuracy,
    required this.sentences,
    required this.correctSentences,
    required this.durationSeconds,
    required this.date,
  });

  /// Composite ranking score: accuracy dominates, speed breaks ties.
  double get rankScore =>
      accuracy * 1000 - (durationSeconds / (sentences.clamp(1, 999)));

  Map<String, dynamic> toJson() => {
        'title': title,
        'difficulty': difficulty,
        'accuracy': accuracy,
        'sentences': sentences,
        'correctSentences': correctSentences,
        'durationSeconds': durationSeconds,
        'date': date.toIso8601String(),
      };

  static TrainerResult fromJson(Map<String, dynamic> j) => TrainerResult(
        title: j['title'] as String? ?? '',
        difficulty: j['difficulty'] as String? ?? 'Medium',
        accuracy: (j['accuracy'] as num?)?.toDouble() ?? 0,
        sentences: j['sentences'] as int? ?? 0,
        correctSentences: j['correctSentences'] as int? ?? 0,
        durationSeconds: j['durationSeconds'] as int? ?? 0,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
      );
}

/// A trainer achievement badge.
class Badge {
  final String id;
  final String label;
  final String emoji;
  const Badge(this.id, this.label, this.emoji);
}

class Badges {
  static const perfect = Badge('perfect', 'Flawless', '💎');
  static const fast = Badge('fast', 'Speed Demon', '⚡');
  static const streak5 = Badge('streak5', '5 in a row', '🔥');
  static const marathon = Badge('marathon', 'Marathoner', '🏃');
  static const first = Badge('first', 'First Run', '🌱');

  static const all = [perfect, fast, streak5, marathon, first];
  static Badge? byId(String id) =>
      all.where((b) => b.id == id).cast<Badge?>().firstOrNull;
}

/// Local (device-only) persistence for the trainer leaderboard and earned
/// badges — there is no backend, so "leaderboard" means personal bests.
class TrainerStore {
  static const _kLeaderboard = 'trainer_leaderboard_v1';
  static const _kBadges = 'trainer_badges_v1';
  static const _maxEntries = 20;

  Future<List<TrainerResult>> leaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLeaderboard);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => TrainerResult.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.rankScore.compareTo(a.rankScore));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> addResult(TrainerResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await leaderboard();
    list.add(result);
    list.sort((a, b) => b.rankScore.compareTo(a.rankScore));
    final trimmed = list.take(_maxEntries).toList();
    await prefs.setString(
        _kLeaderboard, jsonEncode(trimmed.map((r) => r.toJson()).toList()));
  }

  Future<Set<String>> earnedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kBadges) ?? const []).toSet();
  }

  Future<void> awardBadges(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_kBadges) ?? const []).toSet();
    current.addAll(ids);
    await prefs.setStringList(_kBadges, current.toList());
  }
}
