import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../config/router/routes.dart';
import '../../../widgets/star_field_background.dart';
import '../../../database/app_database.dart';
import '../../../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mandalaController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _mandalaRotation;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _mandalaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _mandalaRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _mandalaController, curve: Curves.linear),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _runSplashSequence();
  }

  String? _initError;

  Future<void> _runSplashSequence() async {
    try {
      // Start animations FIRST so the UI appears even if db fails
      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _scaleController.forward();

      // Initialize database
      await AppDatabase.instance.database;

      // Check onboarding state
      await Future.delayed(const Duration(milliseconds: 2500));
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

      if (!mounted) return;
      if (onboardingDone) {
        context.go(AppRoutes.dashboard);
      } else {
        context.go(AppRoutes.welcome);
      }
    } catch (e, st) {
      print('Splash Init Error: $e\n$st');
      if (mounted) {
        setState(() {
          _initError = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _mandalaController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        starCount: 80,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mandala logo
                ScaleTransition(
                  scale: _scaleAnim,
                  child: AnimatedBuilder(
                    animation: _mandalaRotation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: CosmicColors.gold.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          // Rotating mandala ring
                          Transform.rotate(
                            angle: _mandalaRotation.value,
                            child: CustomPaint(
                              size: const Size(130, 130),
                              painter: _MandalaPainter(),
                            ),
                          ),
                          // Reverse rotating inner ring
                          Transform.rotate(
                            angle: -_mandalaRotation.value * 0.5,
                            child: CustomPaint(
                              size: const Size(90, 90),
                              painter: _MandalaPainter(petals: 6, innerRadius: 30),
                            ),
                          ),
                          // Center OM symbol / logo
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [CosmicColors.goldLight, CosmicColors.gold],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: CosmicColors.gold.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'ॐ',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: CosmicColors.bgDeep,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // App name
                Text(
                  'CosmicVed',
                  style: TextStyle(
                    fontFamily: CosmicTypography.cinzel,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          CosmicColors.goldDeep,
                          CosmicColors.gold,
                          CosmicColors.goldLight,
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 60)),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Your Cosmic Companion',
                  style: TextStyle(
                    fontFamily: CosmicTypography.cormorant,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: CosmicColors.textMed,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 80),

                // Loading indicator
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    backgroundColor: CosmicColors.bgCard,
                    color: CosmicColors.gold,
                    minHeight: 2,
                  ),
                ),
              if (_initError != null) ...[
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    'Initialization Error:\n$_initError',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
}

/// Mandala ring painter
class _MandalaPainter extends CustomPainter {
  final int petals;
  final double innerRadius;

  const _MandalaPainter({this.petals = 8, this.innerRadius = 40});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    final paint = Paint()
      ..color = CosmicColors.gold.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dotPaint = Paint()
      ..color = CosmicColors.gold.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi) / petals;
      final x = center.dx + outerRadius * math.cos(angle);
      final y = center.dy + outerRadius * math.sin(angle);

      // Petal path
      final path = Path();
      path.moveTo(center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle));
      path.quadraticBezierTo(
        center.dx + (outerRadius * 0.8) * math.cos(angle - 0.3),
        center.dy + (outerRadius * 0.8) * math.sin(angle - 0.3),
        x, y,
      );
      path.quadraticBezierTo(
        center.dx + (outerRadius * 0.8) * math.cos(angle + 0.3),
        center.dy + (outerRadius * 0.8) * math.sin(angle + 0.3),
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      canvas.drawPath(path, paint);

      // Dot at tip
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }

    // Outer ring
    canvas.drawCircle(center, outerRadius - 2, paint..color = CosmicColors.gold.withValues(alpha: 0.3));
    canvas.drawCircle(center, innerRadius, paint..color = CosmicColors.gold.withValues(alpha: 0.2));
  }

  @override
  bool shouldRepaint(_MandalaPainter old) => false;
}
