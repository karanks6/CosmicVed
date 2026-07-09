import 'package:flutter/material.dart';
import '../theme/color_scheme.dart';
import '../theme/app_decorations.dart';

/// Premium glassmorphism card widget
class CosmicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? tint;
  final bool glowGold;
  final double blurSigma;
  final VoidCallback? onTap;
  final bool animate;
  final Gradient? gradient;

  const CosmicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.tint,
    this.glowGold = false,
    this.blurSigma = 8,
    this.onTap,
    this.animate = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // BackdropFilter.blur was removed — multiple simultaneous blur filters are
    // the #1 cause of GPU frame drops in Flutter. The solid card design is
    // visually nearly identical but costs a fraction of the GPU budget.
    Widget card = Container(
      decoration: gradient != null
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: gradient,
              border: Border.all(
                color: CosmicColors.gold.withValues(alpha: 0.2),
                width: 1,
              ),
            )
          : isDark
              ? CosmicDecorations.glassCard(
                  borderRadius: borderRadius,
                  tint: tint,
                  glowGold: glowGold,
                )
              : CosmicDecorations.lightGlassCard(
                  borderRadius: borderRadius,
                ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: CosmicColors.gold.withValues(alpha: 0.1),
          highlightColor: CosmicColors.gold.withValues(alpha: 0.05),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Gradient card with optional glow
class CosmicGradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const CosmicGradientCard({
    super.key,
    required this.child,
    required this.colors,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Animated pulsing card (for special highlights)
class CosmicPulseCard extends StatefulWidget {
  final Widget child;
  final Color pulseColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const CosmicPulseCard({
    super.key,
    required this.child,
    this.pulseColor = CosmicColors.gold,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  State<CosmicPulseCard> createState() => _CosmicPulseCardState();
}

class _CosmicPulseCardState extends State<CosmicPulseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.pulseColor.withValues(
                  alpha: 0.1 + _pulseAnim.value * 0.2,
                ),
                blurRadius: 20 + _pulseAnim.value * 20,
                spreadRadius: _pulseAnim.value * 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: CosmicCard(
        padding: widget.padding,
        borderRadius: widget.borderRadius,
        glowGold: widget.pulseColor == CosmicColors.gold,
        child: widget.child,
      ),
    );
  }
}
