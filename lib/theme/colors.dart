import 'package:flutter/material.dart';

/// Vivid Sonic / VibeTune design system.
///
/// A bright, airy LIGHT theme built on an off-white base with a trio of
/// electric accents (Electric Violet, Magenta, Cyan) and soft, colored
/// shadows for weightless depth.
class AppColors {
  AppColors._();

  // Primary palette (Electric Violet)
  static const Color primary = Color(0xFF4648D4);
  static const Color primaryLight = Color(0xFF6063EE); // primary-container
  static const Color primaryDark = Color(0xFF2F2EBE);

  // Secondary (Magenta) / Tertiary (Cyan)
  static const Color accent = Color(0xFFA200BA); // secondary
  static const Color accentLight = Color(0xFFEA57FF); // secondary-container
  static const Color tertiary = Color(0xFF006577);
  static const Color tertiaryLight = Color(0xFF4CD7F6);

  // Backgrounds & surfaces
  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Color(0xFFFFFFFF); // pure white cards
  static const Color surfaceLight = Color(0xFFEDEEFB); // light violet tint
  static const Color surfaceVariant = Color(0xFFE9EBF0); // neutral container

  // Text
  static const Color textPrimary = Color(0xFF191C1E); // on-surface charcoal
  static const Color textSecondary = Color(0xFF464554); // on-surface-variant
  static const Color textTertiary = Color(0xFF767586); // outline

  // Functional
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFFFFB74D);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent], // violet -> magenta
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF7F9FB), Color(0xFFF1F3F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Default album-art tile gradient (vivid violet -> magenta).
  static const LinearGradient cardGradient = LinearGradient(
    colors: [primaryLight, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Palettes used for generated album-art tiles.
  static const List<List<Color>> albumPalettes = [
    [Color(0xFF6063EE), Color(0xFFA200BA)], // violet -> magenta
    [Color(0xFF006577), Color(0xFF4CD7F6)], // cyan
    [Color(0xFFEA57FF), Color(0xFF4648D4)], // magenta -> violet
    [Color(0xFF4648D4), Color(0xFF006577)], // violet -> cyan
    [Color(0xFF7C4DFF), Color(0xFFEA57FF)], // purple -> magenta
  ];

  /// Deterministic gradient for a given seed (e.g. a song id / index).
  static LinearGradient albumGradient(Object seed) {
    final palette = albumPalettes[seed.hashCode.abs() % albumPalettes.length];
    return LinearGradient(
      colors: palette,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Soft colored shadows (the "vivid" depth).
  static List<BoxShadow> get softShadow => const [
    BoxShadow(
      color: Color(0x0D6366F1), // rgba(99,102,241,0.05)
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get floatingShadow => const [
    BoxShadow(
      color: Color(0x1F6366F1), // rgba(99,102,241,0.12)
      blurRadius: 40,
      offset: Offset(0, 20),
    ),
  ];

  /// Colored glow that matches a button's own hue.
  static List<BoxShadow> glow(Color color, {double alpha = 0.4}) => [
    BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
