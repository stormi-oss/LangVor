/// Shared spacing scale — keeps padding/margins consistent across screens
/// instead of each widget picking its own ad hoc EdgeInsets values.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Standard corner radius for cards, inputs, and chips.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
}
