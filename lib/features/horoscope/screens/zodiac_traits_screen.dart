import 'package:flutter/material.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_card.dart';

class ZodiacTraitsScreen extends StatelessWidget {
  const ZodiacTraitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      appBar: AppBar(
        title: Text(
          'Zodiac Traits',
          style: TextStyle(fontFamily: CosmicTypography.cinzel, color: CosmicColors.textHigh),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: StarFieldBackground(
        starCount: 40,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _zodiacData.length,
          itemBuilder: (context, index) {
            final data = _zodiacData[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CosmicCard(
                glowGold: index == 0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(data['emoji'] as String, style: const TextStyle(fontSize: 40)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] as String,
                                style: TextStyle(
                                  fontFamily: CosmicTypography.cinzel,
                                  fontSize: 22,
                                  color: CosmicColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                data['sanskrit'] as String,
                                style: TextStyle(
                                  fontFamily: CosmicTypography.inter,
                                  fontSize: 14,
                                  color: CosmicColors.textMed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _TraitRow(label: 'Ruling Planet', value: data['planet'] as String),
                    _TraitRow(label: 'Element', value: data['element'] as String),
                    _TraitRow(label: 'Nature', value: data['nature'] as String),
                    _TraitRow(label: 'Lucky Colors', value: data['colors'] as String),
                    const SizedBox(height: 16),
                    Text('Strengths', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.gold)),
                    const SizedBox(height: 4),
                    Text(
                      data['strengths'] as String,
                      style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 13, color: CosmicColors.textHigh, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text('Weaknesses', style: TextStyle(fontFamily: CosmicTypography.cinzel, fontSize: 14, color: CosmicColors.gold)),
                    const SizedBox(height: 4),
                    Text(
                      data['weaknesses'] as String,
                      style: TextStyle(fontFamily: CosmicTypography.inter, fontSize: 13, color: CosmicColors.textHigh, height: 1.5),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TraitRow extends StatelessWidget {
  final String label;
  final String value;
  const _TraitRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 12,
                color: CosmicColors.textLow,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 13,
                color: CosmicColors.textHigh,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _zodiacData = [
  {
    'name': 'Aries',
    'sanskrit': 'Mesha',
    'emoji': '♈',
    'planet': 'Mars (Mangal)',
    'element': 'Fire',
    'nature': 'Moveable (Chara)',
    'colors': 'Red, Coral',
    'strengths': 'Courageous, energetic, pioneering, enthusiastic, and confident.',
    'weaknesses': 'Impulsive, short-tempered, impatient, and sometimes aggressive.'
  },
  {
    'name': 'Taurus',
    'sanskrit': 'Vrishabha',
    'emoji': '♉',
    'planet': 'Venus (Shukra)',
    'element': 'Earth',
    'nature': 'Fixed (Sthira)',
    'colors': 'White, Pink',
    'strengths': 'Reliable, patient, practical, devoted, and stable.',
    'weaknesses': 'Stubborn, possessive, uncompromising, and resistant to change.'
  },
  {
    'name': 'Gemini',
    'sanskrit': 'Mithuna',
    'emoji': '♊',
    'planet': 'Mercury (Budha)',
    'element': 'Air',
    'nature': 'Dual (Dvisvabhava)',
    'colors': 'Green, Yellow',
    'strengths': 'Adaptable, versatile, intellectual, communicative, and witty.',
    'weaknesses': 'Nervous, inconsistent, indecisive, and restless.'
  },
  {
    'name': 'Cancer',
    'sanskrit': 'Karka',
    'emoji': '♋',
    'planet': 'Moon (Chandra)',
    'element': 'Water',
    'nature': 'Moveable (Chara)',
    'colors': 'White, Silver',
    'strengths': 'Tenacious, highly imaginative, loyal, emotional, and sympathetic.',
    'weaknesses': 'Moody, pessimistic, suspicious, and manipulative.'
  },
  {
    'name': 'Leo',
    'sanskrit': 'Simha',
    'emoji': '♌',
    'planet': 'Sun (Surya)',
    'element': 'Fire',
    'nature': 'Fixed (Sthira)',
    'colors': 'Gold, Orange',
    'strengths': 'Creative, passionate, generous, warm-hearted, and cheerful.',
    'weaknesses': 'Arrogant, stubborn, self-centered, and inflexible.'
  },
  {
    'name': 'Virgo',
    'sanskrit': 'Kanya',
    'emoji': '♍',
    'planet': 'Mercury (Budha)',
    'element': 'Earth',
    'nature': 'Dual (Dvisvabhava)',
    'colors': 'Green, Pale Yellow',
    'strengths': 'Loyal, analytical, kind, hardworking, and practical.',
    'weaknesses': 'Shyness, worry, overly critical of self and others, all work and no play.'
  },
  {
    'name': 'Libra',
    'sanskrit': 'Tula',
    'emoji': '♎',
    'planet': 'Venus (Shukra)',
    'element': 'Air',
    'nature': 'Moveable (Chara)',
    'colors': 'Pink, Light Blue',
    'strengths': 'Cooperative, diplomatic, gracious, fair-minded, and social.',
    'weaknesses': 'Indecisive, avoids confrontations, will carry a grudge, self-pity.'
  },
  {
    'name': 'Scorpio',
    'sanskrit': 'Vrishchika',
    'emoji': '♏',
    'planet': 'Mars (Mangal) & Ketu',
    'element': 'Water',
    'nature': 'Fixed (Sthira)',
    'colors': 'Red, Black',
    'strengths': 'Resourceful, brave, passionate, stubborn, and a true friend.',
    'weaknesses': 'Distrusting, jealous, secretive, and violent.'
  },
  {
    'name': 'Sagittarius',
    'sanskrit': 'Dhanu',
    'emoji': '♐',
    'planet': 'Jupiter (Guru)',
    'element': 'Fire',
    'nature': 'Dual (Dvisvabhava)',
    'colors': 'Yellow, Orange',
    'strengths': 'Generous, idealistic, great sense of humor, and philosophical.',
    'weaknesses': 'Promises more than can deliver, very impatient, will say anything no matter how undiplomatic.'
  },
  {
    'name': 'Capricorn',
    'sanskrit': 'Makara',
    'emoji': '♑',
    'planet': 'Saturn (Shani)',
    'element': 'Earth',
    'nature': 'Moveable (Chara)',
    'colors': 'Black, Dark Blue',
    'strengths': 'Responsible, disciplined, self-control, and good managers.',
    'weaknesses': 'Know-it-all, unforgiving, condescending, and expecting the worst.'
  },
  {
    'name': 'Aquarius',
    'sanskrit': 'Kumbha',
    'emoji': '♒',
    'planet': 'Saturn (Shani) & Rahu',
    'element': 'Air',
    'nature': 'Fixed (Sthira)',
    'colors': 'Blue, Blue-green',
    'strengths': 'Progressive, original, independent, and humanitarian.',
    'weaknesses': 'Runs from emotional expression, temperamental, uncompromising, and aloof.'
  },
  {
    'name': 'Pisces',
    'sanskrit': 'Meena',
    'emoji': '♓',
    'planet': 'Jupiter (Guru)',
    'element': 'Water',
    'nature': 'Dual (Dvisvabhava)',
    'colors': 'Sea Green, Yellow',
    'strengths': 'Compassionate, artistic, intuitive, gentle, and wise.',
    'weaknesses': 'Fearful, overly trusting, sad, desire to escape reality, and can be a victim or a martyr.'
  },
];
