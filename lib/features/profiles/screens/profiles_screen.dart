// Stub screens for features to be expanded in Phase 2

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/router/routes.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../widgets/cosmic_button.dart';
import '../../../models/user_profile.dart';
import '../../../repositories/profile_repository.dart';
import '../../dashboard/screens/dashboard_screen.dart';

// ─── Profiles Screen ───────────────────────────────────────────────────────

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      appBar: AppBar(
        title: Text('Profiles', style: TextStyle(fontFamily: CosmicTypography.cinzel, color: CosmicColors.textHigh)),
        backgroundColor: Colors.transparent,
      ),
      body: StarFieldBackground(
        starCount: 40,
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: CosmicColors.gold)),
          error: (e, _) => Center(child: Text('$e')),
          data: (profile) => _ProfilesList(currentProfile: profile),
        ),
      ),
    );
  }
}

class _ProfilesList extends ConsumerWidget {
  final UserProfile? currentProfile;
  const _ProfilesList({required this.currentProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<UserProfile>>(
      future: ProfileRepository().getAllProfiles().then((r) => r.valueOrNull ?? []),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: CosmicColors.gold));
        final profiles = snap.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...profiles.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CosmicCard(
                glowGold: p.id == currentProfile?.id,
                onTap: () async {
                  if (p.id != null && p.id != currentProfile?.id) {
                    await ProfileRepository().setActiveProfile(p.id!);
                    ref.invalidate(activeProfileProvider);
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: p.id == currentProfile?.id ? CosmicColors.goldGradient : null,
                        color: p.id != currentProfile?.id ? CosmicColors.bgCard : null,
                        border: Border.all(color: CosmicColors.gold.withValues(alpha: 0.3)),
                      ),
                      child: Center(child: Text(p.initials, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 18, color: p.id == currentProfile?.id ? CosmicColors.bgDeep : CosmicColors.gold, fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.textHigh, fontWeight: FontWeight.w600)),
                          Text('${p.birthCity}, ${p.birthCountry} • Age ${p.ageInYears}', style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textMed)),
                        ],
                      ),
                    ),
                    if (p.id == currentProfile?.id)
                      const Icon(Icons.check_circle_rounded, color: CosmicColors.gold, size: 20)
                    else
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              backgroundColor: CosmicColors.bgCard,
                              title: const Text('Delete Profile?', style: TextStyle(color: CosmicColors.textHigh)),
                              content: Text('Are you sure you want to delete ${p.name}?', style: const TextStyle(color: CosmicColors.textMed)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
                              ],
                            ),
                          );
                          if (confirm == true && p.id != null) {
                            await ProfileRepository().deleteProfile(p.id!);
                            // Trigger rebuild
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 12),
            CosmicButton(
              label: 'Add New Profile',
              icon: Icons.add_rounded,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => context.push(AppRoutes.addProfile),
            ),
          ],
        );
      },
    );
  }
}
