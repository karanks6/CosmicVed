import 'package:flutter/material.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../widgets/cosmic_button.dart';
import '../../../services/astrology/panchang_service.dart';
import '../../../models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../repositories/astrology_repository.dart';

class PanchangScreen extends ConsumerStatefulWidget {
  const PanchangScreen({super.key});
  @override ConsumerState<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends ConsumerState<PanchangScreen> {
  DateTime _selectedDate = DateTime.now();
  Future<Panchang?>? _panchangFuture;

  @override
  void initState() {
    super.initState();
    _loadPanchang();
  }

  void _loadPanchang() {
    final profile = ref.read(activeProfileProvider).valueOrNull;
    if (profile == null) return;
    
    _panchangFuture = AstrologyRepository().getOrCalculatePanchang(
      profileId: profile.id!,
      dateLocal: _selectedDate,
      latitude: profile.latitude,
      longitude: profile.longitude,
      utcOffsetMinutes: 330, // Default to IST for demo
    ).then((res) => res.valueOrNull);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        starCount: 50,
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: CosmicColors.gold)),
          error: (e, _) => Center(child: Text('Error loading profile: $e')),
          data: (profile) {
            if (profile == null) return const Center(child: Text('Please select a profile first.'));

            // Ensure future is loaded if not already
            if (_panchangFuture == null) {
              _loadPanchang();
            }

            return FutureBuilder<Panchang?>(
              future: _panchangFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: CosmicColors.gold));
                }
                final panchang = snapshot.data;
                if (panchang == null) {
                  return const Center(child: Text('Failed to calculate Panchang'));
                }
                
                return _PanchangView(
                  panchang: panchang,
                  selectedDate: _selectedDate,
                  onDateChanged: (d) {
                    setState(() {
                      _selectedDate = d;
                      _loadPanchang();
                    });
                  },
                );
              }
            );
          },
        ),
      ),
    );
  }
}

class _PanchangView extends StatelessWidget {
  final Panchang panchang;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _PanchangView({required this.panchang, required this.selectedDate, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text('Panchang', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 20, color: CosmicColors.textHigh)),
          backgroundColor: Colors.transparent,
          floating: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded, color: CosmicColors.gold),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: CosmicColors.gold, surface: CosmicColors.bgCard)),
                    child: child!,
                  ),
                );
                if (picked != null) onDateChanged(picked);
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Date header
              CosmicGradientCard(
                colors: const [Color(0xFF0C1A35), Color(0xFF1A0C35)],
                child: Column(
                  children: [
                    Text(
                      '${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year}',
                      style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 18, color: CosmicColors.textHigh, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      panchang.varaEnglish,
                      style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 14, color: CosmicColors.gold),
                    ),
                    const SizedBox(height: 10),
                    _moonPhaseIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PanchangGrid(panchang: panchang),
              const SizedBox(height: 16),
              _InausCard(panchang: panchang),
              const SizedBox(height: 16),
              _AbhijitCard(panchang: panchang),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _moonPhaseIndicator() {
    final pct = panchang.moonPhasePercent;
    return Column(
      children: [
        Text(
          panchang.isShuklapaksha ? 'Shukla Paksha (Waxing Moon)' : 'Krishna Paksha (Waning Moon)',
          style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textMed),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: CosmicColors.bgCard,
            color: CosmicColors.gold,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}

class _PanchangGrid extends StatelessWidget {
  final Panchang panchang;
  const _PanchangGrid({required this.panchang});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: [
        _PCell('Tithi', panchang.tithi, '🌙'),
        _PCell('Nakshatra', panchang.nakshatra, '✦'),
        _PCell('Yoga', panchang.yoga, '🔮'),
        _PCell('Karana', panchang.karana, '⊛'),
        _PCell('Vara', panchang.vara, '🌞'),
        _PCell('Paksha', panchang.isShuklapaksha ? 'Shukla' : 'Krishna', '☽'),
      ],
    );
  }
}

class _PCell extends StatelessWidget {
  final String label, value, icon;
  const _PCell(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 10, color: CosmicColors.textLow)),
                Text(value, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 13, color: CosmicColors.textHigh, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InausCard extends StatelessWidget {
  final Panchang panchang;
  const _InausCard({required this.panchang});

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      tint: CosmicColors.maroon.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('⚠️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('Inauspicious Periods', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 13, color: CosmicColors.maroon, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 14),
          _TimeRow('Rahu Kalam', panchang.rahuKalamStart, panchang.rahuKalamEnd),
          const SizedBox(height: 8),
          _TimeRow('Yamagandam', panchang.yamagandamStart, panchang.yamagandamEnd),
          const SizedBox(height: 8),
          _TimeRow('Gulika Kalam', panchang.gulikaKalamStart, panchang.gulikaKalamEnd),
        ],
      ),
    );
  }
}

class _AbhijitCard extends StatelessWidget {
  final Panchang panchang;
  const _AbhijitCard({required this.panchang});

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      glowGold: true,
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Abhijit Muhurta', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 13, color: CosmicColors.gold, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(panchang.abhijitMuhurta, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 14, color: CosmicColors.textHigh)),
                const SizedBox(height: 4),
                Text('Most auspicious period for new beginnings', style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textMed)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label, start, end;
  const _TimeRow(this.label, this.start, this.end);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed)),
        Text('$start – $end', style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textHigh, fontWeight: FontWeight.w500)),
      ],
    );
  }
}


