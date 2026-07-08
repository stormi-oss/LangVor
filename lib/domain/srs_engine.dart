import 'dart:math';

/// SM-2 Spaced Repetition Algorithm implementation.
///
/// Based on the SuperMemo SM-2 algorithm by Piotr Wozniak.
/// Quality ratings:
///   0 — Complete blackout, no recall
///   1 — Incorrect, but upon seeing the answer, remembered
///   2 — Incorrect, but the answer seemed easy to recall
///   3 — Correct with serious difficulty
///   4 — Correct with some hesitation
///   5 — Perfect, instant recall
class SrsEngine {
  /// Minimum ease factor to prevent cards from becoming unreviewable.
  static const double _minEaseFactor = 1.3;

  /// Calculate next review parameters based on user's quality rating.
  ///
  /// Returns a [SrsResult] with updated interval, repetitions,
  /// ease factor, and next review date.
  static SrsResult calculate({
    required int quality,
    required int currentRepetitions,
    required int currentInterval,
    required double currentEaseFactor,
  }) {
    assert(quality >= 0 && quality <= 5, 'Quality must be between 0 and 5');

    int newRepetitions;
    int newInterval;
    double newEaseFactor;

    if (quality >= 3) {
      // Successful recall
      switch (currentRepetitions) {
        case 0:
          newInterval = 1; // First review: 1 day
          break;
        case 1:
          newInterval = 6; // Second review: 6 days
          break;
        default:
          newInterval = (currentInterval * currentEaseFactor).round();
      }
      newRepetitions = currentRepetitions + 1;
    } else {
      // Failed recall — reset
      newRepetitions = 0;
      newInterval = 1;
    }

    // Update ease factor using SM-2 formula
    newEaseFactor = currentEaseFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    newEaseFactor = max(newEaseFactor, _minEaseFactor);

    final nextReviewAt = DateTime.now().add(Duration(days: newInterval));

    return SrsResult(
      repetitions: newRepetitions,
      interval: newInterval,
      easeFactor: newEaseFactor,
      nextReviewAt: nextReviewAt,
    );
  }

  /// Get a human-readable label for the next review interval.
  static String intervalLabel(int intervalDays) {
    if (intervalDays == 0) return 'Now';
    if (intervalDays == 1) return '1 day';
    if (intervalDays < 7) return '$intervalDays days';
    if (intervalDays < 30) {
      final weeks = (intervalDays / 7).round();
      return '$weeks week${weeks > 1 ? 's' : ''}';
    }
    if (intervalDays < 365) {
      final months = (intervalDays / 30).round();
      return '$months month${months > 1 ? 's' : ''}';
    }
    final years = (intervalDays / 365).round();
    return '$years year${years > 1 ? 's' : ''}';
  }

  /// Quality rating labels for UI display.
  static const Map<int, String> qualityLabels = {
    0: 'Blackout',
    1: 'Wrong',
    2: 'Hard',
    3: 'Difficult',
    4: 'Good',
    5: 'Perfect',
  };
}

/// Result of an SRS calculation.
class SrsResult {
  final int repetitions;
  final int interval;
  final double easeFactor;
  final DateTime nextReviewAt;

  const SrsResult({
    required this.repetitions,
    required this.interval,
    required this.easeFactor,
    required this.nextReviewAt,
  });
}
