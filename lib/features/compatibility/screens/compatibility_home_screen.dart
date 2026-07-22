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
import '../../../services/compatibility/guna_milan_service.dart';
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
      
      final kA = (await repo.getOrCalculateKundali(_personA!)).valueOrNull;
      final kB = (await repo.getOrCalculateKundali(_personB!)).valueOrNull;

      if (kA == null || kB == null) throw Exception('Kundali error');

      final gunaResult = GunaMilanService.instance.calculate(kA, kB);

      // Numerology Compatibility
      final numA = ChaldeanService.instance.calculateLifePath(_personA!.dateOfBirth).number;
      final numB = ChaldeanService.instance.calculateLifePath(_personB!.dateOfBirth).number;
      
      bool isManglik(Kundali k) {
        final mars = k.getPlanet('Mars');
        if (mars == null) return false;
        final h = mars.houseNumber;
        return h == 1 || h == 4 || h == 7 || h == 8 || h == 12;
      }

      final percentage = gunaResult.scorePercent.round();
      String verdict = '';

      if (percentage >= 75) {
        verdict = 'Excellent Match';
      } else if (percentage >= 50) {
        verdict = 'Good Match';
      } else if (percentage >= 35) {
        verdict = 'Challenging Match';
      } else {
        verdict = 'Karmic Match';
      }

      // Generate accurate, unique strengths and challenges based on actual Koota scores
      List<String> strengthList = [];
      List<String> challengeList = [];
      
      for (var k in gunaResult.kootas ?? []) {
        if (k.pointsObtained == k.maxPoints && k.maxPoints >= 3) {
          if (k.name == 'Nadi') strengthList.add('Perfect genetic and health harmony.');
          if (k.name == 'Bhakoot') strengthList.add('Deep emotional resonance and love longevity.');
          if (k.name == 'Gana') strengthList.add('Matching temperaments and natural understanding.');
          if (k.name == 'Maitri') strengthList.add('Strong natural friendship and mutual respect.');
          if (k.name == 'Yoni') strengthList.add('High physical attraction and intimacy.');
        } else if (k.pointsObtained == 0 && k.maxPoints >= 3) {
          if (k.name == 'Nadi') challengeList.add('Nadi Dosha detected: health and genetic friction.');
          if (k.name == 'Bhakoot') challengeList.add('Bhakoot Dosha: emotional mismatches may occur.');
          if (k.name == 'Gana') challengeList.add('Clashing temperaments require patience.');
          if (k.name == 'Maitri') challengeList.add('Lacking natural friendship, requires effort to connect.');
          if (k.name == 'Yoni') challengeList.add('Physical chemistry may need work.');
        }
      }
      
      // Fallbacks if no major ones found
      if (strengthList.isEmpty) {
        if (percentage >= 60) strengthList.add('Overall steady foundation for a good relationship.');
        else strengthList.add('Opportunities for personal growth through compromise.');
      }
      if (challengeList.isEmpty) {
        if (percentage >= 60) challengeList.add('Occasional miscommunications requiring standard patience.');
        else challengeList.add('Fundamentally different approaches to life goals.');
      }

      if (mounted) {
        setState(() {
          _results = {
            'guna': gunaResult,
            'numA': numA,
            'numB': numB,
            'manglikA': isManglik(kA),
            'manglikB': isManglik(kB),
            'percentage': percentage,
            'verdict': verdict,
            'strengths': strengthList.take(2).join('\n'),
            'challenges': challengeList.take(2).join('\n'),
          };
          _calculating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _calculating = false);
      }
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
    final CompatibilityResult guna = results['guna'];
    final score = guna.scorePercent.round();
    final color = score >= 75 ? Colors.greenAccent : (score >= 50 ? Colors.blueAccent : (score >= 35 ? Colors.orangeAccent : Colors.redAccent));
    final nameA = personA.name.split(' ')[0];
    final nameB = personB.name.split(' ')[0];

    bool hasNadiDosha = false;
    bool hasBhakootDosha = false;
    for (var k in (guna.kootas ?? [])) {
      if (k.name == 'Nadi' && k.pointsObtained == 0) hasNadiDosha = true;
      if (k.name == 'Bhakoot' && k.pointsObtained == 0) hasBhakootDosha = true;
    }

    final manglikA = results['manglikA'] as bool;
    final manglikB = results['manglikB'] as bool;
    String manglikStatus = 'Both non-Manglik. Peaceful alignment.';
    if (manglikA && manglikB) manglikStatus = 'Both are Manglik. Dosha is cancelled.';
    else if (manglikA) manglikStatus = '$nameA is Manglik, $nameB is not. May cause friction.';
    else if (manglikB) manglikStatus = '$nameB is Manglik, $nameA is not. May cause friction.';

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
          
          _DetailSection(title: 'Strengths', content: results['strengths'], icon: '✨', color: Colors.greenAccent),
          const SizedBox(height: 16),
          _DetailSection(title: 'Challenges', content: results['challenges'], icon: '⚡', color: Colors.orangeAccent),
            
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          
          Text('Deep Astrological Analysis', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 18, color: CosmicColors.gold)),
          const SizedBox(height: 16),

          _InfoRow('Moon Sign', '$nameA: ${guna.details['moon_sign_a']} | $nameB: ${guna.details['moon_sign_b']}'),
          _InfoRow('Birth Star (Nakshatra)', '$nameA: ${guna.details['nakshatra_a']} | $nameB: ${guna.details['nakshatra_b']}'),
          _InfoRow('Life Path (Numerology)', '$nameA: ${results['numA']} | $nameB: ${results['numB']}'),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Text('Dosha Checks (Flaws)', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow('Manglik / Kuja Dosha', manglikStatus, isWrap: true),
                const SizedBox(height: 8),
                _InfoRow('Nadi Dosha (Genetics)', hasNadiDosha ? 'Detected! Zero points in Nadi.' : 'None (Safe)'),
                const SizedBox(height: 8),
                _InfoRow('Bhakoot Dosha (Love)', hasBhakootDosha ? 'Detected! Zero points in Bhakoot.' : 'None (Safe)'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Ashtakoota Match Score: ${guna.totalScore.toStringAsFixed(1)} / 36.0', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 18, color: CosmicColors.gold)),
          const SizedBox(height: 12),
          Text('Ashtakoota Score Breakdown', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 16, color: CosmicColors.gold)),
          const SizedBox(height: 12),
          if (guna.kootas != null)
            ...guna.kootas!.map((k) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(k.name, style: TextStyle(fontFamily: CosmicTypography.inter, color: CosmicColors.textHigh, fontWeight: FontWeight.w600))),
                  Expanded(flex: 5, child: Text('${k.pointsObtained} / ${k.maxPoints} pts', style: TextStyle(fontFamily: CosmicTypography.inter, color: CosmicColors.gold))),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isWrap;
  const _InfoRow(this.label, this.value, {this.isWrap = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontFamily: CosmicTypography.inter, color: CosmicColors.textMed))),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontFamily: CosmicTypography.inter, color: CosmicColors.textHigh, fontWeight: FontWeight.w600))),
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
