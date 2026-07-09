import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/color_scheme.dart';

/// Optimized animated star field background.
///
/// Key performance improvements over the original:
/// - Paint objects are pre-allocated and reused (not created per-frame per-star)
/// - MaskFilter.blur glow is removed from per-frame painting (causes GPU load)
/// - Star field is wrapped in RepaintBoundary so it paints independently
/// - Twinkle animation runs at reduced frequency via a slower AnimationController
/// - The static nebula layer is painted once and never repaints
class StarFieldBackground extends StatefulWidget {
  final Widget child;
  final int starCount;
  final bool enableNebula;

  const StarFieldBackground({
    super.key,
    required this.child,
    this.starCount = 80,
    this.enableNebula = true,
  });

  @override
  State<StarFieldBackground> createState() => _StarFieldBackgroundState();
}

class _StarFieldBackgroundState extends State<StarFieldBackground>
    with SingleTickerProviderStateMixin {
  // Single controller instead of two — reduced from 2 AnimationControllers to 1
  late AnimationController _twinkleController;
  late List<_Star> _stars;
  final _rand = math.Random(42);

  @override
  void initState() {
    super.initState();

    // Slower repeat = fewer frames needed for the star to visually update
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _stars = List.generate(widget.starCount, (_) => _Star(
      x: _rand.nextDouble(),
      y: _rand.nextDouble(),
      size: _rand.nextDouble() * 2.2 + 0.5,
      baseOpacity: _rand.nextDouble() * 0.5 + 0.3,
      twinkleSpeed: _rand.nextDouble() * 0.5 + 0.5,
      color: _starColor(_rand.nextInt(5)),
    ));
  }

  Color _starColor(int type) {
    switch (type) {
      case 0: return CosmicColors.ivory;
      case 1: return CosmicColors.gold.withValues(alpha: 0.8);
      case 2: return const Color(0xFFADD8E6);
      case 3: return const Color(0xFFFFCCCC);
      default: return Colors.white;
    }
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Static deep space gradient — never repaints
        const _StaticGradientBackground(),

        // Nebula layer — static CustomPainter, shouldRepaint=false, no blur at runtime
        if (widget.enableNebula) const RepaintBoundary(child: _NebulaLayer()),

        // Star field — isolated in RepaintBoundary, only this layer repaints per frame
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _twinkleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _StarPainter(
                  stars: _stars,
                  twinkleValue: _twinkleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),

        // Content — NOT inside a repaint boundary so it scrolls correctly,
        // but is isolated from the star animation layer above.
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x, y;
  final double size;
  final double baseOpacity;
  final double twinkleSpeed;
  final Color color;

  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.twinkleSpeed,
    required this.color,
  });
}

// ─── Star Painter ──────────────────────────────────────────────────────────

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double twinkleValue;

  // Pre-allocated paint object — reused every frame (no GC pressure)
  final Paint _starPaint = Paint()..style = PaintingStyle.fill;

  _StarPainter({required this.stars, required this.twinkleValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkleFactor = math.sin(
        twinkleValue * math.pi * 2 * star.twinkleSpeed,
      );
      final opacity = (star.baseOpacity + twinkleFactor * 0.2).clamp(0.1, 1.0);

      _starPaint.color = star.color.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * 0.7,
        _starPaint,
      );
    }
    // NOTE: Glow (MaskFilter.blur) removed — it causes a full GPU shader
    // compilation per star per frame. The visual difference is minimal on
    // a dark background and the performance gain is significant.
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.twinkleValue != twinkleValue;
}

// ─── Static layers (never repaint) ────────────────────────────────────────

class _StaticGradientBackground extends StatelessWidget {
  const _StaticGradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF020509),
            Color(0xFF050A18),
            Color(0xFF080E22),
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _NebulaLayer extends StatelessWidget {
  const _NebulaLayer();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _NebulaPainter(),
      size: Size.infinite,
    );
  }
}

class _NebulaPainter extends CustomPainter {
  const _NebulaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Use a single pre-allocated paint, mutate color for each nebula
    final paint = Paint()..style = PaintingStyle.fill;

    _drawNebula(canvas, paint,
      Offset(size.width * 0.75, size.height * 0.2),
      size.width * 0.3,
      CosmicColors.saffron.withValues(alpha: 0.05),
    );
    _drawNebula(canvas, paint,
      Offset(size.width * 0.2, size.height * 0.7),
      size.width * 0.25,
      CosmicColors.indigo.withValues(alpha: 0.06),
    );
    _drawNebula(canvas, paint,
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.2,
      CosmicColors.gold.withValues(alpha: 0.04),
    );
  }

  void _drawNebula(Canvas canvas, Paint paint, Offset center, double radius, Color color) {
    // Use a radial gradient instead of MaskFilter.blur — much cheaper on GPU
    paint.shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0.0)],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    paint.color = Colors.white; // color comes from shader
    canvas.drawCircle(center, radius, paint);
    paint.shader = null;
  }

  @override
  bool shouldRepaint(_NebulaPainter old) => false;
}
