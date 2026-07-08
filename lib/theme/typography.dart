import 'package:flutter/material.dart';
import 'color_scheme.dart';

/// CosmicVed typography system
abstract final class CosmicTypography {
  // ─── Font Families ────────────────────────────────────────────────────────
  static const String cinzel = 'Cinzel';
  static const String cormorant = 'CormorantGaramond';
  static const String inter = 'Inter';

  // ─── Dark Text Theme ──────────────────────────────────────────────────────
  static TextTheme buildDarkTextTheme() => _buildTextTheme(
        high: CosmicColors.textHigh,
        med: CosmicColors.textMed,
        low: CosmicColors.textLow,
      );

  // ─── Light Text Theme ─────────────────────────────────────────────────────
  static TextTheme buildLightTextTheme() => _buildTextTheme(
        high: CosmicColors.textHighLight,
        med: CosmicColors.textMedLight,
        low: CosmicColors.textMedLight,
      );

  static TextTheme _buildTextTheme({
    required Color high,
    required Color med,
    required Color low,
  }) {
    return TextTheme(
      // ── Display ── (Cinzel — for spectacular headings)
      displayLarge: TextStyle(
        fontFamily: cinzel,
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: high,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: cinzel,
        fontSize: 44,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: high,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: cinzel,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: high,
        height: 1.2,
      ),

      // ── Headline ── (Cinzel for section headers)
      headlineLarge: TextStyle(
        fontFamily: cinzel,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: high,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: cinzel,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: high,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: cinzel,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: high,
        height: 1.35,
      ),

      // ── Title ── (Cormorant Garamond for elegant sub-headings)
      titleLarge: TextStyle(
        fontFamily: cormorant,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: high,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: cormorant,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: med,
        height: 1.45,
      ),
      titleSmall: TextStyle(
        fontFamily: cormorant,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: med,
        height: 1.5,
      ),

      // ── Body ── (Inter for readable content)
      bodyLarge: TextStyle(
        fontFamily: inter,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: high,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: inter,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: med,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontFamily: inter,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: low,
        height: 1.5,
      ),

      // ── Label ── (Inter for chips, captions)
      labelLarge: TextStyle(
        fontFamily: inter,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: high,
      ),
      labelMedium: TextStyle(
        fontFamily: inter,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: med,
      ),
      labelSmall: TextStyle(
        fontFamily: inter,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: low,
      ),
    );
  }
}

/// Extension for quick access to cosmic text styles
extension CosmicTextExt on BuildContext {
  TextTheme get txt => Theme.of(this).textTheme;

  TextStyle get cinzelDisplay => TextStyle(
        fontFamily: CosmicTypography.cinzel,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: CosmicColors.gold,
      );

  TextStyle get cormorantTitle => TextStyle(
        fontFamily: CosmicTypography.cormorant,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        color: CosmicColors.textMed,
      );
}
