import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_scheme.dart';
import 'typography.dart';

/// CosmicVed application theme
abstract final class CosmicTheme {
  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData dark() {
    final colorScheme = buildDarkColorScheme();
    final textTheme = CosmicTypography.buildDarkTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: CosmicColors.bgDeep,
      canvasColor: CosmicColors.bgBase,
      cardColor: CosmicColors.bgCard,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: CosmicColors.textHigh,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: CosmicColors.gold),
        actionsIconTheme: const IconThemeData(color: CosmicColors.gold),
      ),

      // ── Bottom Nav ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0A0E20),
        selectedItemColor: CosmicColors.gold,
        unselectedItemColor: CosmicColors.textLow,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── NavigationBar ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0A0E20),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        indicatorColor: CosmicColors.gold.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: CosmicColors.gold, size: 24);
          }
          return const IconThemeData(color: CosmicColors.textLow, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: CosmicTypography.inter,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CosmicColors.gold,
            );
          }
          return const TextStyle(
            fontFamily: CosmicTypography.inter,
            fontSize: 11,
            color: CosmicColors.textLow,
          );
        }),
      ),

      // ── Card ──
      cardTheme: CardThemeData(
        color: CosmicColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: CosmicColors.gold.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── ElevatedButton ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CosmicColors.gold,
          foregroundColor: CosmicColors.bgDeep,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: CosmicTypography.cinzel,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // ── OutlinedButton ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CosmicColors.gold,
          side: const BorderSide(color: CosmicColors.gold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: CosmicTypography.cinzel,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // ── TextButton ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CosmicColors.gold,
          textStyle: const TextStyle(
            fontFamily: CosmicTypography.inter,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── InputDecoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CosmicColors.bgCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: CosmicColors.gold.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: CosmicColors.gold.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: CosmicColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CosmicColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CosmicColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: CosmicTypography.inter,
          color: CosmicColors.textMed,
        ),
        hintStyle: TextStyle(
          fontFamily: CosmicTypography.inter,
          color: CosmicColors.textLow,
        ),
        prefixIconColor: CosmicColors.gold,
        suffixIconColor: CosmicColors.textMed,
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: CosmicColors.bgCard,
        labelStyle: const TextStyle(
          fontFamily: CosmicTypography.inter,
          fontSize: 12,
          color: CosmicColors.textMed,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: CosmicColors.gold.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: CosmicColors.gold.withValues(alpha: 0.15),
        thickness: 1,
        space: 24,
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: CosmicColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: CosmicColors.gold.withValues(alpha: 0.2),
          ),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CosmicColors.bgCardAlt,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── TabBar ──
      tabBarTheme: const TabBarThemeData(
        labelColor: CosmicColors.gold,
        unselectedLabelColor: CosmicColors.textLow,
        indicatorColor: CosmicColors.gold,
        labelStyle: TextStyle(
          fontFamily: CosmicTypography.cinzel,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: CosmicTypography.inter,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CosmicColors.gold;
          }
          return CosmicColors.textLow;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CosmicColors.gold.withValues(alpha: 0.3);
          }
          return CosmicColors.bgCardAlt;
        }),
      ),

      // ── Slider ──
      sliderTheme: const SliderThemeData(
        activeTrackColor: CosmicColors.gold,
        inactiveTrackColor: CosmicColors.bgCardAlt,
        thumbColor: CosmicColors.gold,
        overlayColor: Color(0x33D4A017),
      ),

      // ── ProgressIndicator ──
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CosmicColors.gold,
        linearTrackColor: CosmicColors.bgCardAlt,
        circularTrackColor: CosmicColors.bgCardAlt,
      ),

      // ── Tooltip ──
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: CosmicColors.bgCardAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: CosmicColors.gold.withValues(alpha: 0.3),
          ),
        ),
        textStyle: const TextStyle(
          fontFamily: CosmicTypography.inter,
          fontSize: 12,
          color: CosmicColors.textHigh,
        ),
      ),

      // ── Icon ──
      iconTheme: const IconThemeData(
        color: CosmicColors.textMed,
        size: 22,
      ),

      // ── PageTransitions ──
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData light() {
    final colorScheme = buildLightColorScheme();
    final textTheme = CosmicTypography.buildLightTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: CosmicColors.lightBg,
      canvasColor: CosmicColors.lightCard,
      cardColor: CosmicColors.lightCard,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: CosmicColors.textHighLight,
        ),
        iconTheme: const IconThemeData(color: CosmicColors.goldDeep),
      ),

      cardTheme: CardThemeData(
        color: CosmicColors.lightCard,
        elevation: 2,
        shadowColor: CosmicColors.goldDeep.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: CosmicColors.goldDeep.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CosmicColors.goldDeep,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CosmicColors.lightCardAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: CosmicColors.goldDeep.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: CosmicColors.goldDeep.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: CosmicColors.goldDeep, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: CosmicTypography.inter,
          color: CosmicColors.textMedLight,
        ),
        prefixIconColor: CosmicColors.goldDeep,
      ),
    );
  }
}
