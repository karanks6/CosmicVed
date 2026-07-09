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

class _ProfilesList extends ConsumerStatefulWidget {
  final UserProfile? currentProfile;
  const _ProfilesList({required this.currentProfile});

  @override
  ConsumerState<_ProfilesList> createState() => _ProfilesListState();
}

class _ProfilesListState extends ConsumerState<_ProfilesList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<UserProfile>? _profiles;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final res = await ProfileRepository().getAllProfiles();
    if (mounted) {
      setState(() {
        _profiles = res.valueOrNull ?? [];
      });
    }
  }

  void _deleteProfile(UserProfile p) async {
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
      final index = _profiles!.indexWhere((profile) => profile.id == p.id);
      if (index != -1) {
        final removedProfile = _profiles!.removeAt(index);
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildItem(removedProfile, animation),
          duration: const Duration(milliseconds: 300),
        );
        await ProfileRepository().deleteProfile(p.id!);
      }
    }
  }

  Widget _buildItem(UserProfile p, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CosmicCard(
            glowGold: p.id == widget.currentProfile?.id,
            onTap: () async {
              if (p.id != null && p.id != widget.currentProfile?.id) {
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
                    gradient: p.id == widget.currentProfile?.id ? CosmicColors.goldGradient : null,
                    color: p.id != widget.currentProfile?.id ? CosmicColors.bgCard : null,
                    border: Border.all(color: CosmicColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Center(child: Text(p.initials, style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 18, color: p.id == widget.currentProfile?.id ? CosmicColors.bgDeep : CosmicColors.gold, fontWeight: FontWeight.w700))),
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
                if (p.id == widget.currentProfile?.id)
                  const Icon(Icons.check_circle_rounded, color: CosmicColors.gold, size: 20)
                else
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => _deleteProfile(p),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_profiles == null) return const Center(child: CircularProgressIndicator(color: CosmicColors.gold));

    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.all(16),
      initialItemCount: _profiles!.length + 1,
      itemBuilder: (context, index, animation) {
        if (index == _profiles!.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CosmicButton(
              label: 'Add New Profile',
              icon: Icons.add_rounded,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => context.push(AppRoutes.addProfile),
            ),
          );
        }
        return _buildItem(_profiles![index], animation);
      },
    );
  }
}
