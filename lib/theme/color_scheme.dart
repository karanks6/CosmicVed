import 'package:flutter/material.dart';

/// CosmicVed design tokens — sacred cosmic palette
abstract final class CosmicColors {
  // ─── Dark Theme Surfaces ──────────────────────────────────────────────────
  static const Color bgDeep = Color(0xFF050A18); // Deep space
  static const Color bgBase = Color(0xFF080E20); // Base background
  static const Color bgCard = Color(0xFF0D1530); // Card surface
  static const Color bgCardAlt = Color(0xFF111A38); // Alt card
  static const Color bgOverlay = Color(0x990D1530); // Glass overlay

  // ─── Light Theme Surfaces ─────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFFFF8F0); // Warm ivory
  static const Color lightCard = Color(0xFFFFF0DC); // Sand card
  static const Color lightCardAlt = Color(0xFFFFE8C8); // Deeper sand
  static const Color lightOverlay = Color(0xCCFFF8F0); // Glass overlay

  // ─── Brand Colors ─────────────────────────────────────────────────────────
  static const Color gold = Color(0xFFD4A017); // Sacred gold (primary)
  static const Color goldLight = Color(0xFFECC94B); // Golden light
  static const Color goldDeep = Color(0xFFA07810); // Deep gold
  static const Color saffron = Color(0xFFFF6B2B); // Saffron (secondary)
  static const Color saffronLight = Color(0xFFFF8C5A); // Light saffron
  static const Color indigo = Color(0xFF7B2FBE); // Deep indigo (accent)
  static const Color indigoLight = Color(0xFF9B4FDE); // Light indigo
  static const Color maroon = Color(0xFF8B1A1A); // Maroon
  static const Color maroonLight = Color(0xFFAB3A3A); // Light maroon

  // ─── Neutral Tones ────────────────────────────────────────────────────────
  static const Color ivory = Color(0xFFF5E6C8); // Star/ivory white
  static const Color sand = Color(0xFFD4B896); // Sand
  static const Color textHigh = Color(0xFFFFF8EC); // High-emphasis text (dark)
  static const Color textMed = Color(0xFFB8A98A); // Medium text (dark)
  static const Color textLow = Color(0xFF7A6B54); // Low-emphasis text (dark)
  static const Color textHighLight = Color(0xFF1A1206); // High text (light)
  static const Color textMedLight = Color(0xFF5C4A2A); // Medium text (light)

  // ─── Planet Colors ────────────────────────────────────────────────────────
  static const Color sun = Color(0xFFFFB830); // Surya - Sun
  static const Color moon = Color(0xFFE8E8FF); // Chandra - Moon
  static const Color mars = Color(0xFFFF4444); // Mangal - Mars
  static const Color mercury = Color(0xFF50C878); // Budha - Mercury
  static const Color jupiter = Color(0xFFFFD700); // Guru - Jupiter
  static const Color venus = Color(0xFFFF69B4); // Shukra - Venus
  static const Color saturn = Color(0xFF778899); // Shani - Saturn
  static const Color rahu = Color(0xFF4B0082); // Rahu (North Node)
  static const Color ketu = Color(0xFF8B4513); // Ketu (South Node)

  // ─── Semantic Colors ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDeep, Color(0xFF0A0F22), Color(0xFF0D1530)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldDeep, gold, goldLight],
  );

  static const LinearGradient saffronGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE55A1B), saffron, saffronLight],
  );

  static const LinearGradient indigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B1F9E), indigo, indigoLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1530), Color(0xFF111A38)],
  );

  static const RadialGradient starburstGradient = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [Color(0x33D4A017), Color(0x00D4A017)],
  );

  // ─── Light Theme Gradients ────────────────────────────────────────────────
  static const LinearGradient lightCosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF8F0), Color(0xFFFFF0DC), Color(0xFFFFE8C8)],
  );

  // ─── Guna Milan Score Colors ──────────────────────────────────────────────
  static Color gunaScoreColor(double percent) {
    if (percent >= 75) return success;
    if (percent >= 60) return goldLight;
    if (percent >= 45) return warning;
    return error;
  }
}

/// Build the dark ColorScheme
ColorScheme buildDarkColorScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    primary: CosmicColors.gold,
    onPrimary: CosmicColors.bgDeep,
    primaryContainer: CosmicColors.goldDeep,
    onPrimaryContainer: CosmicColors.textHigh,
    secondary: CosmicColors.saffron,
    onSecondary: CosmicColors.bgDeep,
    secondaryContainer: Color(0xFF4A2010),
    onSecondaryContainer: CosmicColors.saffronLight,
    tertiary: CosmicColors.indigo,
    onTertiary: CosmicColors.textHigh,
    tertiaryContainer: Color(0xFF3A1580),
    onTertiaryContainer: CosmicColors.indigoLight,
    error: CosmicColors.error,
    onError: Colors.white,
    surface: CosmicColors.bgCard,
    onSurface: CosmicColors.textHigh,
    surfaceContainerHighest: CosmicColors.bgCardAlt,
    onSurfaceVariant: CosmicColors.textMed,
    outline: Color(0xFF3A3060),
    outlineVariant: Color(0xFF1E2040),
    shadow: Colors.black,
    scrim: Color(0x80000000),
    inverseSurface: CosmicColors.ivory,
    onInverseSurface: CosmicColors.bgDeep,
    inversePrimary: CosmicColors.goldDeep,
  );
}

/// Build the light ColorScheme
ColorScheme buildLightColorScheme() {
  return const ColorScheme(
    brightness: Brightness.light,
    primary: CosmicColors.goldDeep,
    onPrimary: Colors.white,
    primaryContainer: CosmicColors.goldLight,
    onPrimaryContainer: CosmicColors.bgDeep,
    secondary: CosmicColors.saffron,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFDDCC),
    onSecondaryContainer: Color(0xFF6A2000),
    tertiary: CosmicColors.indigo,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFE8D0FF),
    onTertiaryContainer: Color(0xFF3A0080),
    error: CosmicColors.error,
    onError: Colors.white,
    surface: CosmicColors.lightCard,
    onSurface: CosmicColors.textHighLight,
    surfaceContainerHighest: CosmicColors.lightCardAlt,
    onSurfaceVariant: CosmicColors.textMedLight,
    outline: Color(0xFFB89060),
    outlineVariant: Color(0xFFD4C0A0),
    shadow: Color(0x40000000),
    scrim: Color(0x40000000),
    inverseSurface: CosmicColors.bgCard,
    onInverseSurface: CosmicColors.textHigh,
    inversePrimary: CosmicColors.gold,
  );
}
