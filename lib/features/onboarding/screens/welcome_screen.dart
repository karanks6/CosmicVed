import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../config/router/routes.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late AnimationController _cardsController;

  final _features = [
    (Icons.auto_graph_rounded, 'Vedic Kundali',
        'Complete birth chart with North, South & East Indian styles'),
    (Icons.filter_9_plus_rounded, 'Chaldean Numerology',
        'Life Path, Destiny & Name Number with full interpretations'),
    (Icons.favorite_rounded, 'Compatibility',
        'Ashtakoota Guna Milan & friendship matching'),
    (Icons.calendar_today_rounded, 'Daily Panchang',
        'Tithi, Nakshatra, Yoga, Rahu Kalam & Muhurta'),
    (Icons.medical_services_rounded, 'Remedies & Guidance',
        'Personalized gemstones, mantras & spiritual practices'),
  ];

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeIn);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    _heroController.forward().then((_) => _cardsController.forward());
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Hero section
                      FadeTransition(
                        opacity: _heroFade,
                        child: SlideTransition(
                          position: _heroSlide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: CosmicColors.gold.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: CosmicColors.gold.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('✨', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ancient Wisdom, Modern App',
                                      style: TextStyle(
                                        fontFamily: CosmicTypography.inter,
                                        fontSize: 12,
                                        color: CosmicColors.gold,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    CosmicColors.goldGradient.createShader(bounds),
                                child: Text(
                                  'Discover Your\nCosmic Destiny',
                                  style: TextStyle(
                                    fontFamily: CosmicTypography.cinzel,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'Explore authentic Vedic Astrology and Chaldean '
                                'Numerology — entirely offline, beautifully designed, '
                                'and deeply insightful.',
                                style: TextStyle(
                                  fontFamily: CosmicTypography.inter,
                                  fontSize: 15,
                                  color: CosmicColors.textMed,
                                  height: 1.6,
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),

                      // Feature cards
                      AnimatedBuilder(
                        animation: _cardsController,
                        builder: (context, child) {
                          return Column(
                            children: _features.asMap().entries.map((entry) {
                              final index = entry.key;
                              final delay = index * 0.1;
                              final animValue = (_cardsController.value - delay)
                                  .clamp(0.0, 1.0);

                              return Opacity(
                                opacity: animValue,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - animValue)),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: _FeatureCard(
                                      icon: entry.value.$1,
                                      title: entry.value.$2,
                                      description: entry.value.$3,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // CTA buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    CosmicButton(
                      label: 'Begin My Journey',
                      icon: Icons.arrow_forward_rounded,
                      width: double.infinity,
                      onPressed: () => context.go(
                        AppRoutes.profileSetup,
                        extra: {'first': true},
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '100% Offline • Privacy First • No Account Required',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: CosmicTypography.inter,
                        fontSize: 11,
                        color: CosmicColors.textLow,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: CosmicColors.bgCard,
        border: Border.all(
          color: CosmicColors.gold.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CosmicColors.gold.withValues(alpha: 0.1),
              border: Border.all(
                color: CosmicColors.gold.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, color: CosmicColors.gold, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: CosmicTypography.cinzel,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CosmicColors.textHigh,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: CosmicTypography.inter,
                    fontSize: 12,
                    color: CosmicColors.textMed,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
