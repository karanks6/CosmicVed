import 'package:flutter/material.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontFamily: CosmicTypography.cinzel, color: CosmicColors.textHigh)),
        backgroundColor: Colors.transparent,
      ),
      body: StarFieldBackground(
        starCount: 30,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingsSection('Display', [
              _SettingsTile(Icons.palette_rounded, 'Theme', 'Dark (Cosmic)'),
              _SettingsTile(Icons.language_rounded, 'Language', 'English'),
              _SettingsTile(Icons.calendar_view_month_rounded, 'Chart Style', 'North Indian'),
            ]),
            const SizedBox(height: 16),
            _SettingsSection('Calculation', [
              _SettingsTile(Icons.adjust_rounded, 'Ayanamsa', 'Lahiri (Chitrapaksha)'),
              _SettingsTile(Icons.home_rounded, 'House System', 'Equal House'),
            ]),
            const SizedBox(height: 16),
            _SettingsSection('Privacy', [
              _SettingsTile(Icons.storage_rounded, 'Storage', 'Local SQLite only'),
              _SettingsTile(Icons.wifi_off_rounded, 'Network', 'Fully offline'),
            ]),
            const SizedBox(height: 16),
            _SettingsSection('About', [
              _SettingsTile(Icons.info_rounded, 'Version', '1.0.0'),
              _SettingsTile(Icons.privacy_tip_rounded, 'Privacy', 'All data stored locally'),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 13, color: CosmicColors.gold, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, value;
  const _SettingsTile(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: CosmicColors.gold, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 13, color: CosmicColors.textHigh))),
          Text(value, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed)),
        ],
      ),
    );
  }
}
