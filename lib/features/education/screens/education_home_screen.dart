import 'package:flutter/material.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';

// ─── Education Data ───────────────────────────────────────────────────────────

class _Lesson {
  final String title;
  final String emoji;
  final String category;
  final String duration;
  final List<String> keyPoints;
  final String content;
  const _Lesson({
    required this.title, required this.emoji, required this.category,
    required this.duration, required this.keyPoints, required this.content,
  });
}

const _lessons = <_Lesson>[
  _Lesson(
    title: 'Introduction to Vedic Astrology',
    emoji: '🌟',
    category: 'Foundations',
    duration: '5 min',
    keyPoints: ['Origins in the Vedas (5000+ years old)', 'Sidereal vs Tropical zodiac', 'The role of karma in Jyotish', 'Differences from Western astrology'],
    content: 'Vedic Astrology (Jyotish) is one of the six auxiliary disciplines of the Vedas. Unlike Western astrology which uses the Tropical zodiac (based on seasons), Vedic astrology uses the Sidereal zodiac — fixed stars as they actually appear in the sky. This difference creates an approximately 23° shift called the Ayanamsa. Jyotish views the birth chart as a karmic map — a reflection of your soul\'s journey across lifetimes.',
  ),
  _Lesson(
    title: 'The 12 Rashis (Zodiac Signs)',
    emoji: '♈',
    category: 'Foundations',
    duration: '8 min',
    keyPoints: ['Mesh (Aries) to Meen (Pisces)', 'Each sign has a ruling planet', 'Natural benefics vs malefics', 'Trines, quadrants, and dual signs'],
    content: 'The 12 Rashis form the foundation of any Kundali. Each Rashi is 30° of the ecliptic and is ruled by one of the 7 classical planets (or nodes). Signs are categorized by: Element (Fire/Earth/Air/Water), Mode (Moveable/Fixed/Dual), and Nature (Benefic/Malefic). The sign rising at birth becomes the Lagna — the most personal point of your chart.',
  ),
  _Lesson(
    title: 'The 9 Grahas (Planets)',
    emoji: '☉',
    category: 'Planets',
    duration: '10 min',
    keyPoints: ['Surya (Sun) — soul & authority', 'Chandra (Moon) — mind & emotions', 'Mangal (Mars) — energy & courage', 'Budha (Mercury) — intellect', 'Guru (Jupiter) — wisdom', 'Shukra (Venus) — love & beauty', 'Shani (Saturn) — karma & discipline', 'Rahu & Ketu — karmic axis'],
    content: 'Vedic astrology uses 9 grahas (Sanskrit for "seizers"): the 7 classical planets plus Rahu and Ketu (the Moon\'s nodes). Each graha has a natural signification, rules certain signs, and is exalted, neutral, or debilitated in others. The concept of planetary friendships, neutrality, and enmity is unique to Jyotish.',
  ),
  _Lesson(
    title: 'The 12 Bhavas (Houses)',
    emoji: '🏠',
    category: 'Houses',
    duration: '8 min',
    keyPoints: ['1st House — Self & body (Lagna)', '4th House — Home & mother', '7th House — Partnerships', '10th House — Career & fame', 'Trikona (1, 5, 9) — Fortune houses', 'Kendra (1, 4, 7, 10) — Angular houses'],
    content: 'The 12 bhavas (houses) represent specific life domains. In Vedic astrology, house analysis is integral to prediction. The Trikona houses (1, 5, 9) are the most auspicious. Kendra houses (1, 4, 7, 10) give planets extra strength. Dusthana houses (6, 8, 12) represent challenges, enemies, and losses — though malefics here can be beneficial.',
  ),
  _Lesson(
    title: 'The 27 Nakshatras (Lunar Mansions)',
    emoji: '⭐',
    category: 'Nakshatras',
    duration: '12 min',
    keyPoints: ['27 divisions of 13°20\' each', 'Each nakshatra has a ruling planet', 'Used for Dasha system & muhurta', 'Chitra, Pushya, Rohini — famous nakshatras', 'Nakshatra pada (4 divisions of 3°20\')'],
    content: 'The 27 Nakshatras are the lunar mansions — divisions of the zodiac used extensively in Vedic astrology for timing (muhurta), compatibility (matching), and the Vimshottari Dasha system. The Moon\'s nakshatra at birth determines your Dasha sequence. Each nakshatra has a ruling deity, a ruling planet, a symbol, and a psychological theme.',
  ),
  _Lesson(
    title: 'Vimshottari Dasha System',
    emoji: '⏰',
    category: 'Timing',
    duration: '10 min',
    keyPoints: ['120-year cycle of 9 planetary periods', 'Starts from Moon nakshatra at birth', 'Major (Maha) → Sub (Antar) → Sub-sub (Pratyantar)', 'Ketu Dasha — 7 years', 'Saturn Dasha — 19 years (longest)', 'Predicting major life events'],
    content: 'Vimshottari Dasha is the most commonly used timing system in Vedic astrology. The 120-year cycle starts based on the degree of the Moon in its birth nakshatra. Each planet rules a period: Ketu 7, Venus 20, Sun 6, Moon 10, Mars 7, Rahu 18, Jupiter 16, Saturn 19, Mercury 17 years. During each period, the qualities of that planet manifest strongly in life.',
  ),
  _Lesson(
    title: 'Yoga — Planetary Combinations',
    emoji: '🔱',
    category: 'Advanced',
    duration: '15 min',
    keyPoints: ['Raja Yoga — power & success', 'Dhana Yoga — wealth combinations', 'Gaja Kesari Yoga — Moon-Jupiter', 'Panch Mahapurusha Yoga — exalted planets', 'Kaal Sarpa Yoga — all planets between nodes', 'Neecha Bhanga — cancellation of debilitation'],
    content: 'Yogas are specific planetary combinations that create powerful effects in life. They are among the most sophisticated elements of Jyotish. Raj Yoga (kingly combination) occurs when lords of Kendra and Trikona houses conjoin. Dhana Yogas bring wealth. Neecha Bhanga Raja Yoga transforms a debilitated planet into a powerful one through specific conditions.',
  ),
  _Lesson(
    title: 'Chaldean Numerology Basics',
    emoji: '🔢',
    category: 'Numerology',
    duration: '6 min',
    keyPoints: ['Numbers 1-9 have planetary rulers', 'Based on sound vibration, not position', 'Life Path — birth date sum', 'Destiny Number — full birth name', 'Master numbers: 11, 22, 33', 'Chaldean vs Pythagorean systems'],
    content: 'Chaldean numerology originated in ancient Babylon and assigns numbers based on the sound vibration of letters. It differs from Pythagorean (Western) numerology in letter-to-number assignments. In Chaldean, each number 1-8 corresponds to a celestial body: 1=Sun, 2=Moon, 3=Jupiter, 4=Rahu, 5=Mercury, 6=Venus, 7=Ketu, 8=Saturn. The number 9 is sacred and never assigned to letters.',
  ),
  _Lesson(
    title: 'Muhurta — Auspicious Timing',
    emoji: '🕰️',
    category: 'Advanced',
    duration: '8 min',
    keyPoints: ['Choosing the right moment for actions', 'Panchang: 5 elements of a day', 'Vara (weekday), Tithi, Nakshatra, Yoga, Karana', 'Abhijit Muhurta — midday power period', 'Rahu Kalam & Yama Gandam — inauspicious times', 'Marriage, business, travel muhurtas'],
    content: 'Muhurta is the Vedic science of electional astrology — choosing the most auspicious moment to begin important activities. It uses the Panchang (5-part almanac) which includes the lunar day (Tithi), weekday (Vara), Nakshatra, Yoga (luni-solar combination), and Karana (half-tithi). Avoiding Rahu Kalam, inauspicious yogas like Visha Yoga, and selecting favorable nakshatras maximizes the success of any endeavor.',
  ),
];

// ─── Education Home Screen ─────────────────────────────────────────────────

class EducationHomeScreen extends StatefulWidget {
  const EducationHomeScreen({super.key});

  @override
  State<EducationHomeScreen> createState() => _EducationHomeScreenState();
}

class _EducationHomeScreenState extends State<EducationHomeScreen> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Foundations', 'Planets', 'Houses', 'Nakshatras', 'Timing', 'Numerology', 'Advanced'];
  _Lesson? _openLesson;

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _lessons
        : _lessons.where((l) => l.category == _selectedCategory).toList();

    return PopScope(
      canPop: _openLesson == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() => _openLesson = null);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _openLesson != null
            ? _LessonDetailScreen(
                key: ValueKey(_openLesson!.title),
                lesson: _openLesson!,
                onBack: () => setState(() => _openLesson = null),
                onNext: () {
                  final currentIndex = filtered.indexOf(_openLesson!);
                  if (currentIndex != -1 && currentIndex < filtered.length - 1) {
                    setState(() => _openLesson = filtered[currentIndex + 1]);
                  } else {
                    setState(() => _openLesson = null);
                  }
                },
              )
            : Scaffold(
                key: const ValueKey('home'),
                backgroundColor: CosmicColors.bgDeep,
                body: StarFieldBackground(
                  starCount: 40,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
              title: Text('Learn Astrology',
                style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 20, color: CosmicColors.textHigh)),
              backgroundColor: Colors.transparent,
              floating: true,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero card
                    CosmicGradientCard(
                      colors: const [Color(0xFF1A0D2E), Color(0xFF2D1B69)],
                      child: Row(
                        children: [
                          const Text('📚', style: TextStyle(fontSize: 36)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vedic Knowledge Library',
                                  style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 16, color: CosmicColors.gold, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${_lessons.length} lessons · From beginner to advanced',
                                  style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 12, color: CosmicColors.textMed)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category filter
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = _categories[i];
                          final selected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: selected
                                    ? CosmicColors.gold
                                    : CosmicColors.bgCard,
                                border: Border.all(
                                  color: selected ? CosmicColors.gold : CosmicColors.gold.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontFamily: CosmicTypography.inter,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: selected ? CosmicColors.bgDeep : CosmicColors.textMed,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LessonCard(
                      lesson: filtered[i],
                      onTap: () => setState(() => _openLesson = filtered[i]),
                    ),
                  ),
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    ), // end Scaffold
      ), // end AnimatedSwitcher
    ); // end PopScope
  }
}

// ─── Lesson Card ──────────────────────────────────────────────────────────────

class _LessonCard extends StatelessWidget {
  final _Lesson lesson;
  final VoidCallback onTap;
  const _LessonCard({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const catColors = <String, Color>{
      'Foundations': Color(0xFF4FC3F7),
      'Planets': Color(0xFFFFB347),
      'Houses': Color(0xFF81C784),
      'Nakshatras': Color(0xFFCE93D8),
      'Timing': Color(0xFFFFCC02),
      'Numerology': Color(0xFFFF8A65),
      'Advanced': Color(0xFFEF5350),
    };
    final catColor = catColors[lesson.category] ?? CosmicColors.gold;

    return CosmicCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: catColor.withValues(alpha: 0.12),
              border: Border.all(color: catColor.withValues(alpha: 0.3)),
            ),
            child: Center(child: Text(lesson.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: catColor.withValues(alpha: 0.15),
                      ),
                      child: Text(lesson.category,
                        style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 9, color: catColor, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    Text('⏱ ${lesson.duration}',
                      style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 10, color: CosmicColors.textLow)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(lesson.title,
                  style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 13, color: CosmicColors.textHigh, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${lesson.keyPoints.length} key points',
                  style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.textMed)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: CosmicColors.gold, size: 16),
        ],
      ),
    );
  }
}

// ─── Lesson Detail Screen ─────────────────────────────────────────────────────

class _LessonDetailScreen extends StatelessWidget {
  final _Lesson lesson;
  final VoidCallback onBack;
  final VoidCallback onNext;
  const _LessonDetailScreen({super.key, required this.lesson, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        starCount: 30,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: CosmicColors.gold),
                onPressed: onBack,
              ),
              title: Text(lesson.category,
                style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 13, color: CosmicColors.textMed)),
              backgroundColor: Colors.transparent,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Title
                  Row(
                    children: [
                      Text(lesson.emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lesson.title,
                              style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 20, color: CosmicColors.textHigh, fontWeight: FontWeight.w700, height: 1.2)),
                            const SizedBox(height: 4),
                            Text('⏱ ${lesson.duration} read',
                              style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 11, color: CosmicColors.gold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Key Points
                  CosmicCard(
                    padding: const EdgeInsets.all(16),
                    glowGold: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Key Points',
                          style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 13, color: CosmicColors.gold, letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        ...lesson.keyPoints.map((kp) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✦ ', style: TextStyle(color: CosmicColors.gold, fontSize: 12)),
                              Expanded(child: Text(kp, style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 13, color: CosmicColors.textHigh, height: 1.4))),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content
                  CosmicCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overview',
                          style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 13, color: CosmicColors.gold, letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        Text(lesson.content,
                          style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 14, color: CosmicColors.textMed, height: 1.7)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Completion footer
                  Center(
                    child: GestureDetector(
                      onTap: onNext,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: CosmicColors.goldGradient,
                        ),
                        child: Text('Lesson Complete ✓',
                          style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.bgDeep, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
