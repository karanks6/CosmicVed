import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../config/router/routes.dart';
import '../../../services/numerology/chaldean_service.dart';
import '../../../models/models.dart';
import '../../dashboard/screens/dashboard_screen.dart';
// ─── Providers ─────────────────────────────────────────────────────────────

final lifePathProvider = FutureProvider.family<NumerologyResult?, dynamic>((ref, profile) async {
  if (profile == null) return null;
  return ChaldeanService.instance.calculateLifePath(profile.dateOfBirth);
});

// ─── Numerology Home ────────────────────────────────────────────────────────

class NumerologyHomeScreen extends ConsumerWidget {
  const NumerologyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        starCount: 60,
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: CosmicColors.gold),
          ),
          error: (e, _) => Center(child: Text('$e')),
          data: (profile) => _NumerologyContent(profile: profile),
        ),
      ),
    );
  }
}

class _NumerologyContent extends ConsumerWidget {
  final dynamic profile;
  const _NumerologyContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifePathAsync = profile != null
        ? ref.watch(lifePathProvider(profile))
        : const AsyncValue<NumerologyResult?>.data(null);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            'Chaldean Numerology',
            style: TextStyle(
              fontFamily: CosmicTypography.cinzel,
              fontSize: 18,
              color: CosmicColors.textHigh,
            ),
          ),
          backgroundColor: Colors.transparent,
          floating: true,
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // Life Path card
              lifePathAsync.when(
                loading: () => _SkeletonCard(height: 180),
                error: (_, __) => const SizedBox.shrink(),
                data: (lp) => lp != null ? _LifePathCard(result: lp) : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Nav cards
              Text(
                'Explore Numbers',
                style: TextStyle(
                  fontFamily: CosmicTypography.cinzel,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: CosmicColors.textHigh,
                ),
              ),

              const SizedBox(height: 12),

              _NumCard(
                number: profile != null
                    ? ChaldeanService.instance
                        .calculateLifePath(profile.dateOfBirth)
                        .number
                    : 0,
                title: 'Life Path Number',
                subtitle: 'Your soul\'s core mission and purpose',
                icon: Icons.route_rounded,
                route: '${AppRoutes.numerology}/life-path',
                color: CosmicColors.gold,
              ),

              const SizedBox(height: 10),

              _NumCard(
                number: 0, // Calculated when user enters name
                title: 'Destiny Number',
                subtitle: 'Based on your full birth name',
                icon: Icons.stars_rounded,
                route: '${AppRoutes.numerology}/destiny',
                color: CosmicColors.saffron,
              ),

              const SizedBox(height: 10),

              _NumCard(
                number: 0,
                title: 'Name Number',
                subtitle: 'Based on your currently used name',
                icon: Icons.text_fields_rounded,
                route: '${AppRoutes.numerology}/name-number',
                color: CosmicColors.indigo,
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

class _LifePathCard extends StatelessWidget {
  final NumerologyResult result;
  const _LifePathCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return CosmicPulseCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Life Path Number',
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      fontSize: 12,
                      color: CosmicColors.textMed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.interpretation['title'] ?? '',
                    style: TextStyle(
                      fontFamily: CosmicTypography.cinzel,
                      fontSize: 16,
                      color: CosmicColors.textHigh,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: CosmicColors.goldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: CosmicColors.gold.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${result.number}',
                    style: TextStyle(
                      fontFamily: CosmicTypography.cinzel,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: CosmicColors.bgDeep,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.interpretation['summary'] ?? '',
            style: TextStyle(
              fontFamily: CosmicTypography.cormorant,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: CosmicColors.textMed,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            'Formula: ${result.formula}',
            style: TextStyle(
              fontFamily: CosmicTypography.inter,
              fontSize: 11,
              color: CosmicColors.textLow,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  const _NumCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.push(route),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: CosmicTypography.inter,
                    fontSize: 11,
                    color: CosmicColors.textMed,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: CosmicColors.textLow, size: 20),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({required this.height});
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: CosmicColors.bgCard,
    ),
  );
}
