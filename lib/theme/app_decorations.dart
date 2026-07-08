import 'dart:ui';
import 'package:flutter/material.dart';
import 'color_scheme.dart';

/// Shared decorations, borders, and UI helpers for CosmicVed
abstract final class CosmicDecorations {
  // ─── Glass Card ───────────────────────────────────────────────────────────
  static BoxDecoration glassCard({
    double borderRadius = 20,
    Color? tint,
    double opacity = 0.12,
    bool glowGold = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (tint ?? Colors.white).withValues(alpha: opacity),
          (tint ?? Colors.white).withValues(alpha: opacity * 0.5),
        ],
      ),
      border: Border.all(
        color: (tint ?? CosmicColors.gold).withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        if (glowGold)
          BoxShadow(
            color: CosmicColors.gold.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
      ],
    );
  }

  // ─── Light Glass Card ─────────────────────────────────────────────────────
  static BoxDecoration lightGlassCard({double borderRadius = 20}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xCCFFF8F0), Color(0xAAFFE8C8)],
      ),
      border: Border.all(
        color: CosmicColors.goldDeep.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: CosmicColors.goldDeep.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ─── Gold Border ──────────────────────────────────────────────────────────
  static BoxDecoration goldBorder({
    double borderRadius = 16,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: CosmicColors.gold.withValues(alpha: 0.5),
        width: borderWidth,
      ),
    );
  }

  // ─── Gradient Container ───────────────────────────────────────────────────
  static BoxDecoration gradientCard({
    List<Color>? colors,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors ??
            [
              CosmicColors.bgCard,
              CosmicColors.bgCardAlt,
            ],
      ),
      border: Border.all(
        color: CosmicColors.gold.withValues(alpha: 0.15),
        width: 1,
      ),
    );
  }

  // ─── Planet Badge ─────────────────────────────────────────────────────────
  static BoxDecoration planetBadge(Color planetColor) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: planetColor.withValues(alpha: 0.15),
      border: Border.all(
        color: planetColor.withValues(alpha: 0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: planetColor.withValues(alpha: 0.2),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
    );
  }

  // ─── Mandala Divider ──────────────────────────────────────────────────────
  static Widget mandalaDevider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                CosmicColors.gold.withValues(alpha: 0.4),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '✦',
            style: TextStyle(
              color: CosmicColors.gold.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                CosmicColors.gold.withValues(alpha: 0.4),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

/// Backdrop blur glass widget
class GlassWidget extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final Color? tint;
  final bool glowGold;

  const GlassWidget({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 10,
    this.tint,
    this.glowGold = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: CosmicDecorations.glassCard(
            borderRadius: borderRadius,
            tint: tint,
            glowGold: glowGold,
          ),
          child: child,
        ),
      ),
    );
  }
}
