import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../models/models.dart';
import '../../dashboard/screens/dashboard_screen.dart';

// ─── Health Insight Data ─────────────────────────────────────────────────────

class _HealthInsight {
  final String planet;
  final String emoji;
  final String bodySystem;
  final List<String> governs;
  final List<String> weaknessSymptoms;
  final List<String> remedies;
  const _HealthInsight({
    required this.planet, required this.emoji, required this.bodySystem,
    required this.governs, required this.weaknessSymptoms, required this.remedies,
  });
}

const _healthData = <String, _HealthInsight>{
  'Sun': _HealthInsight(
    planet: 'Sun', emoji: '☉', bodySystem: 'Cardiovascular & Immunity',
    governs: ['Heart', 'Spine', 'Eyes', 'Vitality', 'Immune System', 'Bone Marrow'],
    weaknessSymptoms: ['Fatigue & low energy', 'Eye problems', 'Heart irregularities', 'Low self-esteem', 'Vitamin D deficiency'],
    remedies: ['Early morning sun exposure', 'Heart-healthy diet', 'Regular exercise', 'Positive affirmations', 'Ruby or Surya Namaskara'],
  ),
  'Moon': _HealthInsight(
    planet: 'Moon', emoji: '☽', bodySystem: 'Mind & Fluids',
    governs: ['Mind', 'Breasts', 'Stomach', 'Lymphatic System', 'Body Fluids', 'Emotional Health'],
    weaknessSymptoms: ['Anxiety & mood swings', 'Digestive issues', 'Water retention', 'Insomnia', 'Hormonal imbalances'],
    remedies: ['Stay hydrated', 'Meditation & yoga', 'Lunar diet (avoid excess during full moon)', 'Calming herbs: Ashwagandha', 'Pearl or moonstone'],
  ),
  'Mars': _HealthInsight(
    planet: 'Mars', emoji: '♂', bodySystem: 'Blood & Muscles',
    governs: ['Blood', 'Muscles', 'Bone Marrow', 'Adrenaline', 'Surgery', 'Acute Fevers'],
    weaknessSymptoms: ['Inflammatory conditions', 'Accidents & injuries', 'High blood pressure', 'Anger management issues', 'Iron deficiency'],
    remedies: ['Iron-rich diet', 'Channel energy through sports', 'Red Coral gemstone', 'Avoid overexertion', 'Hanuman Chalisa recitation'],
  ),
  'Mercury': _HealthInsight(
    planet: 'Mercury', emoji: '☿', bodySystem: 'Nervous System',
    governs: ['Brain', 'Nervous System', 'Speech', 'Lungs', 'Skin', 'Thyroid'],
    weaknessSymptoms: ['Anxiety & nervousness', 'Speech disorders', 'Skin conditions', 'Respiratory issues', 'Memory problems'],
    remedies: ['Pranayama & breathwork', 'Mental exercises & puzzles', 'Green diet', 'Emerald or jade', 'Omega-3 fatty acids'],
  ),
  'Jupiter': _HealthInsight(
    planet: 'Jupiter', emoji: '♃', bodySystem: 'Liver & Growth',
    governs: ['Liver', 'Pancreas', 'Fat Metabolism', 'Growth', 'Blood Circulation', 'Arterial System'],
    weaknessSymptoms: ['Liver disorders', 'Obesity & weight gain', 'Diabetes risk', 'Excessive optimism leading to neglect', 'Cholesterol issues'],
    remedies: ['Liver-cleansing diet', 'Avoid excess fats & sweets', 'Yellow Sapphire', 'Fasting on Thursdays', 'Turmeric & curcumin'],
  ),
  'Venus': _HealthInsight(
    planet: 'Venus', emoji: '♀', bodySystem: 'Reproductive & Endocrine',
    governs: ['Reproductive System', 'Kidneys', 'Skin Beauty', 'Throat', 'Hormones', 'Thymus Gland'],
    weaknessSymptoms: ['Kidney & bladder issues', 'Skin disorders', 'Reproductive problems', 'Low libido', 'Throat infections'],
    remedies: ['Adequate hydration', 'Kidney-supporting herbs', 'Diamond or opal', 'Rose-based aromatherapy', 'Avoid excessive sugar'],
  ),
  'Saturn': _HealthInsight(
    planet: 'Saturn', emoji: '♄', bodySystem: 'Skeletal & Chronic',
    governs: ['Bones & Teeth', 'Joints', 'Chronic Diseases', 'Skin (dryness)', 'Knees', 'Colon'],
    weaknessSymptoms: ['Arthritis & joint pain', 'Chronic fatigue', 'Constipation', 'Dental problems', 'Skin dryness & aging'],
    remedies: ['Calcium & Vitamin D supplementation', 'Joint-supportive yoga', 'Blue Sapphire (with caution)', 'Sesame oil massage', 'Shani mantra Saturdays'],
  ),
  'Rahu': _HealthInsight(
    planet: 'Rahu', emoji: '☊', bodySystem: 'Mysterious & Mental',
    governs: ['Subconscious Mind', 'Phobias', 'Skin Diseases', 'Infections', 'Poisoning', 'Epilepsy'],
    weaknessSymptoms: ['Unexplained illnesses', 'Mental confusion & phobias', 'Addiction tendencies', 'Viral & bacterial infections', 'Skin eruptions'],
    remedies: ['Detoxification & fasting', 'Spiritual practices', 'Hessonite Garnet', 'Avoid intoxicants', 'Durga Saptashati recitation'],
  ),
  'Ketu': _HealthInsight(
    planet: 'Ketu', emoji: '☋', bodySystem: 'Spiritual & Extremities',
    governs: ['Abdomen', 'Feet', 'Spiritual Diseases', 'Hereditary Conditions', 'Immune Disorders', 'Moksha'],
    weaknessSymptoms: ["Foot disorders", 'Autoimmune conditions', 'Spiritual crisis', 'Hereditary diseases', 'Malabsorption'],
    remedies: ["Cat's Eye gemstone", 'Grounding practices', 'Pilgrimage & seva', 'Barefoot walking on grass', 'Ganesha worship'],
  ),
};

// ─── Screen ──────────────────────────────────────────────────────────────────

class HealthInsightsScreen extends ConsumerWidget {
  const HealthInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        starCount: 45,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text('Health Insights',
                style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 20, color: CosmicColors.textHigh)),
              backgroundColor: Colors.transparent,
              floating: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: profileAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator(color: CosmicColors.gold)),
                ),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('$e'))),
                data: (profile) {
                  if (profile == null) {
                    return SliverToBoxAdapter(child: _NoProfile());
                  }
                  return _HealthContent(profile: profile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthContent extends StatelessWidget {
  final dynamic profile;
  const _HealthContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Intro card
        CosmicGradientCard(
          colors: const [Color(0xFF0D2B1F), Color(0xFF143D2E)],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('🌿', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ayurvedic Health Insights',
                      style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 15, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Based on planetary rulerships of body systems',
                      style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textMed)),
                  ],
                )),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.amber.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '⚠️ These insights are based on traditional Vedic astrology and are for educational purposes only. Consult a qualified healthcare professional for medical advice.',
                  style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: Colors.amber.shade300, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('All Planetary Health Zones',
          style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.textHigh, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._healthData.values.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HealthCard(insight: h),
        )),
      ]),
    );
  }
}

class _HealthCard extends StatefulWidget {
  final _HealthInsight insight;
  const _HealthCard({required this.insight});

  @override
  State<_HealthCard> createState() => _HealthCardState();
}

class _HealthCardState extends State<_HealthCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.insight;
    const green = Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: CosmicCard(
          padding: const EdgeInsets.all(16),
          tint: _expanded ? green.withValues(alpha: 0.04) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green.withValues(alpha: 0.12),
                    border: Border.all(color: green.withValues(alpha: 0.3)),
                  ),
                  child: Center(child: Text(h.emoji, style: const TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.planet, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.textHigh, fontWeight: FontWeight.w600)),
                    Text(h.bodySystem, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: green)),
                  ],
                )),
                Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: CosmicColors.gold),
              ]),

              if (_expanded) ...[
                const SizedBox(height: 14),
                Text('Governs', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 11, color: green, letterSpacing: 0.4)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 4,
                  children: h.governs.map((g) => _SmallChip(g, green)).toList()),
                const SizedBox(height: 14),
                _ExpandBlock('⚠️ Signs of Imbalance', h.weaknessSymptoms, const Color(0xFFFF7043)),
                const SizedBox(height: 10),
                _ExpandBlock('✅ Recommendations', h.remedies, green),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SmallChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Text(label, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 10, color: CosmicColors.textHigh)),
  );
}

class _ExpandBlock extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  const _ExpandBlock(this.title, this.items, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color.withValues(alpha: 0.07),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 11, color: color, letterSpacing: 0.3)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            Expanded(child: Text(item, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed))),
          ]),
        )),
      ],
    ),
  );
}

class _NoProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: CosmicCard(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🌿', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('Create a Profile First',
          style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 18, color: CosmicColors.textHigh)),
        const SizedBox(height: 8),
        Text('Health insights are personalized from your birth chart.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 13, color: CosmicColors.textMed)),
      ]),
    ),
  );
}
