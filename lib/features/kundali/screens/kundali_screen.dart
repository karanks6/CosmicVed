import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../models/models.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../constants/astrology_constants.dart';
import '../../../services/astrology/panchang_service.dart';
import 'kundali_chart_painter.dart';

class KundaliScreen extends ConsumerWidget {
  const KundaliScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        starCount: 60,
        enableNebula: true,
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: CosmicColors.gold),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('No profile found'));
            }
            return _KundaliContent(profile: profile);
          },
        ),
      ),
    );
  }
}

class _KundaliContent extends ConsumerWidget {
  final dynamic profile;
  const _KundaliContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kundaliAsync = ref.watch(kundaliProvider(profile));

    return kundaliAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: CosmicColors.gold),
            SizedBox(height: 16),
            Text(
              'Calculating Kundali...',
              style: TextStyle(
                fontFamily: 'Inter',
                color: CosmicColors.textMed,
              ),
            ),
          ],
        ),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (kundali) {
        if (kundali == null) return const SizedBox.shrink();
        return _KundaliView(kundali: kundali);
      },
    );
  }
}

class _KundaliView extends StatefulWidget {
  final Kundali kundali;
  const _KundaliView({required this.kundali});

  @override
  State<_KundaliView> createState() => _KundaliViewState();
}

class _KundaliViewState extends State<_KundaliView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _chartStyle = 'north';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            'Birth Chart',
            style: TextStyle(
              fontFamily: CosmicTypography.cinzel,
              fontSize: 20,
              color: CosmicColors.textHigh,
            ),
          ),
          backgroundColor: Colors.transparent,
          floating: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.tune_rounded, color: CosmicColors.gold),
              color: CosmicColors.bgCard,
              onSelected: (v) => setState(() => _chartStyle = v),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'north', child: Text('North Indian', style: TextStyle(color: CosmicColors.textHigh))),
                PopupMenuItem(value: 'south', child: Text('South Indian', style: TextStyle(color: CosmicColors.textHigh))),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Chart'),
              Tab(text: 'Planets'),
              Tab(text: 'Details'),
            ],
          ),
        ),

        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ChartTab(kundali: widget.kundali, style: _chartStyle),
              _PlanetsTab(kundali: widget.kundali),
              _DetailsTab(kundali: widget.kundali),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── North Indian Chart Painter ────────────────────────────────────────────

class _ChartTab extends StatelessWidget {
  final Kundali kundali;
  final String style;

  const _ChartTab({required this.kundali, required this.style});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CosmicCard(
            padding: const EdgeInsets.all(16),
            glowGold: true,
            child: Column(
              children: [
                Text(
                  'Rashi Chart (D1)',
                  style: TextStyle(
                    fontFamily: CosmicTypography.cinzel,
                    fontSize: 14,
                    color: CosmicColors.gold,
                  ),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.0,
                  child: CustomPaint(
                    painter: KundaliChartPainter(
                      kundali: kundali,
                      style: style,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          CosmicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ascendant: ${kundali.ascendantSign} ${kundali.ascendantDegrees.toStringAsFixed(1)}°',
                  style: TextStyle(
                    fontFamily: CosmicTypography.inter,
                    fontSize: 13,
                    color: CosmicColors.textHigh,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ayanamsa (Lahiri): ${kundali.ayanamsa.toStringAsFixed(4)}°',
                  style: TextStyle(
                    fontFamily: CosmicTypography.inter,
                    fontSize: 12,
                    color: CosmicColors.textMed,
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



// ─── Planets Table ─────────────────────────────────────────────────────────

class _PlanetsTab extends StatelessWidget {
  final Kundali kundali;
  const _PlanetsTab({required this.kundali});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _TableHeader(),
              ...kundali.planets.asMap().entries.map((e) => _PlanetRow(
                    planet: e.value,
                    index: e.key,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: CosmicColors.gold.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: ['Planet', 'Sign', 'Deg', 'House', 'Nakshatra']
            .asMap()
            .entries
            .map((e) => Expanded(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CosmicColors.gold,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _PlanetRow extends StatelessWidget {
  final PlanetPosition planet;
  final int index;
  const _PlanetRow({required this.planet, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = AstrologyConstants.getColorForPlanet(planet.name);
    const rashis = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CosmicColors.gold.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 6),
                Text(
                  planet.name,
                  style: TextStyle(
                    fontFamily: CosmicTypography.inter,
                    fontSize: 11,
                    color: CosmicColors.textHigh,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              rashis[planet.rashiIndex],
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 11,
                color: CosmicColors.textMed,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${planet.rashiDegrees.toStringAsFixed(1)}°'
              '${planet.isRetrograde ? 'R' : ''}',
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 11,
                color: planet.isRetrograde
                    ? CosmicColors.saffron
                    : CosmicColors.textMed,
              ),
            ),
          ),
          Expanded(
            child: Text(
              planet.houseNumber.toString(),
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 11,
                color: CosmicColors.textMed,
              ),
            ),
          ),
          Expanded(
            child: Text(
              planet.nakshatra ?? '-',
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 10,
                color: CosmicColors.textLow,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Kundali Details Tab ───────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  final Kundali kundali;
  const _DetailsTab({required this.kundali});

  @override
  Widget build(BuildContext context) {
    const rashis = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetailCard('Ascendant (Lagna)', [
          ('Sign', rashis[kundali.ascendantRashiIndex]),
          ('Degree', '${kundali.ascendantDegrees.toStringAsFixed(2)}°'),
          ('Lord', _signLord(kundali.ascendantRashiIndex)),
        ]),
        const SizedBox(height: 12),
        _DetailCard('Moon Position', [
          ('Sign', kundali.moonSign),
          ('Nakshatra', kundali.moonNakshatra),
          ('Pada', '${kundali.moonNakshatraPada}'),
          ('Nakshatra Lord', _nakshatraLord(kundali.moonNakshatra)),
        ]),
        const SizedBox(height: 12),
        _DetailCard('Sun Position', [
          ('Sign', kundali.sunSign),
          ('Degree', '${kundali.planets[0].rashiDegrees.toStringAsFixed(2)}°'),
          ('Nakshatra', kundali.planets[0].nakshatra ?? '-'),
        ]),
        const SizedBox(height: 12),
        _DetailCard('Calculation Details', [
          ('System', 'Vedic (Jyotish)'),
          ('Ayanamsa', 'Lahiri (Chitrapaksha)'),
          ('Ayanamsa Value', '${kundali.ayanamsa.toStringAsFixed(4)}°'),
          ('House System', 'Equal House'),
          ('Calculated', kundali.calculatedAt.toLocal().toString().split('.').first),
        ]),
      ],
    );
  }

  String _signLord(int rashiIdx) {
    final lords = ['Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury',
        'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter'];
    return lords[rashiIdx];
  }

  String _nakshatraLord(String nakshatra) {
    final idx = AstrologyConstants.nakshatras.indexOf(nakshatra);
    if (idx < 0) return '-';
    return AstrologyConstants.nakshatraLords[idx];
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<(String, String)> items;
  const _DetailCard(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: CosmicTypography.cinzel,
              fontSize: 13,
              color: CosmicColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.$1,
                      style: TextStyle(
                        fontFamily: CosmicTypography.inter,
                        fontSize: 12,
                        color: CosmicColors.textLow,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontFamily: CosmicTypography.inter,
                        fontSize: 12,
                        color: CosmicColors.textHigh,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
