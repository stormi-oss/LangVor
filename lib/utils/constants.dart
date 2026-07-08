/// Application-wide constants.
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'LangVor';

  /// Version
  static const String version = '1.0.0';

  /// Default SRS ease factor for new cards
  static const double defaultEaseFactor = 2.5;

  /// Minimum ease factor (prevents cards from becoming unreviewable)
  static const double minEaseFactor = 1.3;

  /// Maximum words shown in dictionary lookup
  static const int maxDictionaryResults = 20;

  /// Debounce duration for text input (ms)
  static const int inputDebounceMs = 300;

  /// Breakpoints
  static const double desktopBreakpoint = 900.0;
  static const double tabletBreakpoint = 600.0;

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
