import '../../models/models.dart';
import '../../models/user_profile.dart';
import '../ephemeris/ephemeris_service.dart';
import 'package:sweph/sweph.dart';

class AstrologyApiService {
  static final AstrologyApiService instance = AstrologyApiService._internal();

  AstrologyApiService._internal();

  /// Calculates Kundali data 100% offline using Swiss Ephemeris
  Future<Kundali?> fetchKundali(UserProfile profile) async {
    try {
      final jd = EphemerisService.getJulianDay(profile.birthDateTimeUtc);
      final lat = profile.latitude;
      final lon = profile.longitude;
      final ayanamsa = EphemerisService.calculateAyanamsa(profile.birthDateTimeUtc);

      // Map our app planets to Swiss Ephemeris bodies
      final planetMap = {
        'Sun': HeavenlyBody.SE_SUN,
        'Moon': HeavenlyBody.SE_MOON,
        'Mars': HeavenlyBody.SE_MARS,
        'Mercury': HeavenlyBody.SE_MERCURY,
        'Jupiter': HeavenlyBody.SE_JUPITER,
        'Venus': HeavenlyBody.SE_VENUS,
        'Saturn': HeavenlyBody.SE_SATURN,
        'Rahu': HeavenlyBody.SE_MEAN_NODE,
      };

      final List<PlanetPosition> planets = [];
      
      planetMap.forEach((name, body) {
        final pos = EphemerisService.getPlanet(jd, body);
        final longitude = pos.longitude;
        final speed = pos.speedInLongitude;
        final rashiIndex = (longitude ~/ 30) % 12;
        final rashiDegrees = longitude % 30;
        final isRetrograde = speed < 0;

        // Calculate Nakshatra
        final totalNakshatras = 27;
        final nakshatraExtent = 360.0 / totalNakshatras; // 13.333 degrees
        final nakshatraIndex = (longitude / nakshatraExtent).floor();
        final nakshatraRem = longitude % nakshatraExtent;
        final nakshatraPada = (nakshatraRem / (nakshatraExtent / 4)).floor() + 1;

        planets.add(PlanetPosition(
          name: name,
          nameSanskrit: name, // We can map Sanskrit names if needed
          longitude: longitude,
          siderealLongitude: longitude,
          rashiIndex: rashiIndex,
          rashiDegrees: rashiDegrees,
          isRetrograde: isRetrograde,
          houseNumber: 1, // To be calculated based on Lagna
          nakshatra: _nakshatraName(nakshatraIndex),
          nakshatraPada: nakshatraPada,
        ));
      });

      // Add Ketu (exactly 180 degrees from Rahu)
      final rahuLon = planets.firstWhere((p) => p.name == 'Rahu').longitude;
      final ketuLon = (rahuLon + 180.0) % 360.0;
      final ketuRashiIndex = (ketuLon ~/ 30) % 12;
      final ketuRashiDegrees = ketuLon % 30;
      final kNakshatraExtent = 360.0 / 27.0;
      final kNakshatraIndex = (ketuLon / kNakshatraExtent).floor();
      final kNakshatraRem = ketuLon % kNakshatraExtent;
      final kNakshatraPada = (kNakshatraRem / (kNakshatraExtent / 4)).floor() + 1;

      planets.add(PlanetPosition(
        name: 'Ketu',
        nameSanskrit: 'Ketu',
        longitude: ketuLon,
        siderealLongitude: ketuLon,
        rashiIndex: ketuRashiIndex,
        rashiDegrees: ketuRashiDegrees,
        isRetrograde: planets.firstWhere((p) => p.name == 'Rahu').isRetrograde, // Ketu has same motion as Rahu
        houseNumber: 1,
        nakshatra: _nakshatraName(kNakshatraIndex),
        nakshatraPada: kNakshatraPada,
      ));

      // Lagna (Ascendant)
      final ascLon = EphemerisService.getAscendant(jd, lat, lon, ayanamsa);
      final ascRashiIndex = (ascLon ~/ 30) % 12;
      final ascDegrees = ascLon % 30;

      // Assign House Numbers (1-12) based on Lagna (Whole Sign Houses)
      for (var i = 0; i < planets.length; i++) {
        final houseNum = ((planets[i].rashiIndex - ascRashiIndex + 12) % 12) + 1;
        // The original code had final variables, we'd need to rebuild the object or just use copyWith if it exists.
        // Assuming PlanetPosition is mutable or we create a new one:
        planets[i] = planets[i].copyWith(houseNumber: houseNum);
      }

      final moon = planets.firstWhere((p) => p.name == 'Moon');
      final sun = planets.firstWhere((p) => p.name == 'Sun');

      return Kundali(
        birthDateTime: profile.birthDateTimeUtc,
        latitude: profile.latitude,
        longitude: profile.longitude,
        ayanamsa: ayanamsa,
        ascendantLongitude: ascLon,
        ascendantRashiIndex: ascRashiIndex,
        ascendantDegrees: ascDegrees,
        planets: planets,
        houseRashis: List.generate(12, (index) => (ascRashiIndex + index) % 12),
        moonNakshatra: moon.nakshatra ?? '',
        moonNakshatraPada: moon.nakshatraPada ?? 1,
        sunSign: _rashiName(sun.rashiIndex),
        moonSign: _rashiName(moon.rashiIndex),
        ascendantSign: _rashiName(ascRashiIndex),
        calculatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Kundali Calculation Error: $e');
      rethrow;
    }
  }
  
  /// Calculates Panchang data 100% offline using Swiss Ephemeris
  Future<Panchang?> fetchPanchang(DateTime date, double lat, double lon) async {
    try {
      final jd = EphemerisService.getJulianDay(date);
      final sunPos = EphemerisService.getPlanet(jd, HeavenlyBody.SE_SUN);
      final moonPos = EphemerisService.getPlanet(jd, HeavenlyBody.SE_MOON);
      
      final sunLon = sunPos.longitude;
      final moonLon = moonPos.longitude;

      // Tithi
      var diff = moonLon - sunLon;
      if (diff < 0) diff += 360.0;
      final tithiIndex = (diff / 12.0).floor() + 1; // 1 to 30
      final isShuklapaksha = diff < 180.0;

      // Nakshatra
      final nakshatraExtent = 360.0 / 27.0;
      final nakshatraIndex = (moonLon / nakshatraExtent).floor() + 1; // 1 to 27

      // Yoga
      final sum = (moonLon + sunLon) % 360.0;
      final yogaExtent = 360.0 / 27.0;
      final yogaIndex = (sum / yogaExtent).floor() + 1; // 1 to 27

      // Karana
      final karanaIndex = (diff / 6.0).floor() + 1; // 1 to 60

      final moonPhasePercent = (diff / 360.0) * 100.0;

      return Panchang(
        date: date,
        tithi: _tithiName(tithiIndex),
        tithiNumber: tithiIndex,
        nakshatra: _nakshatraName(nakshatraIndex - 1),
        nakshatraIndex: nakshatraIndex,
        yoga: _yogaName(yogaIndex),
        yogaIndex: yogaIndex,
        karana: _karanaName(karanaIndex),
        moonLongitude: moonLon,
        sunLongitude: sunLon,
        vara: _vaaraName(date.weekday),
        varaEnglish: _vaaraName(date.weekday),
        isShuklapaksha: isShuklapaksha,
        moonPhasePercent: moonPhasePercent,
        // Optional: Implement Muhurtas using Sunrise/Sunset later if needed
        rahuKalamStart: '',
        rahuKalamEnd: '',
        yamagandamStart: '',
        yamagandamEnd: '',
        gulikaKalamStart: '',
        gulikaKalamEnd: '',
        abhijitMuhurta: '',
      );
    } catch (e) {
      print('Panchang Calculation Error: $e');
      rethrow;
    }
  }

  String _rashiName(int index) {
    const names = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    return names[index % 12];
  }

  String _nakshatraName(int index) {
    const names = ['Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha', 'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'];
    return names[index % 27];
  }

  String _tithiName(int index) {
    return 'Tithi \$index';
  }

  String _yogaName(int index) {
    return 'Yoga \$index';
  }

  String _karanaName(int index) {
    return 'Karana \$index';
  }

  String _vaaraName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[(weekday - 1) % 7];
  }
}
