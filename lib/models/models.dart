import 'dart:convert';

// ─── Planet Position ──────────────────────────────────────────────────────────

class PlanetPosition {
  final String name;
  final String nameSanskrit;
  final double longitude; // 0–360 tropical
  final double siderealLongitude; // Vedic (tropical - ayanamsa)
  final int rashiIndex; // 0-based (0=Aries)
  final double rashiDegrees; // degrees within rashi
  final bool isRetrograde;
  final bool isExalted;
  final bool isDebilitated;
  final bool isMoolaTrikona;
  final int houseNumber; // 1-based
  final String? nakshatra;
  final int? nakshatraPada;

  const PlanetPosition({
    required this.name,
    required this.nameSanskrit,
    required this.longitude,
    required this.siderealLongitude,
    required this.rashiIndex,
    required this.rashiDegrees,
    required this.isRetrograde,
    this.isExalted = false,
    this.isDebilitated = false,
    this.isMoolaTrikona = false,
    this.houseNumber = 1,
    this.nakshatra,
    this.nakshatraPada,
  });

  factory PlanetPosition.fromMap(Map<String, dynamic> map) {
    return PlanetPosition(
      name: map['name'] as String,
      nameSanskrit: map['name_sanskrit'] as String? ?? map['name'] as String,
      longitude: (map['longitude'] as num).toDouble(),
      siderealLongitude: (map['sidereal_longitude'] as num).toDouble(),
      rashiIndex: map['rashi_index'] as int,
      rashiDegrees: (map['rashi_degrees'] as num).toDouble(),
      isRetrograde: map['is_retrograde'] as bool? ?? false,
      isExalted: map['is_exalted'] as bool? ?? false,
      isDebilitated: map['is_debilitated'] as bool? ?? false,
      isMoolaTrikona: map['is_moola_trikona'] as bool? ?? false,
      houseNumber: (map['house_number'] as int?) ?? 1,
      nakshatra: map['nakshatra'] as String?,
      nakshatraPada: map['nakshatra_pada'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'name_sanskrit': nameSanskrit,
        'longitude': longitude,
        'sidereal_longitude': siderealLongitude,
        'rashi_index': rashiIndex,
        'rashi_degrees': rashiDegrees,
        'is_retrograde': isRetrograde,
        'is_exalted': isExalted,
        'is_debilitated': isDebilitated,
        'is_moola_trikona': isMoolaTrikona,
        'house_number': houseNumber,
        'nakshatra': nakshatra,
        'nakshatra_pada': nakshatraPada,
      };

  /// Formatted position: "12°34' Aries"
  String get formattedPosition {
    final d = rashiDegrees.floor();
    final m = ((rashiDegrees - d) * 60).round();
    const rashis = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    return "${d}°${m.toString().padLeft(2, '0')}' ${rashis[rashiIndex]}${isRetrograde ? ' (R)' : ''}";
  }
}

// ─── Kundali / Birth Chart ────────────────────────────────────────────────────

class Kundali {
  final DateTime birthDateTime; // UTC
  final double latitude;
  final double longitude;
  final double ayanamsa; // Lahiri ayanamsa in degrees
  final double ascendantLongitude; // Sidereal
  final int ascendantRashiIndex;
  final double ascendantDegrees;
  final List<PlanetPosition> planets;
  final List<int> houseRashis; // rashi index of each house (12 houses)
  final String moonNakshatra;
  final int moonNakshatraPada;
  final String sunSign;
  final String moonSign;
  final String ascendantSign;
  final DateTime calculatedAt;
  final bool isOffline;

  const Kundali({
    required this.birthDateTime,
    required this.latitude,
    required this.longitude,
    required this.ayanamsa,
    required this.ascendantLongitude,
    required this.ascendantRashiIndex,
    required this.ascendantDegrees,
    required this.planets,
    required this.houseRashis,
    required this.moonNakshatra,
    required this.moonNakshatraPada,
    required this.sunSign,
    required this.moonSign,
    required this.ascendantSign,
    required this.calculatedAt,
    this.isOffline = false,
  });

  factory Kundali.fromMap(Map<String, dynamic> map) {
    final planetsRaw = (jsonDecode(map['planets'] as String) as List)
        .cast<Map<String, dynamic>>();
    final housesRaw = (jsonDecode(map['house_rashis'] as String) as List)
        .cast<int>();

    return Kundali(
      birthDateTime: DateTime.parse(map['birth_datetime'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      ayanamsa: (map['ayanamsa'] as num).toDouble(),
      ascendantLongitude: (map['ascendant_longitude'] as num).toDouble(),
      ascendantRashiIndex: map['ascendant_rashi_index'] as int,
      ascendantDegrees: (map['ascendant_degrees'] as num).toDouble(),
      planets: planetsRaw.map(PlanetPosition.fromMap).toList(),
      houseRashis: housesRaw,
      moonNakshatra: map['moon_nakshatra'] as String,
      moonNakshatraPada: map['moon_nakshatra_pada'] as int,
      sunSign: map['sun_sign'] as String,
      moonSign: map['moon_sign'] as String,
      ascendantSign: map['ascendant_sign'] as String,
      calculatedAt: DateTime.parse(map['calculated_at'] as String),
      isOffline: map['is_offline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'birth_datetime': birthDateTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'ayanamsa': ayanamsa,
        'ascendant_longitude': ascendantLongitude,
        'ascendant_rashi_index': ascendantRashiIndex,
        'ascendant_degrees': ascendantDegrees,
        'planets': jsonEncode(planets.map((p) => p.toMap()).toList()),
        'house_rashis': jsonEncode(houseRashis),
        'moon_nakshatra': moonNakshatra,
        'moon_nakshatra_pada': moonNakshatraPada,
        'sun_sign': sunSign,
        'moon_sign': moonSign,
        'ascendant_sign': ascendantSign,
        'calculated_at': calculatedAt.toIso8601String(),
        'is_offline': isOffline,
      };

  String toJson() => jsonEncode(toMap());
  factory Kundali.fromJson(String json) =>
      Kundali.fromMap(jsonDecode(json) as Map<String, dynamic>);

  PlanetPosition? getPlanet(String name) {
    try {
      return planets.firstWhere((p) => p.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Get planets in a specific house (1-based)
  List<PlanetPosition> planetsInHouse(int house) {
    return planets.where((p) => p.houseNumber == house).toList();
  }
}

// ─── Panchang ─────────────────────────────────────────────────────────────────

class Panchang {
  final DateTime date;
  final String tithi; // Lunar day name
  final int tithiNumber; // 1–30
  final String vara; // Day of week (Ravivara etc.)
  final String varaEnglish;
  final String nakshatra; // Moon's nakshatra
  final int nakshatraIndex;
  final String yoga;
  final int yogaIndex;
  final String karana;
  final double moonLongitude;
  final double sunLongitude;
  final String rahuKalamStart;
  final String rahuKalamEnd;
  final String yamagandamStart;
  final String yamagandamEnd;
  final String gulikaKalamStart;
  final String gulikaKalamEnd;
  final String abhijitMuhurta;
  final double moonPhasePercent; // 0–100 (0=new, 100=full)
  final bool isShuklapaksha; // waxing (true) or waning (false)
  final bool isOffline;

  const Panchang({
    required this.date,
    required this.tithi,
    required this.tithiNumber,
    required this.vara,
    required this.varaEnglish,
    required this.nakshatra,
    required this.nakshatraIndex,
    required this.yoga,
    required this.yogaIndex,
    required this.karana,
    required this.moonLongitude,
    required this.sunLongitude,
    required this.rahuKalamStart,
    required this.rahuKalamEnd,
    required this.yamagandamStart,
    required this.yamagandamEnd,
    required this.gulikaKalamStart,
    required this.gulikaKalamEnd,
    required this.abhijitMuhurta,
    required this.moonPhasePercent,
    required this.isShuklapaksha,
    this.isOffline = false,
  });

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'tithi': tithi,
        'tithi_number': tithiNumber,
        'vara': vara,
        'vara_english': varaEnglish,
        'nakshatra': nakshatra,
        'nakshatra_index': nakshatraIndex,
        'yoga': yoga,
        'yoga_index': yogaIndex,
        'karana': karana,
        'moon_longitude': moonLongitude,
        'sun_longitude': sunLongitude,
        'rahu_kalam_start': rahuKalamStart,
        'rahu_kalam_end': rahuKalamEnd,
        'yamgandam_start': yamagandamStart,
        'yamgandam_end': yamagandamEnd,
        'gulika_start': gulikaKalamStart,
        'gulika_end': gulikaKalamEnd,
        'abhijit_muhurta': abhijitMuhurta,
        'moon_phase_percent': moonPhasePercent,
        'is_shuklapaksha': isShuklapaksha,
        'is_offline': isOffline,
      };

  factory Panchang.fromMap(Map<String, dynamic> map) {
    return Panchang(
      date: DateTime.parse(map['date'] as String),
      tithi: map['tithi'] as String,
      tithiNumber: map['tithi_number'] as int,
      vara: map['vara'] as String,
      varaEnglish: map['vara_english'] as String,
      nakshatra: map['nakshatra'] as String,
      nakshatraIndex: map['nakshatra_index'] as int,
      yoga: map['yoga'] as String,
      yogaIndex: map['yoga_index'] as int,
      karana: map['karana'] as String,
      moonLongitude: (map['moon_longitude'] as num).toDouble(),
      sunLongitude: (map['sun_longitude'] as num).toDouble(),
      rahuKalamStart: map['rahu_kalam_start'] as String,
      rahuKalamEnd: map['rahu_kalam_end'] as String,
      yamagandamStart: map['yamgandam_start'] as String,
      yamagandamEnd: map['yamgandam_end'] as String,
      gulikaKalamStart: map['gulika_start'] as String,
      gulikaKalamEnd: map['gulika_end'] as String,
      abhijitMuhurta: map['abhijit_muhurta'] as String,
      moonPhasePercent: (map['moon_phase_percent'] as num).toDouble(),
      isShuklapaksha: map['is_shuklapaksha'] as bool,
      isOffline: map['is_offline'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Panchang.fromJson(String json) => Panchang.fromMap(jsonDecode(json));
}



// ─── Dasha ────────────────────────────────────────────────────────────────────

class DashaPeriod {
  final String planet;
  final DateTime startDate;
  final DateTime endDate;
  final List<DashaPeriod> antardashas; // sub-periods
  final bool isCurrent;

  const DashaPeriod({
    required this.planet,
    required this.startDate,
    required this.endDate,
    this.antardashas = const [],
    this.isCurrent = false,
  });

  Duration get duration => endDate.difference(startDate);

  double get progressPercent {
    if (!isCurrent) return 0;
    final now = DateTime.now();
    final elapsed = now.difference(startDate).inDays;
    final total = duration.inDays;
    return (elapsed / total * 100).clamp(0.0, 100.0);
  }

  factory DashaPeriod.fromMap(Map<String, dynamic> map) => DashaPeriod(
        planet: map['planet'] as String,
        startDate: DateTime.parse(map['start_date'] as String),
        endDate: DateTime.parse(map['end_date'] as String),
        isCurrent: map['is_current'] as bool? ?? false,
        antardashas: ((map['antardashas'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(DashaPeriod.fromMap)
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'planet': planet,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_current': isCurrent,
        'antardashas': antardashas.map((a) => a.toMap()).toList(),
      };
}

// ─── Numerology Result ────────────────────────────────────────────────────────

class NumerologyResult {
  final String type; // 'life_path' | 'destiny' | 'name_number'
  final int number;
  final int? unreducedNumber; // e.g., 28 before becoming 1
  final List<int>? reductionSteps; // e.g., [28, 10, 1]
  final String? inputName; // for name/destiny numbers
  final Map<String, dynamic> interpretation;
  final String formula; // Human-readable formula explanation
  final DateTime generatedAt;

  const NumerologyResult({
    required this.type,
    required this.number,
    this.unreducedNumber,
    this.reductionSteps,
    this.inputName,
    required this.interpretation,
    required this.formula,
    required this.generatedAt,
  });

  factory NumerologyResult.fromMap(Map<String, dynamic> map) =>
      NumerologyResult(
        type: map['result_type'] as String,
        number: map['result_number'] as int,
        unreducedNumber: map['unreduced_number'] as int?,
        reductionSteps: (jsonDecode(map['result_json'] as String)
            as Map<String, dynamic>)['reduction_steps'] != null
            ? ((jsonDecode(map['result_json'] as String)
                    as Map<String, dynamic>)['reduction_steps'] as List)
                .cast<int>()
            : null,
        inputName: map['input_name'] as String?,
        interpretation: jsonDecode(map['result_json'] as String)
            as Map<String, dynamic>,
        formula: (jsonDecode(map['result_json'] as String)
            as Map<String, dynamic>)['formula'] as String? ?? '',
        generatedAt: DateTime.parse(map['generated_at'] as String),
      );

  Map<String, dynamic> toDbMap(int profileId) {
    final resultJson = {
      ...interpretation,
      'reduction_steps': reductionSteps,
      'unreduced_number': unreducedNumber,
      'formula': formula,
    };
    return {
      'profile_id': profileId,
      'result_type': type,
      'input_name': inputName,
      'result_number': number,
      'result_json': jsonEncode(resultJson),
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

// ─── Geonames City ────────────────────────────────────────────────────────────

class GeoCity {
  final int id;
  final String name;
  final String asciiName;
  final String countryCode;
  final String countryName;
  final double latitude;
  final double longitude;
  final String timezoneId;
  final int population;

  const GeoCity({
    required this.id,
    required this.name,
    required this.asciiName,
    required this.countryCode,
    required this.countryName,
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    required this.population,
  });

  factory GeoCity.fromMap(Map<String, dynamic> map) => GeoCity(
        id: map['id'] as int,
        name: map['name'] as String,
        asciiName: map['ascii_name'] as String,
        countryCode: map['country_code'] as String,
        countryName: map['country_name'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        timezoneId: map['timezone_id'] as String,
        population: (map['population'] as int?) ?? 0,
      );

  String get displayName => '$name, $countryName';

  @override
  String toString() => displayName;
}

// ─── Compatibility Result ─────────────────────────────────────────────────────

class GunaKoota {
  final String name;
  final int pointsObtained;
  final int maxPoints;
  final String meaning;
  final String analysis;

  const GunaKoota({
    required this.name,
    required this.pointsObtained,
    required this.maxPoints,
    required this.meaning,
    required this.analysis,
  });

  double get percent => maxPoints > 0 ? pointsObtained / maxPoints * 100 : 0;

  factory GunaKoota.fromMap(Map<String, dynamic> map) => GunaKoota(
        name: map['name'] as String,
        pointsObtained: map['points_obtained'] as int,
        maxPoints: map['max_points'] as int,
        meaning: map['meaning'] as String,
        analysis: map['analysis'] as String,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'points_obtained': pointsObtained,
        'max_points': maxPoints,
        'meaning': meaning,
        'analysis': analysis,
      };
}

class CompatibilityResult {
  final String type; // 'marriage' | 'friendship' | 'business'
  final double totalScore;
  final double maxScore;
  final List<GunaKoota>? kootas; // For marriage (Ashtakoota)
  final Map<String, dynamic> details;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final DateTime generatedAt;

  const CompatibilityResult({
    required this.type,
    required this.totalScore,
    required this.maxScore,
    this.kootas,
    required this.details,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.generatedAt,
  });

  double get scorePercent => maxScore > 0 ? totalScore / maxScore * 100 : 0;

  String get scoreLabel {
    final pct = scorePercent;
    if (pct >= 75) return 'Excellent';
    if (pct >= 60) return 'Good';
    if (pct >= 45) return 'Average';
    if (pct >= 30) return 'Below Average';
    return 'Challenging';
  }
}
