import 'package:flutter/material.dart';

/// User-controlled typography settings, applied globally to the whole UI.
///
/// - [baseSize] drives a root-level text scaler (size preset / slider).
/// - [weightIndex] shifts every text style's weight up/down while keeping
///   the visual hierarchy intact (Light/Normal/Bold/Extra Bold).
/// - [italic] and [lineHeight] are baked into the generated TextTheme.
class FontSettings {
  final double baseSize; // px, 10–24; default 14
  final int weightIndex; // 0=Light, 1=Normal, 2=Bold, 3=Extra Bold
  final bool italic;
  final double lineHeight; // 1.2 / 1.5 / 1.8 / 2.0

  const FontSettings({
    this.baseSize = 14.0,
    this.weightIndex = 1,
    this.italic = false,
    this.lineHeight = 1.5,
  });

  /// The baseline body size the TextTheme is authored against.
  static const double referenceSize = 14.0;

  /// Root-level text scale factor derived from [baseSize].
  double get textScale => baseSize / referenceSize;

  FontStyle get fontStyle => italic ? FontStyle.italic : FontStyle.normal;

  static const List<String> weightLabels = [
    'Light',
    'Normal',
    'Bold',
    'Extra Bold',
  ];

  /// Weight delta in hundreds applied to each style's base weight.
  int get _weightDelta => const [-100, 0, 100, 200][weightIndex.clamp(0, 3)];

  /// Shifts a base [FontWeight] by the user's weight preference, clamped to
  /// the 100–900 range while preserving the app's typographic hierarchy.
  FontWeight resolveWeight(FontWeight base) {
    final shifted = (base.value + _weightDelta).clamp(100, 900);
    return FontWeight.values[(shifted ~/ 100) - 1];
  }

  FontSettings copyWith({
    double? baseSize,
    int? weightIndex,
    bool? italic,
    double? lineHeight,
  }) {
    return FontSettings(
      baseSize: baseSize ?? this.baseSize,
      weightIndex: weightIndex ?? this.weightIndex,
      italic: italic ?? this.italic,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}
