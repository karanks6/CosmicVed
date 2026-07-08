import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../widgets/cosmic_button.dart';
import '../../../models/models.dart';
import '../../../models/user_profile.dart';
import '../../../repositories/profile_repository.dart';
import '../../../repositories/astrology_repository.dart';
import '../../../services/numerology/chaldean_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class CompatibilityHomeScreen extends ConsumerStatefulWidget {
  const CompatibilityHomeScreen({super.key});

  @override
  ConsumerState<CompatibilityHomeScreen> createState() => _CompatibilityHomeScreenState();
}

class _CompatibilityHomeScreenState extends ConsumerState<CompatibilityHomeScreen> {
  UserProfile? _personA;
  UserProfile? _personB;
  bool _calculating = false;
  Map<String, dynamic>? _results;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final active = await ProfileRepository().getActiveProfile();
    if (active.valueOrNull != null && mounted) {
      setState(() => _personA = active.valueOrNull);
    }
  }

  Future<void> _calculateMatch() async {
    if (_personA == null || _personB == null) return;
    
    setState(() {
      _calculating = true;
      _results = null;
    });

    try {
      final repo = AstrologyRepository();
      
      // Get Kundalis for both to extract Moon signs
      final kA = (await repo.getOrCalculateKundali(_personA!)).valueOrNull;
      final kB = (await repo.getOrCalculateKundali(_personB!)).valueOrNull;

      int signA = kA != null ? kA.planets.firstWhere((p) => p.name == 'Moon').rashiIndex : 0;
      int signB = kB != null ? kB.planets.firstWhere((p) => p.name == 'Moon').rashiIndex : 0;

      // Element arrays
      final elements = ['Fire', 'Earth', 'Air', 'Water'];
      String elementA = elements[signA % 4];
      String elementB = elements[signB % 4];

      // Elemental Compatibility (0.0 to 1.0)
      double elementalScore = 0.5;
      if (elementA == elementB) {
        elementalScore = 0.9;
      } else if ((elementA == 'Fire' && elementB == 'Air') || (elementA == 'Air' && elementB == 'Fire')) {
        elementalScore = 0.85;
      } else if ((elementA == 'Earth' && elementB == 'Water') || (elementA == 'Water' && elementB == 'Earth')) {
        elementalScore = 0.85;
      } else if ((elementA == 'Fire' && elementB == 'Water') || (elementA == 'Water' && elementB == 'Fire')) {
        elementalScore = 0.3;
      } else {
        elementalScore = 0.6;
      }

      // Numerology Compatibility
      final numA = ChaldeanService.instance.calculateLifePath(_personA!.dateOfBirth).number;
      final numB = ChaldeanService.instance.calculateLifePath(_personB!.dateOfBirth).number;
      final numScore = ChaldeanService.instance.numerologyCompatibility(numA, numB);

      // Final Score
      final finalScore = (elementalScore * 0.5) + (numScore * 0.5);
      final percentage = (finalScore * 100).round();

      String verdict = '';
      String strengths = '';
      String challenges = '';

      if (percentage >= 80) {
        verdict = 'Excellent Match';
        strengths = 'Deep soul connection, natural understanding, and mutual respect.';
        challenges = 'Maintaining individuality inside such a close bond.';
      } else if (percentage >= 60) {
        verdict = 'Good Match';
        strengths = 'Strong friendship foundation and willingness to cooperate.';
        challenges = 'Occasional miscommunications requiring patience.';
      } else if (percentage >= 40) {
        verdict = 'Challenging Match';
        strengths = 'Opportunities for massive personal growth and learning.';
        challenges = 'Fundamentally different approaches to emotions and life goals.';
      } else {
        verdict = 'Karmic Match';
        strengths = 'Intense initial attraction and karmic lessons.';
        challenges = 'High friction, requires immense compromise to sustain.';
      }

      if (mounted) {
        setState(() {
          _results = {
            'score': percentage,
            'verdict': verdict,
            'strengths': strengths,
            'challenges': challenges,
            'elementA': elementA,
            'elementB': elementB,
            'numA': numA,
            'numB': numB,
          };
          _calculating = false;
        });
      }
    } catch (e) {
      setState(() => _calculating = false);
    }
  }

  void _selectProfile(bool isPersonA) async {
    final profiles = (await ProfileRepository().getAllProfiles()).valueOrNull ?? [];
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: CosmicColors.bgDeep,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Select Profile', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 18, color: CosmicColors.textHigh)),
          const SizedBox(height: 16),
          ...profiles.map((p) => ListTile(
            title: Text(p.name, style: const TextStyle(color: CosmicColors.textHigh)),
            subtitle: Text(p.birthCity, style: const TextStyle(color: CosmicColors.textMed)),
            onTap: () {
              setState(() {
                if (isPersonA) _personA = p;
                else _personB = p;
                _results = null; // Clear old results
              });
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      appBar: AppBar(
        title: Text('Cosmic Match', style: TextStyle(fontFamily: CosmicTypography.cinzel, color: CosmicColors.textHigh)),
        backgroundColor: Colors.transparent,
      ),
      body: StarFieldBackground(
        starCount: 40,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Selectors
            Row(
              children: [
                Expanded(child: _ProfileSelector(
                  title: 'Person A',
                  profile: _personA,
                  onTap: () => _selectProfile(true),
                )),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('❤️', style: TextStyle(fontSize: 24)),
                ),
                Expanded(child: _ProfileSelector(
                  title: 'Person B',
                  profile: _personB,
                  onTap: () => _selectProfile(false),
                )),
              ],
            ),
            const SizedBox(height: 24),
            
            CosmicButton(
              label: 'Calculate Compatibility',
              onPressed: (_personA != null && _personB != null && !_calculating) ? _calculateMatch : null,
              width: double.infinity,
            ),
            
            const SizedBox(height: 32),
            
            if (_calculating)
              const Center(child: CircularProgressIndicator(color: CosmicColors.gold)),

            if (_results != null)
              _ResultsCard(results: _results!, personA: _personA!, personB: _personB!),
          ],
        ),
      ),
    );
  }
}

class _ProfileSelector extends StatelessWidget {
  final String title;
  final UserProfile? profile;
  final VoidCallback onTap;

  const _ProfileSelector({required this.title, required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CosmicColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: profile != null ? CosmicColors.gold : CosmicColors.gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed)),
            const SizedBox(height: 8),
            if (profile != null) ...[
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: CosmicColors.goldGradient),
                child: Center(child: Text(profile!.initials, style: TextStyle(fontFamily: CosmicTypography.cinzel, color: CosmicColors.bgDeep, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 8),
              Text(profile!.name.split(' ')[0], style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.textHigh, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ] else ...[
              const Icon(Icons.person_add_alt_1_rounded, color: CosmicColors.gold, size: 32),
              const SizedBox(height: 8),
              Text('Select', style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 14, color: CosmicColors.gold)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  final Map<String, dynamic> results;
  final UserProfile personA;
  final UserProfile personB;

  const _ResultsCard({required this.results, required this.personA, required this.personB});

  @override
  Widget build(BuildContext context) {
    final score = results['score'] as int;
    final color = score >= 80 ? Colors.greenAccent : (score >= 60 ? Colors.blueAccent : (score >= 40 ? Colors.orangeAccent : Colors.redAccent));

    return CosmicCard(
      glowGold: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Cosmic Compatibility', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 16, color: CosmicColors.textMed)),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120, height: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: CosmicColors.bgDeep,
                  color: color,
                  strokeWidth: 8,
                ),
              ),
              Text('$score%', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 32, color: CosmicColors.textHigh, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(results['verdict'], style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 22, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          _InfoRow('Life Path', '${personA.name.split(' ')[0]}: ${results['numA']}  |  ${personB.name.split(' ')[0]}: ${results['numB']}'),
          _InfoRow('Element Harmony', '${results['elementA']} & ${results['elementB']}'),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          
          _DetailSection(title: 'Strengths', content: results['strengths'], icon: '✨', color: Colors.greenAccent),
          const SizedBox(height: 16),
          _DetailSection(title: 'Challenges', content: results['challenges'], icon: '⚡', color: Colors.orangeAccent),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: CosmicTypography.inter, color: CosmicColors.textMed)),
          Text(value, style: TextStyle(fontFamily: CosmicTypography.inter, color: CosmicColors.textHigh, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  final String icon;
  final Color color;

  const _DetailSection({required this.title, required this.content, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 16, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 13, color: CosmicColors.textMed, height: 1.5)),
      ],
    );
  }
}
