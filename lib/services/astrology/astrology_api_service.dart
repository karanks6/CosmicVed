import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../../models/user_profile.dart';

class AstrologyApiService {
  static final AstrologyApiService instance = AstrologyApiService._internal();
  final Dio _dio;

  // IMPORTANT: Placeholder endpoint structure. Replace with an actual provider (e.g. Prokerala, AstrologyAPI)
  final String _apiKey = '2723d63c-e603-5b83-85d8-04828a11740b';

  AstrologyApiService._internal() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api.vedicastroapi.com/v3-json/',
    connectTimeout: const Duration(seconds: 10), // Increased for real API calls
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Attempts to fetch Kundali data from the API
  Future<Kundali?> fetchKundali(UserProfile profile) async {
    try {
      // Simulate network request to external API
      final response = await _dio.get(
        'horoscope/planet-details',
        queryParameters: {
          'api_key': _apiKey,
          'dob': '${profile.dateOfBirth.day}/${profile.dateOfBirth.month}/${profile.dateOfBirth.year}',
          'tob': profile.timeOfBirth,
          'lat': profile.latitude,
          'lon': profile.longitude,
          'tz': 5.5, // Hardcoded timezone for demo, should be derived
          'lang': 'en'
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['response'];
        if (data == null) throw Exception('No response data found');
        if (data is String) throw Exception('API Error: $data');
        
        final List<PlanetPosition> planets = [];
        for (int i = 0; i <= 9; i++) {
          final pData = data[i.toString()];
          if (pData != null) {
            planets.add(PlanetPosition(
              name: pData['full_name'] ?? pData['name'],
              nameSanskrit: pData['full_name'] ?? pData['name'],
              longitude: (pData['global_degree'] as num).toDouble(),
              siderealLongitude: (pData['global_degree'] as num).toDouble(),
              rashiIndex: ((pData['rasi_no'] as num).toInt() - 1) % 12,
              rashiDegrees: (pData['local_degree'] as num).toDouble(),
              isRetrograde: pData['retro'] == true,
              houseNumber: (pData['house'] as int?) ?? 1,
              nakshatra: pData['nakshatra'],
              nakshatraPada: (pData['nakshatra_pada'] as num?)?.toInt(),
            ));
          }
        }

        return Kundali(
          birthDateTime: profile.birthDateTimeUtc,
          latitude: profile.latitude,
          longitude: profile.longitude,
          ayanamsa: data['panchang'] is Map ? (data['panchang']['ayanamsa'] as num?)?.toDouble() ?? 24.0 : 24.0,
          ascendantLongitude: planets.isNotEmpty ? planets.first.longitude : 0.0,
          ascendantRashiIndex: planets.isNotEmpty ? planets.first.rashiIndex : 0,
          ascendantDegrees: planets.isNotEmpty ? planets.first.rashiDegrees : 0.0,
          planets: planets,
          houseRashis: List.generate(12, (index) => (planets.isNotEmpty ? (planets.first.rashiIndex + index) % 12 : 0)),
          moonNakshatra: data['nakshatra'] ?? '',
          moonNakshatraPada: (data['nakshatra_pada'] as num?)?.toInt() ?? 1,
          sunSign: _rashiName(planets.firstWhere((p) => p.name == 'Sun').rashiIndex),
          moonSign: data['rasi'] ?? '',
          ascendantSign: planets.isNotEmpty ? _rashiName(planets.first.rashiIndex) : '',
          calculatedAt: DateTime.now(),
        );
      }
      
      throw Exception('API returned status ${response.statusCode}');
    } catch (e) {
      print('Kundali API Error: $e');
      rethrow;
    }
  }
  
  /// Attempts to fetch Panchang data from the API
  Future<Panchang?> fetchPanchang(DateTime date, double lat, double lon) async {
    try {
      final response = await _dio.get(
        'panchang/panchang',
        queryParameters: {
          'api_key': _apiKey,
          'date': '${date.day}/${date.month}/${date.year}',
          'lat': lat,
          'lon': lon,
          'tz': 5.5, 
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['response'];
        if (data == null) throw Exception('No response data found');
        if (data is String) throw Exception('API Error: $data');
        
        final adv = data['advanced_details'] ?? {};
        
        return Panchang(
          date: date,
          tithi: data['tithi'] is Map ? data['tithi']['name'] ?? '' : '',
          tithiNumber: data['tithi'] is Map ? (data['tithi']['number'] as num?)?.toInt() ?? 1 : 1,
          nakshatra: data['nakshatra'] is Map ? data['nakshatra']['name'] ?? '' : '',
          nakshatraIndex: data['nakshatra'] is Map ? (data['nakshatra']['number'] as num?)?.toInt() ?? 1 : 1,
          yoga: data['yoga'] is Map ? data['yoga']['name'] ?? '' : '',
          yogaIndex: data['yoga'] is Map ? (data['yoga']['number'] as num?)?.toInt() ?? 1 : 1,
          karana: data['karana'] is Map ? data['karana']['name'] ?? '' : '',
          moonLongitude: data['moon_position'] is Map ? (data['moon_position']['moon_degree'] as num?)?.toDouble() ?? 0.0 : 0.0,
          sunLongitude: data['sun_position'] is Map ? (data['sun_position']['sun_degree_at_rise'] as num?)?.toDouble() ?? 0.0 : 0.0,
          vara: adv['vaara'] ?? '',
          varaEnglish: adv['vaara'] ?? '',
          isShuklapaksha: adv['masa'] is Map ? adv['masa']['paksha']?.toString().contains('Shukla') ?? true : true,
          moonPhasePercent: 50.0, 
          rahuKalamStart: _extractTime(data['rahukaal']?.toString(), 0),
          rahuKalamEnd: _extractTime(data['rahukaal']?.toString(), 1),
          yamagandamStart: _extractTime(data['yamakanta']?.toString(), 0),
          yamagandamEnd: _extractTime(data['yamakanta']?.toString(), 1),
          gulikaKalamStart: _extractTime(data['gulika']?.toString(), 0),
          gulikaKalamEnd: _extractTime(data['gulika']?.toString(), 1),
          abhijitMuhurta: (adv['abhijit_muhurta'] is Map)
              ? '${adv['abhijit_muhurta']['start']} - ${adv['abhijit_muhurta']['end']}'
              : '',
        );
      }
      
      throw Exception('API returned status ${response.statusCode}');
    } catch (e) {
      print('Panchang API Error: $e');
      rethrow;
    }
  }

  String _extractTime(String? timeStr, int index) {
    if (timeStr == null || timeStr.isEmpty) return '';
    final parts = timeStr.split(' to ');
    if (index >= parts.length) return '';
    return parts[index].trim();
  }

  String _rashiName(int index) {
    const names = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    return names[index % 12];
  }
}
