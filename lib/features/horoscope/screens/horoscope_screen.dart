import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../services/horoscope/horoscope_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';

final horoscopeProvider = FutureProvider.family<String, ({int signIndex, String period})>((ref, args) async {
  return HoroscopeService.instance.fetchHoroscope(args.signIndex, args.period);
});

class HoroscopeScreen extends ConsumerStatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      appBar: AppBar(
        title: Text(
          'Horoscope',
          style: TextStyle(fontFamily: CosmicTypography.cinzel, color: CosmicColors.textHigh),
        ),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CosmicColors.gold,
          labelColor: CosmicColors.gold,
          unselectedLabelColor: CosmicColors.textMed,
          labelStyle: TextStyle(fontFamily: CosmicTypography.inter, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: StarFieldBackground(
        starCount: 40,
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: CosmicColors.gold)),
          error: (e, _) => Center(child: Text('$e')),
          data: (profile) {
            if (profile == null) return const Center(child: Text('Please create a profile first.'));
            
            final kundaliAsync = ref.watch(kundaliProvider(profile));
            
            return kundaliAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: CosmicColors.gold)),
              error: (e, _) => Center(child: Text('$e')),
              data: (kundali) {
                if (kundali == null) return const Center(child: Text('Unable to load chart data.'));
                
                // Determine Moon Sign
                final moonSignIndex = kundali.planets.firstWhere((p) => p.name == 'Moon').rashiIndex;
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _HoroscopeTab(type: 'Daily', signIndex: moonSignIndex),
                    _HoroscopeTab(type: 'Weekly', signIndex: moonSignIndex),
                    _HoroscopeTab(type: 'Monthly', signIndex: moonSignIndex),
                  ],
                );
              }
            );
          },
        ),
      ),
    );
  }
}

class _HoroscopeTab extends ConsumerWidget {
  final String type;
  final int signIndex;

  const _HoroscopeTab({required this.type, required this.signIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signName = _rashiName(signIndex);
    final signEmoji = _rashiEmoji(signIndex);
    
    final horoscopeAsync = ref.watch(horoscopeProvider((signIndex: signIndex, period: type.toLowerCase())));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CosmicCard(
          glowGold: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                signEmoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                'Moon in $signName',
                style: TextStyle(
                  fontFamily: CosmicTypography.cinzel,
                  fontSize: 20,
                  color: CosmicColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vedic Moon Sign (Rashi)',
                style: TextStyle(
                  fontFamily: CosmicTypography.inter,
                  fontSize: 12,
                  color: CosmicColors.textMed,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CosmicColors.bgDeep.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CosmicColors.gold.withValues(alpha: 0.2)),
                ),
                child: horoscopeAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator(color: CosmicColors.gold)),
                  ),
                  error: (err, stack) => Text(
                    'The cosmic waves are disturbed. Please try again later.\n\n$err',
                    style: TextStyle(color: Colors.redAccent, fontFamily: CosmicTypography.inter),
                    textAlign: TextAlign.center,
                  ),
                  data: (prediction) => Text(
                    prediction,
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      fontSize: 14,
                      color: CosmicColors.textHigh,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _rashiName(int index) {
    const names = ['Aries (Mesha)', 'Taurus (Vrishabha)', 'Gemini (Mithuna)', 'Cancer (Karka)', 'Leo (Simha)', 'Virgo (Kanya)', 'Libra (Tula)', 'Scorpio (Vrishchika)', 'Sagittarius (Dhanu)', 'Capricorn (Makara)', 'Aquarius (Kumbha)', 'Pisces (Meena)'];
    return names[index % 12];
  }

  String _rashiEmoji(int index) {
    const emojis = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
    return emojis[index % 12];
  }
}
