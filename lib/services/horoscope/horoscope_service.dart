import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

class HoroscopeService {
  static final HoroscopeService instance = HoroscopeService._internal();
  final Dio _dio;

  // Simple in-memory cache
  // Key: '{period}_{sign}', Value: Map containing 'horoscope', 'date', 'fetchTime'
  final Map<String, Map<String, dynamic>> _cache = {};

  HoroscopeService._internal() : _dio = Dio(BaseOptions(
    // We now scrape directly from the source instead of using a middleman API
    baseUrl: 'https://www.horoscope.com/us/horoscopes/general/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  /// Maps the Vedic Moon Sign index (0 = Aries, 11 = Pisces) to the western sign string
  String _mapSignIndexToWesternSign(int signIndex) {
    const signs = [
      'aries', 'taurus', 'gemini', 'cancer',
      'leo', 'virgo', 'libra', 'scorpio',
      'sagittarius', 'capricorn', 'aquarius', 'pisces'
    ];
    return signs[signIndex % 12];
  }

  Future<String> fetchHoroscope(int signIndex, String period) async {
    final signStr = _mapSignIndexToWesternSign(signIndex);
    final cacheKey = '${period}_$signStr';

    // Check cache
    if (_cache.containsKey(cacheKey)) {
      final cacheData = _cache[cacheKey]!;
      final fetchTime = cacheData['fetchTime'] as DateTime;
      // Cache valid for 2 hours
      if (DateTime.now().difference(fetchTime).inHours < 2) {
        return cacheData['horoscope'] as String;
      }
    }

    try {
      String endpoint = '';
      if (period.toLowerCase() == 'daily') {
        endpoint = 'horoscope-general-daily-today.aspx';
      } else if (period.toLowerCase() == 'weekly') {
        endpoint = 'horoscope-general-weekly.aspx';
      } else if (period.toLowerCase() == 'monthly') {
        endpoint = 'horoscope-general-monthly.aspx';
      } else {
        endpoint = 'horoscope-general-daily-today.aspx';
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'sign': (signIndex + 1).toString(), // horoscope.com uses 1-12 (1=Aries)
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Parse the HTML using the html package
        var document = parse(response.data.toString());
        var paragraph = document.querySelector('.main-horoscope > p');
        
        if (paragraph != null) {
          // Extract text and remove the bolded date prefix (e.g. "Jul 7, 2026 - ")
          String horoscope = paragraph.text.trim();
          if (horoscope.contains(' - ')) {
             horoscope = horoscope.split(' - ').sublist(1).join(' - ');
          }
          
          // Save to cache
          _cache[cacheKey] = {
            'horoscope': horoscope,
            'fetchTime': DateTime.now(),
          };
          
          return horoscope;
        }
      }
      throw Exception('Failed to parse horoscope data');
    } catch (e) {
      // Fallback: Generate a deterministic offline horoscope if API is down
      return _generateOfflineFallback(signStr, period);
    }
  }

  String _generateOfflineFallback(String sign, String period) {
    final now = DateTime.now();
    int seed = 0;
    
    if (period.toLowerCase() == 'daily') {
      seed = now.year * 10000 + now.month * 100 + now.day;
    } else if (period.toLowerCase() == 'weekly') {
      // Get week of year
      int week = ((now.day - now.weekday + 10) / 7).floor();
      seed = now.year * 100 + week;
    } else {
      seed = now.year * 100 + now.month;
    }
    
    // Add sign-specific offset so each sign gets a unique reading
    seed += sign.codeUnits.fold(0, (prev, curr) => prev + curr);

    final List<String> intros = [
      "The cosmic energies are aligning in your favor today.",
      "A planetary shift brings new perspectives to your current situation.",
      "The stars suggest a period of introspection and careful planning.",
      "Expect a surge of creative energy as the moon traverses your sector.",
      "A harmonious aspect between Venus and Mars highlights your relationships.",
    ];

    final List<String> bodies = [
      "You may find yourself facing a choice that requires trusting your intuition over logic. Don't be afraid to take a calculated risk, especially in matters of personal growth.",
      "Communication is key right now. Someone close to you might need your guidance, or you might find the answers you seek by simply listening more closely to others.",
      "Financial matters look stable, but avoid impulse purchases. Focus your energy on long-term goals rather than short-term gratification.",
      "Your ruling planet is providing an extra boost of vitality. It's an excellent time to start a new health routine or tackle that project you've been putting off.",
      "Unexpected news could change your trajectory slightly. Stay adaptable and remember that sometimes the universe redirects us for our own good.",
    ];

    final List<String> conclusions = [
      "Embrace the unknown with an open heart.",
      "Patience will be your greatest asset moving forward.",
      "Trust that everything is unfolding exactly as it should.",
      "Your positive energy will attract exactly what you need.",
      "Take a moment to ground yourself before making big decisions.",
    ];

    // Use modulo arithmetic for deterministic selection
    final intro = intros[seed % intros.length];
    final body = bodies[(seed * 2) % bodies.length];
    final conclusion = conclusions[(seed * 3) % conclusions.length];

    String timeContext = period.toLowerCase() == 'daily' ? 'Today' : (period.toLowerCase() == 'weekly' ? 'This week' : 'This month');

    return "$intro $timeContext, $body $conclusion";
  }
}
