import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../services/astrology/astrology_api_service.dart';
import '../../../models/models.dart';
import '../../dashboard/screens/dashboard_screen.dart';

// ─── Remedy Data Model ──────────────────────────────────────────────────────

class _PlanetRemedy {
  final String planet;
  final String colorHex;
  final String emoji;
  final String gemstone;
  final String metal;
  final String mantra;
  final String deity;
  final String day;
  final List<String> foods;
  final List<String> colors;
  final String description;

  const _PlanetRemedy({
    required this.planet,
    required this.colorHex,
    required this.emoji,
    required this.gemstone,
    required this.metal,
    required this.mantra,
    required this.deity,
    required this.day,
    required this.foods,
    required this.colors,
    required this.description,
  });

  Color get color {
    final h = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

const _remedyData = <String, _PlanetRemedy>{
  'Sun': _PlanetRemedy(
    planet: 'Sun (Surya)', colorHex: 'FFB347', emoji: '☉',
    gemstone: 'Ruby (Manik)', metal: 'Gold',
    mantra: 'Om Hraam Hreem Hraum Sah Suryaya Namah',
    deity: 'Lord Surya', day: 'Sunday',
    foods: ['Wheat', 'Jaggery', 'Saffron', 'Oranges'],
    colors: ['Gold', 'Orange', 'Deep Yellow'],
    description: 'Strengthen the Sun to enhance authority, self-confidence, career success, and vitality. Beneficial for leadership roles and government services.',
  ),
  'Moon': _PlanetRemedy(
    planet: 'Moon (Chandra)', colorHex: 'C0C0C0', emoji: '☽',
    gemstone: 'Pearl (Moti)', metal: 'Silver',
    mantra: 'Om Shraam Shreem Shraum Sah Chandraya Namah',
    deity: 'Lord Shiva', day: 'Monday',
    foods: ['Milk', 'Rice', 'White Sugar', 'Coconut'],
    colors: ['White', 'Silver', 'Pale Blue'],
    description: 'Strengthen the Moon to improve emotional balance, mental peace, intuition, and relationships with the mother.',
  ),
  'Mars': _PlanetRemedy(
    planet: 'Mars (Mangal)', colorHex: 'FF4500', emoji: '♂',
    gemstone: 'Red Coral (Moonga)', metal: 'Copper',
    mantra: 'Om Kraam Kreem Kraum Sah Bhaumaya Namah',
    deity: 'Lord Hanuman', day: 'Tuesday',
    foods: ['Red Lentils', 'Pomegranate', 'Beetroot', 'Red Berries'],
    colors: ['Red', 'Scarlet', 'Crimson'],
    description: 'Strengthen Mars to enhance courage, energy, ambition, and athletic ability. Beneficial for property matters and overcoming enemies.',
  ),
  'Mercury': _PlanetRemedy(
    planet: 'Mercury (Budha)', colorHex: '50C878', emoji: '☿',
    gemstone: 'Emerald (Panna)', metal: 'Bronze',
    mantra: 'Om Braam Breem Braum Sah Budhaya Namah',
    deity: 'Goddess Saraswati', day: 'Wednesday',
    foods: ['Green Moong', 'Spinach', 'Cucumber', 'Green Grapes'],
    colors: ['Green', 'Emerald', 'Light Blue'],
    description: 'Strengthen Mercury to improve intelligence, communication, business acumen, and learning abilities.',
  ),
  'Jupiter': _PlanetRemedy(
    planet: 'Jupiter (Guru)', colorHex: 'FFD700', emoji: '♃',
    gemstone: 'Yellow Sapphire (Pukhraj)', metal: 'Gold',
    mantra: 'Om Graam Greem Graum Sah Gurave Namah',
    deity: 'Lord Brahma', day: 'Thursday',
    foods: ['Chana Dal', 'Turmeric', 'Banana', 'Yellow Foods'],
    colors: ['Yellow', 'Gold', 'Cream'],
    description: 'Strengthen Jupiter to enhance wisdom, spirituality, wealth, and good fortune. Beneficial for teachers and those seeking higher knowledge.',
  ),
  'Venus': _PlanetRemedy(
    planet: 'Venus (Shukra)', colorHex: 'FFB6C1', emoji: '♀',
    gemstone: 'Diamond / White Sapphire', metal: 'Silver',
    mantra: 'Om Draam Dreem Draum Sah Shukraya Namah',
    deity: 'Goddess Lakshmi', day: 'Friday',
    foods: ['White Rice', 'Milk', 'Sugar', 'White Flowers'],
    colors: ['White', 'Pink', 'Pastel'],
    description: 'Strengthen Venus to enhance love, beauty, artistic talent, luxury, and marital happiness.',
  ),
  'Saturn': _PlanetRemedy(
    planet: 'Saturn (Shani)', colorHex: '708090', emoji: '♄',
    gemstone: 'Blue Sapphire (Neelam)', metal: 'Iron / Steel',
    mantra: 'Om Praam Preem Praum Sah Shanaischaraya Namah',
    deity: 'Lord Shiva / Lord Yama', day: 'Saturday',
    foods: ['Black Sesame', 'Mustard Oil', 'Black Urad', 'Iron-rich Foods'],
    colors: ['Black', 'Dark Blue', 'Dark Purple'],
    description: 'Propitiate Saturn to reduce delays, obstacles, and hardships. Essential during Sade Sati. Promotes discipline and longevity.',
  ),
  'Rahu': _PlanetRemedy(
    planet: 'Rahu (North Node)', colorHex: '800080', emoji: '☊',
    gemstone: 'Hessonite Garnet (Gomed)', metal: 'Lead / Ashtadhatu',
    mantra: 'Om Bhram Bhreem Bhraum Sah Rahave Namah',
    deity: 'Goddess Durga', day: 'Saturday',
    foods: ['Black Foods', 'Coconut', 'Barley', 'Mustard'],
    colors: ['Smoky Grey', 'Dark Blue', 'Ultraviolet'],
    description: 'Propitiate Rahu to overcome obsessions, illusions, and sudden disruptions. Associated with technology and unconventional paths.',
  ),
  'Ketu': _PlanetRemedy(
    planet: 'Ketu (South Node)', colorHex: 'A0522D', emoji: '☋',
    gemstone: "Cat's Eye (Lahsuniya)", metal: 'Iron / Ashtadhatu',
    mantra: 'Om Sraam Sreem Sraum Sah Ketave Namah',
    deity: 'Lord Ganesha', day: 'Tuesday',
    foods: ['Brown Rice', 'Sesame', 'Black Gram', 'Roots'],
    colors: ['Brown', 'Smoky', 'Dark Red'],
    description: 'Propitiate Ketu to overcome spiritual confusion and past-life karmas. Governs moksha, spiritual liberation, and occult sciences.',
  ),
};

// ─── Remedies Screen ────────────────────────────────────────────────────────

class RemediesScreen extends ConsumerStatefulWidget {
  const RemediesScreen({super.key});

  @override
  ConsumerState<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends ConsumerState<RemediesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        starCount: 50,
        enableNebula: true,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                'Vedic Remedies',
                style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 20, color: CosmicColors.textHigh),
              ),
              backgroundColor: Colors.transparent,
              pinned: true,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: CosmicColors.gold,
                labelColor: CosmicColors.gold,
                unselectedLabelColor: CosmicColors.textMed,
                labelStyle: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 12),
                tabs: const [Tab(text: 'My Remedies'), Tab(text: 'All Planets')],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  profileAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: CosmicColors.gold)),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (profile) => profile == null ? _NoProfile() : _PersonalizedRemedies(profile: profile),
                  ),
                  _AllPlanetsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Personalized Remedies ──────────────────────────────────────────────────

class _PersonalizedRemedies extends StatelessWidget {
  final dynamic profile;
  const _PersonalizedRemedies({required this.profile});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Kundali?>(
      future: AstrologyApiService.instance.fetchKundali(profile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: CosmicColors.gold));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        }
        
        final kundali = snapshot.data;
        if (kundali == null) {
          return const Center(child: Text('Failed to calculate chart.', style: TextStyle(color: Colors.white)));
        }

        final weakPlanets = kundali.planets
            .where((p) => p.isDebilitated || p.isRetrograde)
            .map((p) => p.name)
            .toList();

        final ascLordName = _ascendantLordName(kundali.ascendantRashiIndex);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            CosmicGradientCard(
              colors: const [Color(0xFF0F1B3D), Color(0xFF2D1B69)],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🕉️', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Personalized Remedies',
                              style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 15, color: CosmicColors.gold, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('Based on ${profile.name}\'s birth chart',
                              style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textMed)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Chip('↑ ${kundali.ascendantSign}'),
                      _Chip('☽ ${kundali.moonSign}'),
                      _Chip('⚡ $ascLordName'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (weakPlanets.isNotEmpty) ...[
              _SectionTitle('Priority Remedies', 'Debilitated or retrograde planets'),
              const SizedBox(height: 12),
              ...weakPlanets.map((p) {
                final r = _remedyData[p];
                if (r == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RemedyCard(remedy: r, badge: 'Needs Attention'),
                );
              }),
              const SizedBox(height: 16),
            ],

            _SectionTitle('Lagna Lord Remedy', 'Strengthen your ascendant ruler'),
            const SizedBox(height: 12),
            if (_remedyData[ascLordName] != null)
              _RemedyCard(remedy: _remedyData[ascLordName]!),
          ],
        );
      },
    );
  }

  String _ascendantLordName(int idx) {
    const lords = ['Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury',
      'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter'];
    return lords[idx % 12];
  }
}

// ─── All Planets Tab ─────────────────────────────────────────────────────────

class _AllPlanetsTab extends StatefulWidget {
  @override
  State<_AllPlanetsTab> createState() => _AllPlanetsTabState();
}

class _AllPlanetsTabState extends State<_AllPlanetsTab> {
  String? _expanded;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        ..._remedyData.values.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ExpandableRemedyCard(
            remedy: r,
            isExpanded: _expanded == r.planet,
            onToggle: () => setState(() =>
              _expanded = _expanded == r.planet ? null : r.planet),
          ),
        )),
      ],
    );
  }
}

// ─── Remedy Card ─────────────────────────────────────────────────────────────

class _RemedyCard extends StatelessWidget {
  final _PlanetRemedy remedy;
  final String? badge;
  const _RemedyCard({required this.remedy, this.badge});

  @override
  Widget build(BuildContext context) {
    final c = remedy.color;
    return CosmicCard(
      padding: const EdgeInsets.all(16),
      tint: c.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PlanetCircle(emoji: remedy.emoji, color: c),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(remedy.planet, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 15, color: CosmicColors.textHigh, fontWeight: FontWeight.w600)),
                  Text('Worship on ${remedy.day}', style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: c)),
                ],
              )),
              if (badge != null) _Badge(badge!, color: CosmicColors.maroon),
            ],
          ),
          const SizedBox(height: 12),
          Text(remedy.description, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed, height: 1.5)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _RemedyBadge('💎', remedy.gemstone, c),
            _RemedyBadge('⚙️', remedy.metal, c),
            _RemedyBadge('🙏', remedy.deity, c),
          ]),
          const SizedBox(height: 12),
          _MantraBox(remedy.mantra, c),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _ListBlock('Colors', remedy.colors, '🎨', c)),
            const SizedBox(width: 10),
            Expanded(child: _ListBlock('Foods', remedy.foods, '🌿', c)),
          ]),
        ],
      ),
    );
  }
}

class _ExpandableRemedyCard extends StatelessWidget {
  final _PlanetRemedy remedy;
  final bool isExpanded;
  final VoidCallback onToggle;
  const _ExpandableRemedyCard({required this.remedy, required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final c = remedy.color;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: CosmicCard(
          padding: const EdgeInsets.all(16),
          tint: isExpanded ? c.withValues(alpha: 0.06) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PlanetCircle(emoji: remedy.emoji, color: c, size: 38),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(remedy.planet, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.textHigh, fontWeight: FontWeight.w600)),
                      Text(remedy.gemstone, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: c)),
                    ],
                  )),
                  Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: CosmicColors.gold),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 14),
                Text(remedy.description, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed, height: 1.5)),
                const SizedBox(height: 12),
                _MantraBox(remedy.mantra, c),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _RemedyBadge('💎', remedy.gemstone, c),
                  _RemedyBadge('⚙️', remedy.metal, c),
                  _RemedyBadge('🙏', remedy.deity, c),
                  _RemedyBadge('📅', remedy.day, c),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _PlanetCircle extends StatelessWidget {
  final String emoji;
  final Color color;
  final double size;
  const _PlanetCircle({required this.emoji, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.15),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.45))),
  );
}

class _MantraBox extends StatelessWidget {
  final String mantra;
  final Color color;
  const _MantraBox(this.mantra, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color.withValues(alpha: 0.08),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mantra', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 10, color: color, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(mantra, style: TextStyle(fontFamily: CosmicTypography.cormorant, fontSize: 14, color: CosmicColors.textHigh, fontStyle: FontStyle.italic, height: 1.4)),
      ],
    ),
  );
}

class _RemedyBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _RemedyBadge(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textHigh, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _ListBlock extends StatelessWidget {
  final String title;
  final List<String> items;
  final String icon;
  final Color color;
  const _ListBlock(this.title, this.items, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color.withValues(alpha: 0.06),
      border: Border.all(color: color.withValues(alpha: 0.15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$icon $title', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 10, color: color, letterSpacing: 0.3)),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text('• $item', style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textMed)),
        )),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: CosmicColors.gold.withValues(alpha: 0.1),
      border: Border.all(color: CosmicColors.gold.withValues(alpha: 0.2)),
    ),
    child: Text(label, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textHigh)),
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, {required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color.withValues(alpha: 0.2),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Text(label, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 10, color: color)),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.textHigh, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(subtitle, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textMed)),
    ],
  );
}

class _NoProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: CosmicCard(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🔮', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('Create a Profile First', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 18, color: CosmicColors.textHigh)),
        const SizedBox(height: 8),
        Text('Personalized remedies are calculated from your birth chart.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 13, color: CosmicColors.textMed)),
      ]),
    ),
  );
}
