import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/color_scheme.dart';

/// Animated star field background — parallax scrolling particle system
class StarFieldBackground extends StatefulWidget {
  final Widget child;
  final int starCount;
  final bool enableNebula;

  const StarFieldBackground({
    super.key,
    required this.child,
    this.starCount = 120,
    this.enableNebula = true,
  });

  @override
  State<StarFieldBackground> createState() => _StarFieldBackgroundState();
}

class _StarFieldBackgroundState extends State<StarFieldBackground>
    with TickerProviderStateMixin {
  late AnimationController _twinkleController;
  late AnimationController _driftController;
  late List<_Star> _stars;
  final _rand = math.Random(42);

  @override
  void initState() {
    super.initState();

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _stars = List.generate(widget.starCount, (_) => _Star(
          x: _rand.nextDouble(),
          y: _rand.nextDouble(),
          size: _rand.nextDouble() * 2.5 + 0.5,
          baseOpacity: _rand.nextDouble() * 0.5 + 0.3,
          twinkleSpeed: _rand.nextDouble() * 0.5 + 0.5,
          driftX: (_rand.nextDouble() - 0.5) * 0.002,
          driftY: (_rand.nextDouble() - 0.5) * 0.001,
          color: _starColor(_rand.nextInt(5)),
        ));
  }

  Color _starColor(int type) {
    switch (type) {
      case 0: return CosmicColors.ivory;
      case 1: return CosmicColors.gold.withValues(alpha: 0.8);
      case 2: return const Color(0xFFADD8E6); // cool blue
      case 3: return const Color(0xFFFFCCCC); // red giant
      default: return Colors.white;
    }
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep space gradient
        Container(
          decoration: const BoxDecoration(
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
        ),

        // Nebula layer
        if (widget.enableNebula) _NebulaLayer(),

        // Star field
        AnimatedBuilder(
          animation: Listenable.merge([_twinkleController, _driftController]),
          builder: (context, _) {
            return CustomPaint(
              painter: _StarPainter(
                stars: _stars,
                twinkleValue: _twinkleController.value,
                driftValue: _driftController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class _Star {
  double x, y;
  final double size;
  final double baseOpacity;
  final double twinkleSpeed;
  final double driftX, driftY;
  final Color color;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.twinkleSpeed,
    required this.driftX,
    required this.driftY,
    required this.color,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double twinkleValue;
  final double driftValue;

  _StarPainter({
    required this.stars,
    required this.twinkleValue,
    required this.driftValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // Apply drift
      final x = (star.x + star.driftX * driftValue * 100) % 1.0;
      final y = (star.y + star.driftY * driftValue * 100) % 1.0;

      // Twinkle
      final twinkleFactor = math.sin(
        twinkleValue * math.pi * 2 * star.twinkleSpeed,
      );
      final opacity = (star.baseOpacity + twinkleFactor * 0.2).clamp(0.1, 1.0);

      final paint = Paint()
        ..color = star.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final px = x * size.width;
      final py = y * size.height;

      // Draw star with glow for larger ones
      if (star.size > 1.8) {
        final glowPaint = Paint()
          ..color = star.color.withValues(alpha: opacity * 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(px, py), star.size * 2, glowPaint);
      }

      canvas.drawCircle(Offset(px, py), star.size * 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.twinkleValue != twinkleValue || old.driftValue != driftValue;
}

class _NebulaLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NebulaPainter(),
      size: Size.infinite,
    );
  }
}

class _NebulaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Saffron nebula patch (top-right)
    _drawNebula(
      canvas,
      Offset(size.width * 0.75, size.height * 0.2),
      size.width * 0.3,
      CosmicColors.saffron.withValues(alpha: 0.04),
    );

    // Indigo nebula patch (bottom-left)
    _drawNebula(
      canvas,
      Offset(size.width * 0.2, size.height * 0.7),
      size.width * 0.25,
      CosmicColors.indigo.withValues(alpha: 0.05),
    );

    // Gold nebula (center-ish)
    _drawNebula(
      canvas,
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.2,
      CosmicColors.gold.withValues(alpha: 0.03),
    );
  }

  void _drawNebula(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_NebulaPainter old) => false;
}
