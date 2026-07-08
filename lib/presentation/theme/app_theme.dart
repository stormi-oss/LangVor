import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'font_settings.dart';

/// LangVor theme data — dark and light themes with Inter typography.
///
/// Both themes are parameterized by [FontSettings] so the user's font
/// weight, italic, and line-height choices are baked into every text style.
/// (Font *size* is applied separately via a root text scaler.)
class AppTheme {
  AppTheme._();

  static const double _cardRadius = 12.0;
  static const double _inputRadius = 10.0;
  static const double _chipRadius = 8.0;

  // ─── Dark Theme ───────────────────────────────────────────────────────────

  static ThemeData dark(FontSettings fonts) {
    final text = _buildTextTheme(Brightness.dark, fonts);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.darkSurfaceElevated,
        border: AppColors.darkDivider,
        hint: AppColors.darkTextTertiary,
        fonts: fonts,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme:
            const IconThemeData(color: AppColors.darkTextSecondary),
        selectedLabelTextStyle:
            text.labelMedium?.copyWith(color: AppColors.primary),
        unselectedLabelTextStyle:
            text.labelMedium?.copyWith(color: AppColors.darkTextSecondary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      elevatedButtonTheme: _buttonTheme(),
      filledButtonTheme: FilledButtonThemeData(style: _buttonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _buttonStyle()),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_chipRadius),
          side: const BorderSide(color: AppColors.darkDivider),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.darkSurfaceElevated,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        contentTextStyle:
            text.bodyMedium?.copyWith(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Light Theme ──────────────────────────────────────────────────────────

  static ThemeData light(FontSettings fonts) {
    final text = _buildTextTheme(Brightness.light, fonts);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accentDark,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: const BorderSide(color: AppColors.lightDivider, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.lightSurfaceElevated,
        border: AppColors.lightDivider,
        hint: AppColors.lightTextTertiary,
        fonts: fonts,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme:
            const IconThemeData(color: AppColors.lightTextSecondary),
        selectedLabelTextStyle:
            text.labelMedium?.copyWith(color: AppColors.primary),
        unselectedLabelTextStyle:
            text.labelMedium?.copyWith(color: AppColors.lightTextSecondary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      elevatedButtonTheme: _buttonTheme(),
      filledButtonTheme: FilledButtonThemeData(style: _buttonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _buttonStyle()),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceElevated,
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_chipRadius),
          side: const BorderSide(color: AppColors.lightDivider),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightSurfaceElevated,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Shared component styles ──────────────────────────────────────────────

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color hint,
    required FontSettings fonts,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: TextStyle(
        fontFamily: 'Inter',
        color: hint,
        fontStyle: fonts.fontStyle,
      ),
    );
  }

  static ElevatedButtonThemeData _buttonTheme() =>
      ElevatedButtonThemeData(style: _buttonStyle());

  static ButtonStyle _buttonStyle() => ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        animationDuration: const Duration(milliseconds: 180),
      );

  // ─── Typography ───────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(Brightness brightness, FontSettings fonts) {
    final color = brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryColor = brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    TextStyle style(
      double size,
      FontWeight weight,
      Color c, {
      double? letterSpacing,
      double? height,
    }) {
      return TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: fonts.resolveWeight(weight),
        fontStyle: fonts.fontStyle,
        color: c,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return TextTheme(
      displayLarge:
          style(32, FontWeight.w700, color, letterSpacing: -0.5),
      displayMedium:
          style(28, FontWeight.w700, color, letterSpacing: -0.5),
      headlineLarge: style(24, FontWeight.w600, color),
      headlineMedium: style(20, FontWeight.w600, color),
      titleLarge: style(18, FontWeight.w600, color),
      titleMedium: style(16, FontWeight.w500, color),
      titleSmall: style(14, FontWeight.w500, secondaryColor),
      bodyLarge: style(16, FontWeight.w400, color, height: fonts.lineHeight),
      bodyMedium: style(14, FontWeight.w400, color, height: fonts.lineHeight),
      bodySmall:
          style(12, FontWeight.w400, secondaryColor, height: fonts.lineHeight),
      labelLarge: style(14, FontWeight.w600, color, letterSpacing: 0.3),
      labelMedium: style(12, FontWeight.w500, secondaryColor),
      labelSmall:
          style(11, FontWeight.w500, secondaryColor, letterSpacing: 0.5),
    );
  }
}
