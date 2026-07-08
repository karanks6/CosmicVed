import '../../models/models.dart';
import '../../constants/numerology_constants.dart';
import '../../constants/astrology_constants.dart';

/// Chaldean Numerology Engine — complete, offline, transparent calculations
///
/// Reference: Chaldean system as documented in classical numerology texts.
/// Key distinction from Pythagorean: 9 is NOT assigned to any letter,
/// and the system does NOT reduce to 9 ordinarily.
class ChaldeanService {
  ChaldeanService._();
  static final ChaldeanService instance = ChaldeanService._();

  // ─── Life Path Number ─────────────────────────────────────────────────────

  /// Calculate Life Path Number from Date of Birth
  ///
  /// Method: Sum all digits of the birth date (DD + MM + YYYY),
  /// then reduce to a single digit or Master Number (11, 22, 33).
  NumerologyResult calculateLifePath(DateTime dob) {
    final day = dob.day;
    final month = dob.month;
    final year = dob.year;

    final dayNum = _digitSum(day);
    final monthNum = _digitSum(month);
    final yearNum = _digitSum(year);

    final total = dayNum + monthNum + yearNum;
    final steps = _reductionSteps(total);
    final finalNum = steps.last;

    // Build formula string
    final dayStr = _formatDigitSum(day, dayNum);
    final monthStr = _formatDigitSum(month, monthNum);
    final yearStr = _formatDigitSum(year, yearNum);
    final formula = '$dayStr + $monthStr + $yearStr = $total'
        '${steps.length > 1 ? ' → ${steps.skip(1).join(' → ')}' : ''}';

    final data = NumerologyConstants.lifePathData[finalNum];

    return NumerologyResult(
      type: 'life_path',
      number: finalNum,
      unreducedNumber: total,
      reductionSteps: steps,
      interpretation: {
        ...?data,
        'formula': formula,
        'day_component': dayNum,
        'month_component': monthNum,
        'year_component': yearNum,
        'karmic_debt': _karmicDebt(total),
      },
      formula: formula,
      generatedAt: DateTime.now(),
    );
  }

  // ─── Destiny Number (from full birth name) ────────────────────────────────

  /// Calculate Destiny Number from full birth name
  ///
  /// Method: Sum Chaldean values of all letters, reduce to single digit
  /// or Master Number. Only alphabetic characters are counted.
  NumerologyResult calculateDestiny(String fullName) {
    final cleaned = fullName.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final letterValues = cleaned.split('').map((c) =>
        NumerologyConstants.chaldeanTable[c] ?? 0);

    final total = letterValues.fold(0, (a, b) => a + b);
    final steps = _reductionSteps(total);
    final finalNum = steps.last;

    // Build formula
    final breakdown = cleaned.split('').map((c) {
      final v = NumerologyConstants.chaldeanTable[c];
      return v != null ? '$c=$v' : '$c=0';
    }).join(' + ');
    final formula = '$breakdown = $total'
        '${steps.length > 1 ? ' → ${steps.skip(1).join(' → ')}' : ''}';

    final summary = NumerologyConstants.destinySummary[finalNum] ?? '';

    return NumerologyResult(
      type: 'destiny',
      number: finalNum,
      unreducedNumber: total,
      reductionSteps: steps,
      inputName: fullName,
      interpretation: {
        'number': finalNum,
        'title': NumerologyConstants.numberKeywords[finalNum],
        'summary': summary,
        'soul_mission': _destinySoulMission(finalNum),
        'talents': _destinyTalents(finalNum),
        'challenges': _destinyChallenges(finalNum),
        'career_direction': _destinyCareer(finalNum),
        'spiritual_calling': _destinySpiritualCalling(finalNum),
        'formula': formula,
        'letter_breakdown': Map.fromEntries(
          cleaned.split('').map((c) => MapEntry(
              c, NumerologyConstants.chaldeanTable[c] ?? 0)),
        ),
      },
      formula: formula,
      generatedAt: DateTime.now(),
    );
  }

  // ─── Name Number (current used name) ─────────────────────────────────────

  NumerologyResult calculateNameNumber(String usedName) {
    final cleaned = usedName.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final letterValues = cleaned.split('').map((c) =>
        NumerologyConstants.chaldeanTable[c] ?? 0);

    final total = letterValues.fold(0, (a, b) => a + b);
    final steps = _reductionSteps(total);
    final finalNum = steps.last;

    final breakdown = cleaned.split('').map((c) {
      final v = NumerologyConstants.chaldeanTable[c];
      return v != null ? '$c=$v' : '$c=0';
    }).join(' + ');
    final formula = '$breakdown = $total'
        '${steps.length > 1 ? ' → ${steps.skip(1).join(' → ')}' : ''}';

    return NumerologyResult(
      type: 'name_number',
      number: finalNum,
      unreducedNumber: total,
      reductionSteps: steps,
      inputName: usedName,
      interpretation: {
        'number': finalNum,
        'title': NumerologyConstants.numberKeywords[finalNum],
        'current_energy': _nameEnergy(finalNum),
        'public_image': _namePublicImage(finalNum),
        'vibration': _nameVibration(finalNum),
        'professional_influence': _nameProfessional(finalNum),
        'communication': _nameCommunication(finalNum),
        'financial_energy': _nameFinancial(finalNum),
        'formula': formula,
      },
      formula: formula,
      generatedAt: DateTime.now(),
    );
  }

  // ─── Complete Numerology Profile ──────────────────────────────────────────

  Map<String, NumerologyResult> calculateFullProfile({
    required DateTime dob,
    required String fullBirthName,
    required String usedName,
  }) {
    return {
      'life_path': calculateLifePath(dob),
      'destiny': calculateDestiny(fullBirthName),
      'name_number': calculateNameNumber(usedName),
    };
  }

  // ─── Lucky Numbers from Life Path ─────────────────────────────────────────

  List<int> luckyNumbers(int lifePathNumber) {
    // All multiples of the life path digit up to 100
    return List.generate(9, (i) => lifePathNumber * (i + 1))
        .where((n) => n <= 100)
        .toList();
  }

  // ─── Compatibility Score (Numerology) ─────────────────────────────────────

  /// Quick numerology compatibility between two life path numbers
  double numerologyCompatibility(int numA, int numB) {
    const table = {
      // [a][b] : compatibility score 0.0–1.0
      1: {1: 0.6, 2: 0.7, 3: 0.9, 4: 0.5, 5: 0.8, 6: 0.6, 7: 0.5, 8: 0.7, 9: 0.9},
      2: {1: 0.7, 2: 0.7, 3: 0.6, 4: 0.8, 5: 0.5, 6: 0.9, 7: 0.7, 8: 0.8, 9: 0.6},
      3: {1: 0.9, 2: 0.6, 3: 0.7, 4: 0.4, 5: 0.9, 6: 0.7, 7: 0.5, 8: 0.5, 9: 0.9},
      4: {1: 0.5, 2: 0.8, 3: 0.4, 4: 0.8, 5: 0.4, 6: 0.8, 7: 0.6, 8: 0.9, 9: 0.4},
      5: {1: 0.8, 2: 0.5, 3: 0.9, 4: 0.4, 5: 0.7, 6: 0.5, 7: 0.8, 8: 0.4, 9: 0.7},
      6: {1: 0.6, 2: 0.9, 3: 0.7, 4: 0.8, 5: 0.5, 6: 0.9, 7: 0.5, 8: 0.7, 9: 0.8},
      7: {1: 0.5, 2: 0.7, 3: 0.5, 4: 0.6, 5: 0.8, 6: 0.5, 7: 0.8, 8: 0.5, 9: 0.7},
      8: {1: 0.7, 2: 0.8, 3: 0.5, 4: 0.9, 5: 0.4, 6: 0.7, 7: 0.5, 8: 0.7, 9: 0.5},
      9: {1: 0.9, 2: 0.6, 3: 0.9, 4: 0.4, 5: 0.7, 6: 0.8, 7: 0.7, 8: 0.5, 9: 0.9},
    };

    final a = numA > 9 ? _digitSumFull(numA) : numA;
    final b = numB > 9 ? _digitSumFull(numB) : numB;
    return (table[a]?[b] ?? 0.5);
  }

  // ─── Internal Helpers ─────────────────────────────────────────────────────

  int _digitSum(int n) {
    int sum = 0;
    int x = n.abs();
    while (x > 0) {
      sum += x % 10;
      x ~/= 10;
    }
    return sum == 0 ? 0 : (sum < 10 ? sum : _digitSum(sum));
  }

  int _digitSumFull(int n) {
    int sum = 0;
    int x = n.abs();
    while (x > 0) {
      sum += x % 10;
      x ~/= 10;
    }
    return sum;
  }

  List<int> _reductionSteps(int n) {
    final steps = <int>[n];
    int current = n;
    while (current > 9 && current != 11 && current != 22 && current != 33) {
      current = _digitSumFull(current);
      steps.add(current);
      if (current == 11 || current == 22 || current == 33) break;
    }
    return steps;
  }

  String _formatDigitSum(int value, int sum) {
    if (value < 10) return '$value';
    final digits = value.toString().split('').join('+');
    return '($digits)=$sum';
  }

  String? _karmicDebt(int rawSum) {
    if (NumerologyConstants.karmicDebtNumbers.contains(rawSum)) {
      return NumerologyConstants.karmicDebtMeanings[rawSum];
    }
    return null;
  }

  // ─── Destiny interpretations ───────────────────────────────────────────────

  String _destinySoulMission(int n) {
    const missions = {
      1: 'To lead, pioneer, and inspire independence through courageous action.',
      2: 'To serve as a bridge between opposing forces, bringing peace and harmony.',
      3: 'To channel creative expression and spread joy, beauty, and inspiration.',
      4: 'To build lasting foundations and systems that serve generations to come.',
      5: 'To explore the full spectrum of human experience and share wisdom from the journey.',
      6: 'To embody unconditional love through service, care, and healing of others.',
      7: 'To develop wisdom through deep introspection and spiritual seeking.',
      8: 'To master the physical world with integrity and share abundance generously.',
      9: 'To serve all humanity through compassion, art, and universal love.',
      11: 'To serve as a channel of divine inspiration and spiritual illumination.',
      22: 'To build structures of lasting benefit to humanity at the grandest scale.',
      33: 'To teach and heal through the living demonstration of unconditional love.',
    };
    return missions[n] ?? '';
  }

  String _destinyTalents(int n) {
    const talents = {
      1: 'Leadership, initiative, originality, courage, executive ability.',
      2: 'Diplomacy, empathy, mediation, attention to detail, intuition.',
      3: 'Creative expression, communication, performance, social charm.',
      4: 'Organization, discipline, reliability, practical problem-solving.',
      5: 'Adaptability, communication, sales, travel, progressive thinking.',
      6: 'Nurturing, healing, artistic sensibility, counseling, responsibility.',
      7: 'Research, analysis, introspection, spiritual insight, writing.',
      8: 'Business acumen, leadership, organization, financial management.',
      9: 'Compassion, artistic excellence, wisdom, philanthropy.',
      11: 'Intuition, vision, inspiration, spiritual teaching.',
      22: 'Large-scale organization, visionary leadership, manifestation.',
      33: 'Healing, teaching, creative mastery, unconditional love in action.',
    };
    return talents[n] ?? '';
  }

  String _destinyChallenges(int n) {
    const challenges = {
      1: 'Overcoming ego and learning cooperative leadership.',
      2: 'Developing self-worth and learning to assert boundaries.',
      3: 'Channeling creativity with discipline and follow-through.',
      4: 'Embracing change and releasing rigid perfectionism.',
      5: 'Developing commitment and avoiding self-indulgence.',
      6: 'Releasing perfectionism and avoiding martyrdom.',
      7: 'Opening to trust and balanced emotional expression.',
      8: 'Maintaining ethical use of power and valuing human connection.',
      9: 'Learning to release attachments and forgive without bitterness.',
      11: 'Grounding visionary insights into practical, actionable steps.',
      22: 'Avoiding overwhelm by the magnitude of the mission.',
      33: 'Maintaining self-care while giving unconditionally.',
    };
    return challenges[n] ?? '';
  }

  String _destinyCareer(int n) {
    final data = NumerologyConstants.lifePathData[n];
    if (data != null && data['career'] is List) {
      return (data['career'] as List).join(', ');
    }
    return '';
  }

  String _destinySpiritualCalling(int n) {
    final data = NumerologyConstants.lifePathData[n];
    if (data != null) return data['spiritual'] as String? ?? '';
    return '';
  }

  // ─── Name Number interpretations ──────────────────────────────────────────

  String _nameEnergy(int n) {
    const energies = {
      1: 'This name radiates pioneering energy, self-confidence, and natural authority. It projects leadership.',
      2: 'This name carries gentle, diplomatic energy. It projects sensitivity, cooperation, and emotional intelligence.',
      3: 'This name vibrates with creativity, joy, and social magnetism. It projects warmth and artistic ability.',
      4: 'This name projects stability, reliability, and methodical precision. It builds trust over time.',
      5: 'This name vibrates with freedom, versatility, and dynamic change. It projects adaptability and curiosity.',
      6: 'This name radiates nurturing, responsible energy. It projects warmth, care, and aesthetic refinement.',
      7: 'This name carries quiet, introspective wisdom. It projects depth, intelligence, and spiritual seeking.',
      8: 'This name vibrates with executive power, ambition, and material mastery. It projects authority.',
      9: 'This name carries universal compassion and artistic inspiration. It projects wisdom and idealism.',
      11: 'This name vibrates at a master frequency — it projects inspiration, vision, and spiritual depth.',
      22: 'This master name carries extraordinary building energy. It projects vision made manifest at scale.',
      33: 'This sacred name radiates master healing and teaching energy at its highest expression.',
    };
    return energies[n] ?? '';
  }

  String _namePublicImage(int n) {
    const images = {
      1: 'You are perceived as a confident, independent leader — someone who gets things done.',
      2: 'You come across as diplomatic, kind, and thoughtful. People feel heard around you.',
      3: 'You are seen as creative, warm, and entertaining. You draw people in effortlessly.',
      4: 'You project reliability and trustworthiness. People see you as a solid foundation.',
      5: 'You are perceived as dynamic, exciting, and adventurous. You seem always in motion.',
      6: 'You appear caring, responsible, and aesthetically refined. People trust your judgment.',
      7: 'You project intellectual depth and quiet wisdom. You seem mysterious and perceptive.',
      8: 'You come across as powerful, competent, and ambitious. People respect your authority.',
      9: 'You are seen as compassionate, wise, and artistically inspired. You seem larger than life.',
      11: 'You project an otherworldly quality — people sense something spiritually special about you.',
      22: 'You project extraordinary capability. People sense you are capable of monumental things.',
      33: 'You radiate unconditional love and healing. People are drawn to your presence instinctively.',
    };
    return images[n] ?? '';
  }

  String _nameVibration(int n) {
    const vibrations = {
      1: 'Solar — radiant, initiating, singular, pioneering',
      2: 'Lunar — receptive, reflective, partnering, flowing',
      3: 'Jovial — expansive, creative, joyful, expressive',
      4: 'Saturnine — structured, grounded, persistent, reliable',
      5: 'Mercurial — quick, versatile, communicative, free',
      6: 'Venusian — harmonious, beautiful, nurturing, loving',
      7: 'Neptune/Ketu — introspective, mystical, seeking, deep',
      8: 'Saturnine/Material — powerful, executive, material master',
      9: 'Martian/Universal — compassionate, completing, humanitarian',
      11: 'Uranian/Master — visionary, inspired, illuminating',
      22: 'Master Builder — manifestation at scale, universal',
      33: 'Master Teacher — divine love made physical',
    };
    return vibrations[n] ?? '';
  }

  String _nameProfessional(int n) {
    const professional = {
      1: 'Enhances leadership opportunities, opens doors for independent work and authority roles.',
      2: 'Strengthens collaborative relationships, diplomatic roles, and team environments.',
      3: 'Amplifies creative opportunities, public-facing roles, and artistic recognition.',
      4: 'Supports careers requiring reliability, long-term projects, and systematic work.',
      5: 'Attracts varied opportunities, sales, communication, and travel-related success.',
      6: 'Enhances service industries, healing professions, and creative-responsibility roles.',
      7: 'Strengthens academic, research, and introspective professional paths.',
      8: 'Amplifies executive, financial, and business leadership opportunities significantly.',
      9: 'Attracts humanitarian, artistic, and global-minded professional recognition.',
      11: 'Opens doors in spiritual, inspirational, and visionary leadership roles.',
      22: 'Supports large-scale organizational leadership and institution building.',
      33: 'Enhances healing, teaching, and roles requiring genuine compassion and mastery.',
    };
    return professional[n] ?? '';
  }

  String _nameCommunication(int n) {
    const comm = {
      1: 'Direct, confident, and authoritative. You communicate with clarity and conviction.',
      2: 'Gentle, empathetic, and thoughtful. You listen as powerfully as you speak.',
      3: 'Animated, expressive, and entertaining. Words flow naturally and charismatically.',
      4: 'Precise, reliable, and methodical. People trust what you say because you mean it.',
      5: 'Quick, versatile, and engaging. You can communicate across many styles effortlessly.',
      6: 'Warm, caring, and reassuring. Your words carry comfort and genuine concern.',
      7: 'Measured, insightful, and deep. You prefer quality of expression over quantity.',
      8: 'Authoritative, organized, and results-focused. You get to the point effectively.',
      9: 'Inspiring, compassionate, and visionary. Your words touch people at a soul level.',
      11: 'Inspired and intuitive. Your communication often carries wisdom beyond logic.',
      22: 'Clear, large-scale, and vision-casting. You communicate transformative possibilities.',
      33: 'Healing, loving, and profoundly moving. Your words carry spiritual authority.',
    };
    return comm[n] ?? '';
  }

  String _nameFinancial(int n) {
    const financial = {
      1: 'Strong earning energy through leadership, entrepreneurship, and independent action.',
      2: 'Financial success through partnerships, support roles, and long-term cooperative ventures.',
      3: 'Wealth through creative expression, performance, and public-facing work.',
      4: 'Steady financial growth through discipline, saving, and methodical long-term strategy.',
      5: 'Variable financial energy — peaks and valleys. Multiple income streams are recommended.',
      6: 'Financial success through service-oriented businesses and value-creation for others.',
      7: 'Income through intellectual work, research, writing, and specialized expertise.',
      8: 'Powerful financial attraction — potentially significant wealth through business mastery.',
      9: 'Money flows in, but the 9 is called to use wealth generously. Abundance follows service.',
      11: 'Financial success comes through trusting intuition in business and creative work.',
      22: 'Potential for massive wealth creation when aligned with purpose-driven building.',
      33: 'Financial abundance supports the mission when love and service are the primary currency.',
    };
    return financial[n] ?? '';
  }
}
