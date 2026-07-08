import 'package:flutter/material.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../widgets/cosmic_button.dart';
import '../../../services/numerology/chaldean_service.dart';
import '../../../models/models.dart';

class DestinyScreen extends StatefulWidget {
  const DestinyScreen({super.key});
  @override State<DestinyScreen> createState() => _DestinyScreenState();
}
class _DestinyScreenState extends State<DestinyScreen> {
  final _ctrl = TextEditingController();
  NumerologyResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      appBar: AppBar(
        title: Text('Destiny Number', style: TextStyle(fontFamily: CosmicTypography.cinzel, color: CosmicColors.textHigh)),
        backgroundColor: Colors.transparent,
      ),
      body: StarFieldBackground(
        starCount: 40,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Birth Name', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.gold)),
                  const SizedBox(height: 8),
                  Text('Enter your complete name exactly as it appears on your birth certificate.', style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ctrl,
                    style: TextStyle(fontFamily: CosmicTypography.inter, color: CosmicColors.textHigh),
                    decoration: const InputDecoration(labelText: 'Full Birth Name', hintText: 'e.g. Ravi Kumar Sharma'),
                  ),
                  const SizedBox(height: 16),
                  CosmicButton(
                    label: 'Calculate',
                    icon: Icons.calculate_rounded,
                    width: double.infinity,
                    onPressed: () {
                      if (_ctrl.text.trim().length > 1) {
                        setState(() => _result = ChaldeanService.instance.calculateDestiny(_ctrl.text.trim()));
                      }
                    },
                  ),
                ],
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              _NumberResult(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class NameNumberScreen extends StatefulWidget {
  const NameNumberScreen({super.key});
  @override State<NameNumberScreen> createState() => _NameNumberScreenState();
}
class _NameNumberScreenState extends State<NameNumberScreen> {
  final _ctrl = TextEditingController();
  NumerologyResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      appBar: AppBar(
        title: Text('Name Number', style: TextStyle(fontFamily: CosmicTypography.cinzel, color: CosmicColors.textHigh)),
        backgroundColor: Colors.transparent,
      ),
      body: StarFieldBackground(
        starCount: 40,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Currently Used Name', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.gold)),
                  const SizedBox(height: 8),
                  Text('The name you currently use — your nickname, pen name, or everyday first name.', style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ctrl,
                    style: TextStyle(fontFamily: CosmicTypography.inter, color: CosmicColors.textHigh),
                    decoration: const InputDecoration(labelText: 'Used Name', hintText: 'e.g. Ravi'),
                  ),
                  const SizedBox(height: 16),
                  CosmicButton(
                    label: 'Calculate',
                    icon: Icons.calculate_rounded,
                    width: double.infinity,
                    onPressed: () {
                      if (_ctrl.text.trim().length > 0) {
                        setState(() => _result = ChaldeanService.instance.calculateNameNumber(_ctrl.text.trim()));
                      }
                    },
                  ),
                ],
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              _NumberResult(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberResult extends StatelessWidget {
  final NumerologyResult result;
  const _NumberResult({required this.result});

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      glowGold: true,
      child: Column(
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: CosmicColors.goldGradient,
              boxShadow: [BoxShadow(color: CosmicColors.gold.withValues(alpha: 0.4), blurRadius: 20)],
            ),
            child: Center(child: Text('${result.number}', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 42, fontWeight: FontWeight.w700, color: CosmicColors.bgDeep))),
          ),
          const SizedBox(height: 16),
          Text(result.interpretation['title'] ?? '', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 16, color: CosmicColors.textHigh, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(result.formula, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.gold)),
          const SizedBox(height: 12),
          ...['current_energy', 'summary', 'public_image', 'vibration', 'professional_influence', 'financial_energy']
              .where((k) => result.interpretation[k] != null)
              .map((k) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_label(k), style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 11, color: CosmicColors.gold)),
                    const SizedBox(height: 4),
                    Text(result.interpretation[k] as String, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed, height: 1.5)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _label(String key) {
    const labels = {
      'current_energy': 'Current Energy', 'summary': 'Summary',
      'public_image': 'Public Image', 'vibration': 'Vibration',
      'professional_influence': 'Professional', 'financial_energy': 'Financial',
    };
    return labels[key] ?? key;
  }
}
