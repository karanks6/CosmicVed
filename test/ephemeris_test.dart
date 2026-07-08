import 'package:flutter_test/flutter_test.dart';
import 'package:cosmic_ved/services/ephemeris/ephemeris_service.dart';

void main() {
  group('Ephemeris Math Engine Tests', () {
    test('Julian Day Calculation is accurate for J2000.0', () {
      final j2000 = DateTime.utc(2000, 1, 1, 12, 0, 0);
      final jd = EphemerisService.getJulianDay(j2000);
      expect(jd, closeTo(2451545.0, 0.01));
    });

    test('Lahiri Ayanamsa increases correctly over time', () {
      final date1950 = DateTime.utc(1950, 1, 1);
      final date2000 = DateTime.utc(2000, 1, 1);
      
      final ayanamsa1950 = EphemerisService.calculateAyanamsa(date1950);
      final ayanamsa2000 = EphemerisService.calculateAyanamsa(date2000);
      
      // Ayanamsa increases by roughly 50.29 arc seconds (~0.0139 deg) per year
      expect(ayanamsa2000 > ayanamsa1950, isTrue);
      expect(ayanamsa2000 - ayanamsa1950, closeTo(0.7, 0.1)); // ~0.7 degrees in 50 years
    });

    test('Rashi Calculation handles wrap-arounds', () {
      expect(EphemerisService.getRashiIndex(0), 0);    // Aries
      expect(EphemerisService.getRashiIndex(29), 0);   // Aries
      expect(EphemerisService.getRashiIndex(30), 1);   // Taurus
      expect(EphemerisService.getRashiIndex(359), 11); // Pisces
      expect(EphemerisService.getRashiIndex(360), 0);  // Aries
    });

    test('calculateKundali returns fully populated Chart', () {
      final eph = EphemerisService.instance;
      final kundali = eph.calculateKundali(
        birthDateTimeUtc: DateTime.utc(1990, 3, 15, 10, 30),
        latitude: 28.6139,  // New Delhi
        longitude: 77.2090,
      );

      expect(kundali.planets.length, 9); // Sun to Ketu
      expect(kundali.houseRashis.length, 12);
      expect(kundali.sunSign, isNotEmpty);
      expect(kundali.moonSign, isNotEmpty);
      expect(kundali.ascendantSign, isNotEmpty);
      expect(kundali.moonNakshatra, isNotEmpty);
      expect(kundali.moonNakshatraPada, inInclusiveRange(1, 4));
    });
  });
}
