import '../../models/models.dart';
import '../../constants/astrology_constants.dart';

/// Ashtakoota (36 Guna Milan) Calculator
/// Based on Parashara Hora Shastra — classical Vedic compatibility system
///
/// Total: 36 points possible
/// 18+ points: Marriage recommended
/// 24+ points: Very good
/// 30+ points: Exceptional
class GunaMilanService {
  GunaMilanService._();
  static final GunaMilanService instance = GunaMilanService._();

  // ─── Nakshatra to Rashi ──────────────────────────────────────────────────
  // Each nakshatra spans 13°20' — 2.25 nakshatras per rashi
  static int nakshatraRashi(int nkIdx) => (nkIdx * 3 ~/ 8) % 12;

  // ─── Nakshatra Lord Planet Index ──────────────────────────────────────────
  static int nakshatraLordIndex(int nkIdx) {
    const lords = [6, 5, 0, 1, 2, 7, 3, 8, 4]; // ketu,venus,sun,moon,mars,rahu,jup,sat,merc
    return lords[nkIdx % 9];
  }

  // ─── Main Calculation ─────────────────────────────────────────────────────

  CompatibilityResult calculate(Kundali personA, Kundali personB) {
    final resultAB = _calculateRaw(personA, personB);
    final resultBA = _calculateRaw(personB, personA);

    return resultAB.totalScore >= resultBA.totalScore ? resultAB : resultBA;
  }

  CompatibilityResult _calculateRaw(Kundali bridgroom, Kundali bride) {
    final moonAIdx = bridgroom.planets
        .firstWhere((p) => p.name == 'Moon')
        .rashiIndex;
    final moonBIdx =
        bride.planets.firstWhere((p) => p.name == 'Moon').rashiIndex;

    final nkA = bridgroom.planets
        .firstWhere((p) => p.name == 'Moon')
        .nakshatra ?? '';
    final nkB =
        bride.planets.firstWhere((p) => p.name == 'Moon').nakshatra ?? '';

    final nkIdxA = AstrologyConstants.nakshatras.indexOf(nkA);
    final nkIdxB = AstrologyConstants.nakshatras.indexOf(nkB);

    final kootas = [
      _varna(moonAIdx, moonBIdx),
      _vashya(moonAIdx, moonBIdx),
      _tara(nkIdxA, nkIdxB),
      _yoni(nkIdxA, nkIdxB),
      _grahaMaitri(moonAIdx, moonBIdx),
      _gana(nkIdxA, nkIdxB),
      _bhakoot(moonAIdx, moonBIdx),
      _nadi(nkIdxA, nkIdxB),
    ];

    final totalScore =
        kootas.fold<int>(0, (sum, k) => sum + k.pointsObtained).toDouble();
    final maxScore = 36.0;
    final pct = totalScore / maxScore * 100;

    return CompatibilityResult(
      type: 'marriage',
      totalScore: totalScore,
      maxScore: maxScore,
      kootas: kootas,
      details: {
        'moon_sign_a': AstrologyConstants.rashis[moonAIdx],
        'moon_sign_b': AstrologyConstants.rashis[moonBIdx],
        'nakshatra_a': nkA,
        'nakshatra_b': nkB,
      },
      strengths: _marriageStrengths(kootas, pct),
      weaknesses: _marriageWeaknesses(kootas, pct),
      recommendations: _marriageRecommendations(totalScore),
      generatedAt: DateTime.now(),
    );
  }

  // ─── 1. Varna (Caste Koota) — Max 1 point ────────────────────────────────
  GunaKoota _varna(int rashiA, int rashiB) {
    const varnaMap = [2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3];
    // Brahmin=3, Kshatriya=2, Vaishya=1, Shudra=0
    const varnaNames = ['Shudra', 'Vaishya', 'Kshatriya', 'Brahmin'];

    final vA = varnaMap[rashiA];
    final vB = varnaMap[rashiB];
    // Groom's varna must be >= bride's (or equal)
    final points = vA >= vB ? 1 : 0;

    return GunaKoota(
      name: 'Varna',
      pointsObtained: points,
      maxPoints: 1,
      meaning: 'Spiritual compatibility and social order. '
          'Groom: ${varnaNames[vA]}, Bride: ${varnaNames[vB]}.',
      analysis: points == 1
          ? 'Compatible Varna — spiritual harmony is present.'
          : 'Varna mismatch — spiritual perspectives may differ. Not a major obstacle.',
    );
  }

  // ─── 2. Vashya (Control Koota) — Max 2 points ────────────────────────────
  GunaKoota _vashya(int rashiA, int rashiB) {
    // Vashya groups: Chatushpada, Manava, Jalchar, Vanchar, Keeta
    const vashyaGroups = [
      'Chatushpada', 'Chatushpada', 'Manava', 'Jalchar', 'Vanchar',
      'Manava', 'Manava', 'Keeta', 'Manava', 'Chatushpada',
      'Manava', 'Jalchar'
    ];

    final gA = vashyaGroups[rashiA];
    final gB = vashyaGroups[rashiB];

    int points;
    if (gA == gB) {
      points = 2;
    } else if (_vashyaFriendly(gA, gB)) {
      points = 1;
    } else {
      points = 0;
    }

    return GunaKoota(
      name: 'Vashya',
      pointsObtained: points,
      maxPoints: 2,
      meaning: 'Attraction and control in the relationship. '
          'Groom: $gA, Bride: $gB.',
      analysis: points == 2
          ? 'Strong mutual attraction and natural compatibility.'
          : points == 1
              ? 'Moderate compatibility — some natural attraction exists.'
              : 'Different natures — requires conscious effort in the relationship.',
    );
  }

  bool _vashyaFriendly(String a, String b) {
    const friendly = {
      'Chatushpada': ['Manava', 'Vanchar'],
      'Manava': ['Chatushpada', 'Jalchar'],
      'Jalchar': ['Keeta', 'Manava'],
      'Vanchar': ['Chatushpada'],
      'Keeta': ['Jalchar'],
    };
    return (friendly[a] ?? []).contains(b);
  }

  // ─── 3. Tara (Star Compatibility) — Max 3 points ─────────────────────────
  GunaKoota _tara(int nkA, int nkB) {
    if (nkA < 0 || nkB < 0) {
      return const GunaKoota(
        name: 'Tara',
        pointsObtained: 1,
        maxPoints: 3,
        meaning: 'Birth star compatibility and health/longevity.',
        analysis: 'Nakshatra data unavailable — neutral score assigned.',
      );
    }

    // Tara from groom's perspective (count from groom's nakshatra to bride's)
    final forwardCount = (nkB - nkA + 27) % 27;
    final taraNum = (forwardCount % 9) + 1;

    // Taras: 1=Janma,2=Sampat,3=Vipat,4=Kshema,5=Pratyak,6=Sadhana,7=Naidhana,8=Mitra,9=Param Mitra
    // Auspicious: 2,4,6,8,9 — Inauspicious: 1,3,5,7
    final inauspicious = [1, 3, 5, 7];
    final points = inauspicious.contains(taraNum) ? 0 : 3;
    final taraNames = [
      'Janma', 'Sampat', 'Vipat', 'Kshema', 'Pratyak',
      'Sadhana', 'Naidhana', 'Mitra', 'Param Mitra'
    ];

    return GunaKoota(
      name: 'Tara',
      pointsObtained: points,
      maxPoints: 3,
      meaning: 'Birth star compatibility, health, and longevity of the couple. '
          'Tara: ${taraNames[taraNum - 1]}.',
      analysis: points == 3
          ? 'Auspicious Tara — the stars favor health and longevity together.'
          : 'Inauspicious Tara — potential for health challenges. Remedies advised.',
    );
  }

  // ─── 4. Yoni (Sexual Compatibility) — Max 4 points ───────────────────────
  GunaKoota _yoni(int nkA, int nkB) {
    // Yoni animal for each nakshatra
    const yoniMap = [
      'Horse', 'Elephant', 'Sheep', 'Snake', 'Snake', 'Dog', 'Cat', 'Sheep',
      'Cat', 'Rat', 'Rat', 'Cow', 'Buffalo', 'Tiger', 'Buffalo', 'Tiger', 'Deer', 'Deer',
      'Dog', 'Monkey', 'Mongoose', 'Monkey', 'Lion', 'Horse', 'Lion', 'Cow', 'Elephant'
    ];

    if (nkA < 0 || nkB < 0) {
      return const GunaKoota(
        name: 'Yoni',
        pointsObtained: 2,
        maxPoints: 4,
        meaning: 'Sexual compatibility and physical harmony.',
        analysis: 'Nakshatra data unavailable — neutral score assigned.',
      );
    }

    final yA = yoniMap[nkA % 27];
    final yB = yoniMap[nkB % 27];

    int points;
    String analysis;

    if (yA == yB) {
      points = 4;
      analysis = 'Same Yoni — exceptional physical and sexual compatibility.';
    } else if (_yoniFriendly(yA, yB)) {
      points = 3;
      analysis = 'Friendly Yoni — good physical compatibility and natural harmony.';
    } else if (_yoniNeutral(yA, yB)) {
      points = 2;
      analysis = 'Neutral Yoni — moderate physical compatibility.';
    } else if (_yoniEnemy(yA, yB)) {
      points = 0;
      analysis = 'Enemy Yoni — significant differences in physical nature. Remedies recommended.';
    } else {
      points = 1;
      analysis = 'Unfriendly Yoni — some differences in physical temperament.';
    }

    return GunaKoota(
      name: 'Yoni',
      pointsObtained: points,
      maxPoints: 4,
      meaning: 'Sexual and physical compatibility. Groom: $yA, Bride: $yB.',
      analysis: analysis,
    );
  }

  bool _yoniFriendly(String a, String b) {
    const friendly = {
      'Horse': ['Deer'],
      'Deer': ['Horse'],
      'Dog': ['Cat'],
      'Cat': ['Dog'],
      'Rat': ['Mongoose'],
      'Mongoose': ['Rat'],
      'Cow': ['Buffalo'],
      'Buffalo': ['Cow'],
    };
    return (friendly[a] ?? []).contains(b);
  }

  bool _yoniNeutral(String a, String b) {
    // Most non-enemy, non-friendly combos are neutral
    return !_yoniEnemy(a, b) && !_yoniFriendly(a, b) && a != b;
  }

  bool _yoniEnemy(String a, String b) {
    const enemies = {
      'Dog': ['Deer', 'Mongoose'],
      'Cat': ['Rat'],
      'Cow': ['Tiger', 'Lion'],
      'Tiger': ['Cow', 'Elephant', 'Horse', 'Deer'],
      'Lion': ['Cow', 'Buffalo'],
      'Elephant': ['Lion'],
    };
    return (enemies[a] ?? []).contains(b) || (enemies[b] ?? []).contains(a);
  }

  // ─── 5. Graha Maitri (Planetary Friendship) — Max 5 points ───────────────
  GunaKoota _grahaMaitri(int rashiA, int rashiB) {
    // Lord of each rashi
    final lordA = AstrologyConstants.rashiLords[rashiA];
    final lordB = AstrologyConstants.rashiLords[rashiB];

    const friendships = {
      // 0=Sun,1=Moon,2=Mars,3=Merc,4=Jup,5=Ven,6=Sat,7=Rahu,8=Ketu
      0: [3, 2, 4], 1: [0, 4], 2: [0, 1, 4], 3: [0, 5],
      4: [0, 1, 2], 5: [3, 8], 6: [4, 5], 7: [], 8: [],
    };
    const enemies = {
      0: [5, 8, 7], 1: [6], 2: [3], 3: [2, 1],
      4: [3, 5], 5: [4, 0], 6: [0, 1], 7: [], 8: [],
    };

    final aFriendsB = (friendships[lordA] ?? []).contains(lordB);
    final bFriendsA = (friendships[lordB] ?? []).contains(lordA);
    final aEnemyB = (enemies[lordA] ?? []).contains(lordB);
    final bEnemyA = (enemies[lordB] ?? []).contains(lordA);

    int points;
    String analysis;

    if (lordA == lordB) {
      points = 5;
      analysis = 'Same ruling planet — exceptional mental and emotional compatibility.';
    } else if (aFriendsB && bFriendsA) {
      points = 5;
      analysis = 'Mutual friendship between ruling planets — excellent mental compatibility.';
    } else if (aFriendsB || bFriendsA) {
      points = 4;
      analysis = 'One-sided planetary friendship — generally compatible mentalities.';
    } else if (aEnemyB && bEnemyA) {
      points = 0;
      analysis = 'Mutual enmity between ruling planets — significant mental incompatibility.';
    } else if (aEnemyB || bEnemyA) {
      points = 1;
      analysis = 'One-sided enmity — some mental friction may occur.';
    } else {
      points = 3;
      analysis = 'Neutral planetary relationship — average mental compatibility.';
    }

    return GunaKoota(
      name: 'Graha Maitri',
      pointsObtained: points,
      maxPoints: 5,
      meaning: 'Mental compatibility and friendship based on the ruling planets of Moon signs.',
      analysis: analysis,
    );
  }

  // ─── 6. Gana (Nature Koota) — Max 6 points ───────────────────────────────
  GunaKoota _gana(int nkA, int nkB) {
    // Gana for each nakshatra: D=Deva,M=Manava,R=Rakshasa
    const ganaMap = [
      'D', 'M', 'R', 'M', 'D', 'R', 'D', 'D', 'R', 'R', 'M', 'M', 'D', 'R', 'D',
      'R', 'D', 'R', 'R', 'M', 'M', 'D', 'R', 'R', 'M', 'M', 'D'
    ];

    if (nkA < 0 || nkB < 0) {
      return const GunaKoota(
        name: 'Gana',
        pointsObtained: 3,
        maxPoints: 6,
        meaning: 'Temperament compatibility.',
        analysis: 'Nakshatra data unavailable — neutral score assigned.',
      );
    }

    final gA = ganaMap[nkA % 27];
    final gB = ganaMap[nkB % 27];

    const ganaNames = {'D': 'Deva (Divine)', 'M': 'Manava (Human)', 'R': 'Rakshasa (Demon)'};

    int points;
    String analysis;

    if (gA == gB) {
      points = 6;
      analysis = 'Same Gana — excellent temperament match and natural harmony.';
    } else if ((gA == 'D' && gB == 'M') || (gA == 'M' && gB == 'D')) {
      points = 5;
      analysis = 'Deva-Manava mix — good compatibility with minor adjustments needed.';
    } else if ((gA == 'D' && gB == 'R') || (gA == 'R' && gB == 'D')) {
      points = 1;
      analysis = 'Deva-Rakshasa mix — significant temperament differences. '
          'Vedic tradition suggests this pairing requires strong remedies.';
    } else {
      // Manava-Rakshasa
      points = 0;
      analysis = 'Manava-Rakshasa mix — challenging temperament differences. '
          'Special remedies are traditionally recommended.';
    }

    return GunaKoota(
      name: 'Gana',
      pointsObtained: points,
      maxPoints: 6,
      meaning: 'Temperament and disposition. Groom: ${ganaNames[gA]}, Bride: ${ganaNames[gB]}.',
      analysis: analysis,
    );
  }

  // ─── 7. Bhakoot (Moon Sign Compatibility) — Max 7 points ──────────────────
  GunaKoota _bhakoot(int rashiA, int rashiB) {
    final diff = (rashiA - rashiB + 12) % 12;
    final reverseDiff = (rashiB - rashiA + 12) % 12;

    // Inauspicious: 6-8, 5-9, 12-2 relative positions
    const inauspiciousPairs = [{6, 8}, {5, 9}, {12, 2}];
    final pair = {diff, reverseDiff};
    final normalize = {diff == 0 ? 12 : diff, reverseDiff == 0 ? 12 : reverseDiff};

    final isInauspicious = inauspiciousPairs.any((p) =>
        normalize.containsAll(p) || pair.containsAll(p));

    final points = isInauspicious ? 0 : 7;

    return GunaKoota(
      name: 'Bhakoot',
      pointsObtained: points,
      maxPoints: 7,
      meaning: 'Moon sign relationship affecting health and prosperity of the family.',
      analysis: points == 7
          ? 'Auspicious Bhakoot — the moon signs support family happiness and prosperity.'
          : 'Bhakoot Dosha present — traditional Vedic remedies are recommended to neutralize its effects. '
              'This is not necessarily a dealbreaker when other scores are high.',
    );
  }

  // ─── 8. Nadi (Pulse/Constitution) — Max 8 points ─────────────────────────
  GunaKoota _nadi(int nkA, int nkB) {
    // Nadi type for each nakshatra: 0=Aadi, 1=Madhya, 2=Antya
    const nadiMap = [
      0, 1, 2, 2, 1, 0, 0, 1, 2, 2, 1, 0, 0, 1, 2,
      2, 1, 0, 0, 1, 2, 2, 1, 0, 0, 1, 2
    ];
    const nadiNames = ['Aadi (Vata)', 'Madhya (Pitta)', 'Antya (Kapha)'];

    if (nkA < 0 || nkB < 0) {
      return const GunaKoota(
        name: 'Nadi',
        pointsObtained: 4,
        maxPoints: 8,
        meaning: 'Physiological and energetic compatibility.',
        analysis: 'Nakshatra data unavailable — neutral score assigned.',
      );
    }

    final nA = nadiMap[nkA % 27];
    final nB = nadiMap[nkB % 27];

    final points = nA != nB ? 8 : 0;

    return GunaKoota(
      name: 'Nadi',
      pointsObtained: points,
      maxPoints: 8,
      meaning: 'Physiological, genetic, and health compatibility. '
          'Groom: ${nadiNames[nA]}, Bride: ${nadiNames[nB]}.',
      analysis: points == 8
          ? 'Excellent Nadi — different body constitutions create healthy balance and good health for children.'
          : 'Nadi Dosha — same body constitution. Traditional texts consider this the most critical dosha. '
              'Vedic remedies including specific pujas are strongly recommended.',
    );
  }

  // ─── Post-calculation helpers ─────────────────────────────────────────────

  List<String> _marriageStrengths(List<GunaKoota> kootas, double pct) {
    final strengths = <String>[];
    if (pct >= 60) strengths.add('Overall compatibility is strong and auspicious');
    for (final k in kootas) {
      if (k.pointsObtained == k.maxPoints) {
        strengths.add('Perfect ${k.name} score — ${k.meaning.split('.').first}');
      }
    }
    return strengths.isEmpty
        ? ['The relationship can be strengthened through conscious effort and mutual respect']
        : strengths;
  }

  List<String> _marriageWeaknesses(List<GunaKoota> kootas, double pct) {
    final weaknesses = <String>[];
    for (final k in kootas) {
      if (k.pointsObtained == 0) {
        weaknesses.add('${k.name} score is 0 — ${k.analysis}');
      }
    }
    if (pct < 45) {
      weaknesses.add('Overall score is below the recommended threshold of 18/36');
    }
    return weaknesses;
  }

  List<String> _marriageRecommendations(double score) {
    if (score >= 28) {
      return [
        'Excellent match — this union is highly auspicious',
        'Proceed with confidence and blessings',
        'A Vivah Muhurta (auspicious marriage timing) is recommended',
      ];
    } else if (score >= 18) {
      return [
        'Good compatibility — marriage is recommended',
        'Consult a Vedic astrologer for remedies to strengthen weak kootas',
        'Perform Mangal Dosha check if applicable',
        'Choose an auspicious marriage date using Muhurta',
      ];
    } else {
      return [
        'Below average score — proceed with careful consideration',
        'Seek guidance from a qualified Vedic astrologer',
        'Traditional remedies (puja, mantra) may help neutralize doshas',
        'Consider the full chart compatibility beyond just Guna Milan',
        'Love and mutual respect are ultimately more important than numbers',
      ];
    }
  }
}
