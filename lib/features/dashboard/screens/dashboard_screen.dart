import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../config/router/routes.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../models/models.dart';
import '../../../models/user_profile.dart';
import '../../../repositories/profile_repository.dart';
import '../../../repositories/astrology_repository.dart';
import '../../../services/astrology/panchang_service.dart';

// ─── Providers ─────────────────────────────────────────────────────────────

final activeProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ProfileRepository();
  final result = await repo.getActiveProfile();
  return result.valueOrNull;
});

final panchangProvider = FutureProvider.family<Panchang?, UserProfile?>((ref, profile) async {
  if (profile == null) return null;
  final result = await AstrologyRepository().getOrCalculatePanchang(
    profileId: profile.id!,
    dateLocal: DateTime.now(),
    latitude: profile.latitude,
    longitude: profile.longitude,
    utcOffsetMinutes: 330, // Default to IST (5.5 hrs) for demo purposes
  );
  return result.valueOrNull;
});

final kundaliProvider = FutureProvider.family<Kundali?, UserProfile?>((ref, profile) async {
  if (profile == null) return null;
  final repo = AstrologyRepository();
  final result = await repo.getOrCalculateKundali(profile);
  return result.valueOrNull;
});

// ─── Dashboard Screen ──────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: CosmicColors.gold),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (profile) {
            if (profile == null) {
              return _NoProfileView();
            }
            return _DashboardContent(profile: profile);
          },
        ),
      ),
    );
  }
}

class _NoProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ॐ', style: TextStyle(fontSize: 60, color: CosmicColors.gold)),
          const SizedBox(height: 20),
          Text(
            'Welcome to CosmicVed',
            style: TextStyle(
              fontFamily: CosmicTypography.cinzel,
              fontSize: 22,
              color: CosmicColors.textHigh,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a profile to begin your cosmic journey',
            style: TextStyle(
              fontFamily: CosmicTypography.inter,
              color: CosmicColors.textMed,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.profileSetup, extra: {'first': true}),
            child: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final UserProfile profile;
  const _DashboardContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panchangAsync = ref.watch(panchangProvider(profile));
    final kundaliAsync = ref.watch(kundaliProvider(profile));
    final now = DateTime.now();

    return RefreshIndicator(
      color: CosmicColors.gold,
      backgroundColor: CosmicColors.bgCard,
      onRefresh: () async {
        final panchang = panchangAsync.valueOrNull;
        final kundali = kundaliAsync.valueOrNull;

        // If data is already fully online, do nothing to save resources
        if ((panchang == null || !panchang.isOffline) &&
            (kundali == null || !kundali.isOffline)) {
          return;
        }

        // We have offline data. Force a refresh to try fetching online data.
        final repo = AstrologyRepository();
        await Future.wait([
          repo.getOrCalculateKundali(profile, forceRefresh: true),
          repo.getOrCalculatePanchang(
            profileId: profile.id!,
            dateLocal: DateTime.now(),
            latitude: profile.latitude,
            longitude: profile.longitude,
            utcOffsetMinutes: 330,
            forceRefresh: true,
          ),
        ]);

        // Invalidate providers so they rebuild with the new cached online data
        ref.invalidate(panchangProvider(profile));
        ref.invalidate(kundaliProvider(profile));
        
        // Wait for UI to update
        await Future.wait([
          ref.read(panchangProvider(profile).future),
          ref.read(kundaliProvider(profile).future),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App bar
        SliverAppBar(
          expandedHeight: 160,
          backgroundColor: Colors.transparent,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(now.hour),
                            style: TextStyle(
                              fontFamily: CosmicTypography.inter,
                              fontSize: 13,
                              color: CosmicColors.textMed,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                CosmicColors.goldGradient.createShader(bounds),
                            child: Text(
                              profile.name.split(' ').first,
                              style: TextStyle(
                                fontFamily: CosmicTypography.cinzel,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Profile avatar
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.profiles),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: CosmicColors.goldGradient,
                            boxShadow: [
                              BoxShadow(
                                color: CosmicColors.gold.withValues(alpha: 0.3),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              profile.initials,
                              style: TextStyle(
                                fontFamily: CosmicTypography.cinzel,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: CosmicColors.bgDeep,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Today's Panchang card ──
              panchangAsync.when(
                loading: () => _SectionSkeleton(height: 160),
                error: (_, __) => const SizedBox.shrink(),
                data: (panchang) => panchang != null
                    ? _PanchangCard(panchang: panchang)
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // ── Quick Actions ──
              _SectionHeader(title: 'Explore', onSeeAll: null),
              const SizedBox(height: 12),
              _QuickActionsGrid(),

              const SizedBox(height: 16),

              // ── Kundali Summary ──
              kundaliAsync.when(
                loading: () => _SectionSkeleton(height: 120),
                error: (_, __) => const SizedBox.shrink(),
                data: (kundali) => kundali != null
                    ? _KundaliSummaryCard(kundali: kundali, profile: profile)
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // ── Daily wisdom quote ──
              _DailyWisdomCard(dayOfYear: now.difference(DateTime(now.year)).inDays),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    ),
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    if (hour < 21) return 'Good Evening,';
    return 'Good Night,';
  }
}

// ─── Panchang Card ─────────────────────────────────────────────────────────

class _PanchangCard extends StatelessWidget {
  final Panchang panchang;
  const _PanchangCard({required this.panchang});

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      glowGold: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Panchang",
                    style: TextStyle(
                      fontFamily: CosmicTypography.cinzel,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CosmicColors.gold,
                    ),
                  ),
                ],
              ),
              Text(
                panchang.isShuklapaksha ? 'Shukla Paksha ☽' : 'Krishna Paksha 🌑',
                style: TextStyle(
                  fontFamily: CosmicTypography.inter,
                  fontSize: 11,
                  color: CosmicColors.textHigh,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _PInfo('Tithi', panchang.tithi)),
              Expanded(child: _PInfo('Vara', panchang.varaEnglish)),
              Expanded(child: _PInfo('Nakshatra', panchang.nakshatra)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _PInfo('Yoga', panchang.yoga)),
              Expanded(child: _PInfo('Karana', panchang.karana)),
              Expanded(
                child: _PInfo(
                  'Rahu Kalam',
                  '${panchang.rahuKalamStart}-${panchang.rahuKalamEnd}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PInfo extends StatelessWidget {
  final String label;
  final String value;
  const _PInfo(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: CosmicTypography.inter,
            fontSize: 11,
            color: CosmicColors.textMed,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: CosmicTypography.inter,
            fontSize: 13,
            color: CosmicColors.textHigh,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── Quick Actions Grid ────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  final _actions = const [
    (Icons.auto_graph_rounded, 'Kundali', CosmicColors.indigo, AppRoutes.kundali),
    (Icons.filter_9_plus_rounded, 'Numerology', CosmicColors.saffron, AppRoutes.numerology),
    (Icons.favorite_rounded, 'Compat.', CosmicColors.maroon, AppRoutes.compatibility),
    (Icons.star_rounded, 'Horoscope', CosmicColors.gold, AppRoutes.horoscope),
    (Icons.auto_awesome_rounded, 'Zodiacs', CosmicColors.sun, AppRoutes.zodiacTraits),
    (Icons.school_rounded, 'Learn', CosmicColors.jupiter, AppRoutes.education),
  ];

  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _actions.length,
      itemBuilder: (context, i) {
        final (icon, label, color, route) = _actions[i];
        return _ActionTile(
          icon: icon,
          label: label,
          color: color,
          onTap: () {
            if (route == AppRoutes.kundali || route == AppRoutes.numerology || route == AppRoutes.compatibility || route == AppRoutes.panchang) {
              context.go(route);
            } else {
              context.push(route);
            }
          },
        );
      },
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: CosmicColors.bgCard,
            border: Border.all(
              color: widget.color.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: CosmicTypography.inter,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: CosmicColors.textMed,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Kundali Summary ───────────────────────────────────────────────────────

class _KundaliSummaryCard extends StatelessWidget {
  final Kundali kundali;
  final UserProfile profile;

  const _KundaliSummaryCard({required this.kundali, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Cosmic Snapshot',
          onSeeAll: () => context.go(AppRoutes.kundali),
        ),
        const SizedBox(height: 12),
        CosmicGradientCard(
          colors: [
            const Color(0xFF0F1B3D),
            const Color(0xFF1A0F3D),
          ],
          child: Row(
            children: [
              Expanded(
                child: _CosmicInfo('Sun Sign', kundali.sunSign, '☉'),
              ),
              _vDivider(),
              Expanded(
                child: _CosmicInfo('Moon Sign', kundali.moonSign, '☽'),
              ),
              _vDivider(),
              Expanded(
                child: _CosmicInfo('Ascendant', kundali.ascendantSign, '↑'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        CosmicCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _CosmicInfo(
                  'Nakshatra',
                  kundali.moonNakshatra,
                  '✦',
                ),
              ),
              _vDivider(),
              Expanded(
                child: _CosmicInfo(
                  'Pada',
                  '${kundali.moonNakshatraPada}${_ordinal(kundali.moonNakshatraPada)}',
                  '◎',
                ),
              ),
              _vDivider(),
              Expanded(
                child: _CosmicInfo(
                  'Ayanamsa',
                  '${kundali.ayanamsa.toStringAsFixed(2)}°',
                  '⊛',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 50,
        color: CosmicColors.gold.withValues(alpha: 0.15),
      );

  String _ordinal(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}

class _CosmicInfo extends StatelessWidget {
  final String label;
  final String value;
  final String symbol;
  const _CosmicInfo(this.label, this.value, this.symbol);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(symbol,
            style: const TextStyle(fontSize: 16, color: CosmicColors.gold)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: CosmicTypography.inter,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CosmicColors.textHigh,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: CosmicTypography.inter,
            fontSize: 10,
            color: CosmicColors.textLow,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Daily Wisdom Card ─────────────────────────────────────────────────────

class _DailyWisdomCard extends StatelessWidget {
  final int dayOfYear;
  const _DailyWisdomCard({required this.dayOfYear});

  @override
  Widget build(BuildContext context) {
    final quotes = [
      ('As above, so below; as within, so without.', 'Hermetic Principle'),
      ('The stars incline, they do not compel.', 'Vedic Wisdom'),
      ('Know thyself and thou shalt know all the mysteries of the gods.',
          'Ancient Oracle'),
      ('Your birth chart is your cosmic blueprint — not your prison.',
          'Jyotish Teaching'),
      ('Every soul has its own unique melody in the cosmic symphony.',
          'Upanishads'),
      ('The planets do not cause events — they reflect them.',
          'Parashara Hora Shastra'),
      ('In the seed of today lies the fruit of tomorrow.', 'Vedic Proverb'),
    ];

    final quote = quotes[dayOfYear % quotes.length];

    return CosmicCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A0E1E), Color(0xFF12103A)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Cosmic Wisdom',
                style: TextStyle(
                  fontFamily: CosmicTypography.cinzel,
                  fontSize: 12,
                  color: CosmicColors.gold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${quote.$1}"',
            style: TextStyle(
              fontFamily: CosmicTypography.cormorant,
              fontSize: 17,
              fontStyle: FontStyle.italic,
              color: CosmicColors.textHigh,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${quote.$2}',
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 11,
                color: CosmicColors.textMed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── UI Helpers ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: CosmicTypography.cinzel,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: CosmicColors.textHigh,
            letterSpacing: 0.3,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 12,
                color: CosmicColors.gold,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  final double height;
  const _SectionSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CosmicColors.bgCard,
      ),
    );
  }
}
