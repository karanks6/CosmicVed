import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';
import '../../../services/numerology/chaldean_service.dart';
import '../../../models/models.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LifePathScreen extends ConsumerWidget {
  const LifePathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      appBar: AppBar(
        title: Text(
          'Life Path Number',
          style: TextStyle(
            fontFamily: CosmicTypography.cinzel,
            color: CosmicColors.textHigh,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: StarFieldBackground(
        starCount: 40,
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: CosmicColors.gold)),
          error: (e, _) => Center(child: Text('$e')),
          data: (profile) {
            if (profile == null) return const Center(child: Text('No profile'));
            final result = ChaldeanService.instance.calculateLifePath(profile.dateOfBirth);
            return _LifePathView(result: result);
          },
        ),
      ),
    );
  }
}

class _LifePathView extends StatefulWidget {
  final NumerologyResult result;
  const _LifePathView({required this.result});

  @override
  State<_LifePathView> createState() => _LifePathViewState();
}

class _LifePathViewState extends State<_LifePathView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _numberAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _numberAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final data = r.interpretation;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Number hero
        Center(
          child: AnimatedBuilder(
            animation: _numberAnim,
            builder: (context, child) => Transform.scale(
              scale: _numberAnim.value,
              child: child,
            ),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: CosmicColors.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: CosmicColors.gold.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${r.number}',
                  style: TextStyle(
                    fontFamily: CosmicTypography.cinzel,
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: CosmicColors.bgDeep,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Title
        Center(
          child: ShaderMask(
            shaderCallback: (b) => CosmicColors.goldGradient.createShader(b),
            child: Text(
              data['title'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: CosmicTypography.cinzel,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Formula
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: CosmicColors.bgCard,
              border: Border.all(color: CosmicColors.gold.withValues(alpha: 0.2)),
            ),
            child: Text(
              r.formula,
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 11,
                color: CosmicColors.gold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        _Section(
          title: 'Your Soul Mission',
          icon: '🌟',
          content: data['lifePurpose'] ?? '',
        ),

        _Section(
          title: 'Core Personality',
          icon: '✨',
          content: data['corePersonality'] ?? '',
        ),

        _Section(
          title: 'Natural Strengths',
          icon: '💪',
          content: data['strengths'] is List
              ? (data['strengths'] as List).join('\n• ')
              : '',
          isBullet: data['strengths'] is List,
        ),

        _Section(
          title: 'Life Challenges',
          icon: '⚡',
          content: data['weaknesses'] is List
              ? (data['weaknesses'] as List).join('\n• ')
              : '',
          isBullet: data['weaknesses'] is List,
        ),

        _Section(
          title: 'Career & Vocation',
          icon: '💼',
          content: data['career'] is List
              ? (data['career'] as List).join(' • ')
              : '',
        ),

        _Section(
          title: 'Love & Relationships',
          icon: '💞',
          content: data['love'] ?? '',
        ),
        
        _Section(
          title: 'Wealth & Money',
          icon: '💰',
          content: data['money'] ?? '',
        ),
        
        _Section(
          title: 'Health',
          icon: '🌿',
          content: data['health'] ?? '',
        ),

        _Section(
          title: 'Spiritual Path',
          icon: '🕉️',
          content: data['spiritual'] ?? '',
        ),

        if (data['luckyNumbers'] != null) ...[
          _Section(
            title: 'Lucky Numbers',
            icon: '🎯',
            content: (data['luckyNumbers'] as List).join('  •  '),
          ),
        ],

        if (data['luckyColors'] != null) ...[
          _Section(
            title: 'Lucky Colors',
            icon: '🎨',
            content: (data['luckyColors'] as List).join('  •  '),
          ),
        ],
        
        if (data['luckyGemstones'] != null) ...[
          _Section(
            title: 'Lucky Gemstones',
            icon: '💎',
            content: (data['luckyGemstones'] as List).join('  •  '),
          ),
        ],
        
        if (data['growthAdvice'] != null) ...[
          _Section(
            title: 'Growth Advice',
            icon: '🌱',
            content: data['growthAdvice'] ?? '',
          ),
        ],

        if (r.interpretation['karmic_debt'] != null) ...[
          CosmicCard(
            padding: const EdgeInsets.all(16),
            tint: CosmicColors.maroon.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Karmic Debt Detected',
                      style: TextStyle(
                        fontFamily: CosmicTypography.cinzel,
                        fontSize: 13,
                        color: CosmicColors.maroon,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  r.interpretation['karmic_debt'] as String,
                  style: TextStyle(
                    fontFamily: CosmicTypography.inter,
                    fontSize: 13,
                    color: CosmicColors.textMed,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 100),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String icon;
  final String content;
  final bool isBullet;

  const _Section({
    required this.title,
    required this.icon,
    required this.content,
    this.isBullet = false,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CosmicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: CosmicTypography.cinzel,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CosmicColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isBullet ? '• $content' : content,
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 13,
                color: CosmicColors.textMed,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
