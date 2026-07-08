import 'package:flutter/material.dart';

/// LangVor color palette — deep black + bordo (burgundy) accents,
/// designed for a modern, corporate feel in both light and dark themes.
class AppColors {
  AppColors._();

  // ── Primary Brand Colors (bordo / burgundy) ──
  static const Color primary = Color(0xFFC1345D); // main bordo, reads on both
  static const Color primaryLight = Color(0xFFE8A0B0); // pastel bordo
  static const Color primaryDark = Color(0xFF8B1538); // deep bordo

  // ── Accent (bright bordo for highlights) ──
  static const Color accent = Color(0xFFD4324F);
  static const Color accentLight = Color(0xFFE8677F);
  static const Color accentDark = Color(0xFF9A1E45);

  // ── Semantic Colors ──
  static const Color success = Color(0xFF2EA86A);
  static const Color warning = Color(0xFFE0A73C);
  static const Color error = Color(0xFFE5484D);
  static const Color info = Color(0xFF4A90D9);

  // ── Dark Theme (deep black-blue + bordo) ──
  static const Color darkBg = Color(0xFF0A0E27);
  static const Color darkSurface = Color(0xFF1A1F3A);
  static const Color darkSurfaceElevated = Color(0xFF242B4D);
  static const Color darkCard = Color(0xFF141935);
  static const Color darkDivider = Color(0xFF2A3152);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFF9CA3C0);
  static const Color darkTextTertiary = Color(0xFF6A7195);

  // ── Light Theme (near-white + subtle bordo tint) ──
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF5E6EA); // bordo tint
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFECDDE2);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6E5A62);
  static const Color lightTextTertiary = Color(0xFF9C8B92);

  // ── SRS Quality Colors (map to semantic) ──
  static const Color srsAgain = error;
  static const Color srsHard = warning;
  static const Color srsGood = info;
  static const Color srsEasy = success;

  /// Brand gradient (logo, hero accents).
  static const List<Color> brandGradient = [primaryDark, accent];

  /// Subtle drop shadow for cards/elevated surfaces, tuned per brightness.
  static List<BoxShadow> cardShadow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.28)
              : const Color(0xFF8B1538).withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Stronger shadow for lifted/hovered elements.
  static List<BoxShadow> hoverShadow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.40)
              : const Color(0xFF8B1538).withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
