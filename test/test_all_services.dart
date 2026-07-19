import 'package:flutter_test/flutter_test.dart';
import 'package:cosmic_ved/models/models.dart';
import 'package:cosmic_ved/models/user_profile.dart';
import 'package:cosmic_ved/services/astrology/astrology_api_service.dart';
import 'package:cosmic_ved/services/horoscope/horoscope_service.dart';
import 'package:cosmic_ved/services/numerology/chaldean_service.dart';
import 'package:cosmic_ved/services/compatibility/guna_milan_service.dart';
import 'package:cosmic_ved/services/ephemeris/ephemeris_service.dart';
import 'package:sweph/sweph.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Audit', () {
    final dummyProfile = UserProfile(
      id: 1,
      name: 'Test User',
      gender: 'male',
      dateOfBirth: DateTime(1990, 1, 1),
      timeOfBirth: '12:00 PM',
      latitude: 28.6139,
      longitude: 77.2090,
      birthCity: 'New Delhi',
      birthCountry: 'India',
      timezoneId: 'Asia/Kolkata',
      utcOffsetMinutes: 330,
    );

    setUpAll(() async {
      // Initialize Sweph before tests
      try {
        await Sweph.init(epheAssets: ["packages/sweph/assets/ephe/seas_18.se1"]);
      } catch (e) {
        print('Sweph init error: $e');
      }
    });

    test('AstrologyApiService - fetchKundali', () async {
      final kundali = await AstrologyApiService.instance.fetchKundali(dummyProfile);
      expect(kundali, isNotNull);
      expect(kundali!.planets.length, 9);
    });

    test('AstrologyApiService - fetchPanchang', () async {
      final panchang = await AstrologyApiService.instance.fetchPanchang(DateTime(2024, 1, 1), 28.6139, 77.2090);
      expect(panchang, isNotNull);
      expect(panchang!.tithi, isNotEmpty);
    });

    test('HoroscopeService - fetchHoroscope', () async {
      // Test fetching Aries daily
      final horoscope = await HoroscopeService.instance.fetchHoroscope(0, 'daily');
      expect(horoscope, isNotNull);
      expect(horoscope, isNotEmpty);
    });

    test('ChaldeanService - calculateLifePath', () {
      final numerology = ChaldeanService.instance.calculateLifePath(dummyProfile.dateOfBirth);
      expect(numerology, isNotNull);
      expect(numerology.number, isNotNull);
    });

    test('GunaMilanService - calculate', () async {
      final p1 = dummyProfile;
      final p2 = UserProfile(
        id: 2,
        name: 'Test Partner',
        gender: 'female',
        dateOfBirth: DateTime(1995, 5, 5),
        timeOfBirth: '08:00 AM',
        latitude: 19.0760,
        longitude: 72.8777,
        birthCity: 'Mumbai',
        birthCountry: 'India',
        timezoneId: 'Asia/Kolkata',
        utcOffsetMinutes: 330,
      );
      
      final k1 = await AstrologyApiService.instance.fetchKundali(p1);
      final k2 = await AstrologyApiService.instance.fetchKundali(p2);
      
      final match = GunaMilanService.instance.calculate(k1!, k2!);
      expect(match, isNotNull);
      expect(match.totalScore, greaterThanOrEqualTo(0.0));
      expect(match.totalScore, lessThanOrEqualTo(36.0));
    });
  });
}
