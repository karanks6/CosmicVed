import 'dart:math' as math;
import '../../models/models.dart';

/// Pure-Dart Astronomical Engine based on Jean Meeus' "Astronomical Algorithms"
/// Provides low-precision (approx 0.1 degree) calculations suitable for offline use without C-libraries.
class EphemerisService {
  // Singleton instance
  static final EphemerisService instance = EphemerisService._();
  EphemerisService._();
  
  // Lahiri Ayanamsa epoch (approx)
  // For precise calculations, Lahiri ayanamsa increases by ~50.29 arcseconds per year.
  static double calculateAyanamsa(DateTime date) {
    // Julian Year 2000.0 is approx 2451545.0
    // Lahiri value at J2000.0 was approx 23°51'11" = 23.853 degrees
    final jd = getJulianDay(date);
    final t = (jd - 2451545.0) / 36525.0; // Julian centuries since J2000
    // Approximate linear drift of ayanamsa
    return 23.853 + (t * 1.396); 
  }

  static double getJulianDay(DateTime date) {
    int y = date.year;
    int m = date.month;
    int d = date.day;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    
    // Gregorian calendar adjustment
    final a = y ~/ 100;
    final b = 2 - a + (a ~/ 4);
    
    // Time fraction
    final timeFraction = (date.hour + date.minute / 60.0 + date.second / 3600.0) / 24.0;
    
    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524.5 + timeFraction;
  }

  // Returns Sun's tropical longitude (0-360)
  static double getSunLongitude(double jd) {
    final d = jd - 2451545.0;
    // Mean anomaly of the Sun
    double g = (357.529 + 0.98560028 * d) % 360.0;
    // Mean longitude of the Sun
    double q = (280.459 + 0.98564736 * d) % 360.0;
    
    // Equation of center
    double gRad = g * math.pi / 180.0;
    double l = q + 1.915 * math.sin(gRad) + 0.020 * math.sin(2 * gRad);
    return (l % 360.0 + 360.0) % 360.0;
  }

  // Returns Moon's tropical longitude (0-360)
  static double getMoonLongitude(double jd) {
    final d = jd - 2451545.0;
    // Mean longitude of the Moon
    double l = (218.316 + 13.176396 * d) % 360.0;
    // Mean anomaly of the Moon
    double m = (134.963 + 13.064993 * d) % 360.0;
    // Mean elongation of the Moon
    double dElong = (297.850 + 12.190749 * d) % 360.0;
    
    double mRad = m * math.pi / 180.0;
    double dRad = dElong * math.pi / 180.0;
    
    double lon = l + 6.289 * math.sin(mRad) + 1.274 * math.sin(dRad - mRad) + 0.658 * math.sin(2 * dRad);
    return (lon % 360.0 + 360.0) % 360.0;
  }
  
  // Approximate other planets (Very low precision - mean longitudes only for demo)
  static double getMeanPlanetLongitude(double jd, double base, double dailyMotion) {
    final d = jd - 2451545.0;
    return ((base + dailyMotion * d) % 360.0 + 360.0) % 360.0;
  }

  // Returns Ascendant (Lagna) Sidereal
  static double getAscendant(double jd, double lat, double lon, double ayanamsa) {
    // Greenwhich Mean Sidereal Time (GMST) at 0h UT
    final d = jd - 2451545.0;
    double gmst = (280.46061837 + 360.98564736629 * d) % 360.0;
    if (gmst < 0) gmst += 360.0;
    
    // Local Sidereal Time (LST)
    double lst = (gmst + lon) % 360.0;
    double lstRad = lst * math.pi / 180.0;
    
    // Obliquity of the ecliptic
    double e = 23.439 * math.pi / 180.0;
    
    double latRad = lat * math.pi / 180.0;
    
    // Ascendant formula
    double y = math.sin(lstRad);
    double x = math.cos(lstRad) * math.cos(e) + math.tan(latRad) * math.sin(e);
    
    double ascTropical = math.atan2(y, x) * 180.0 / math.pi;
    if (ascTropical < 0) ascTropical += 360.0;
    
    // Convert to Sidereal
    double ascSidereal = (ascTropical - ayanamsa + 360.0) % 360.0;
    return ascSidereal;
  }
  
  static String getNakshatraFromLongitude(double siderealLon) {
    const nakshatras = [
      'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra', 
      'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni', 
      'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 
      'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha', 
      'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
    ];
    int index = (siderealLon / (360.0 / 27.0)).floor();
    return nakshatras[index % 27];
  }
  
  static int getNakshatraPada(double siderealLon) {
    double remainder = siderealLon % (360.0 / 27.0);
    double padaSpan = (360.0 / 27.0) / 4.0;
    return (remainder / padaSpan).floor() + 1;
  }
  
  static int getRashiIndex(double lon) {
    return (lon / 30.0).floor() % 12;
  }

  Kundali calculateKundali({
    required DateTime birthDateTimeUtc,
    required double latitude,
    required double longitude,
  }) {
    final jd = getJulianDay(birthDateTimeUtc);
    final ayanamsa = calculateAyanamsa(birthDateTimeUtc);
    
    // Ascendant (Lagna)
    final ascSidereal = getAscendant(jd, latitude, longitude, ayanamsa);
    final ascRashi = getRashiIndex(ascSidereal);
    final ascRashiDeg = ascSidereal % 30.0;
    
    // Sun
    final sunTrop = getSunLongitude(jd);
    final sunSidereal = (sunTrop - ayanamsa + 360.0) % 360.0;
    final sunRashi = getRashiIndex(sunSidereal);
    
    // Moon
    final moonTrop = getMoonLongitude(jd);
    final moonSidereal = (moonTrop - ayanamsa + 360.0) % 360.0;
    final moonRashi = getRashiIndex(moonSidereal);
    final moonNak = getNakshatraFromLongitude(moonSidereal);
    final moonNakPada = getNakshatraPada(moonSidereal);
    
    // Other Planets (Mean Longitudes - approximated for offline non-C library use)
    // Mars: 1.88 yrs, Mercury: 88 days, Jupiter: 11.86 yrs, Venus: 224 days, Saturn: 29.45 yrs
    final marsSidereal = getMeanPlanetLongitude(jd, 355.4, 0.5240) - ayanamsa;
    final mercSidereal = getMeanPlanetLongitude(jd, 252.2, 4.0923) - ayanamsa;
    final jupSidereal = getMeanPlanetLongitude(jd, 34.3, 0.0831) - ayanamsa;
    final venSidereal = getMeanPlanetLongitude(jd, 181.9, 1.6021) - ayanamsa;
    final satSidereal = getMeanPlanetLongitude(jd, 50.0, 0.0334) - ayanamsa;
    
    // Rahu / Ketu (Nodes retrograde motion)
    final rahuSidereal = (getMeanPlanetLongitude(jd, 125.044, -0.05295) - ayanamsa + 360) % 360;
    final ketuSidereal = (rahuSidereal + 180) % 360;

    PlanetPosition makePlanet(String name, String sanskrit, double sidLon, bool retro) {
       final fixedLon = (sidLon + 360) % 360;
       final rashi = getRashiIndex(fixedLon);
       // House is 1-based, calculated relative to Ascendant rashi
       final house = ((rashi - ascRashi + 12) % 12) + 1;
       
       return PlanetPosition(
         name: name,
         nameSanskrit: sanskrit,
         longitude: (fixedLon + ayanamsa) % 360,
         siderealLongitude: fixedLon,
         rashiIndex: rashi,
         rashiDegrees: fixedLon % 30.0,
         isRetrograde: retro,
         houseNumber: house,
         nakshatra: getNakshatraFromLongitude(fixedLon),
         nakshatraPada: getNakshatraPada(fixedLon),
       );
    }

    final planets = [
      makePlanet('Sun', 'Surya', sunSidereal, false),
      makePlanet('Moon', 'Chandra', moonSidereal, false),
      makePlanet('Mars', 'Mangala', marsSidereal, false),
      makePlanet('Mercury', 'Budha', mercSidereal, false),
      makePlanet('Jupiter', 'Guru', jupSidereal, false),
      makePlanet('Venus', 'Shukra', venSidereal, false),
      makePlanet('Saturn', 'Shani', satSidereal, false),
      makePlanet('Rahu', 'Rahu', rahuSidereal, true),
      makePlanet('Ketu', 'Ketu', ketuSidereal, true),
    ];
    
    // House rashis (whole sign house system)
    List<int> houses = [];
    for (int i=0; i<12; i++) {
       houses.add((ascRashi + i) % 12);
    }
    
    const rashiNames = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];

    return Kundali(
      birthDateTime: birthDateTimeUtc,
      latitude: latitude,
      longitude: longitude,
      ayanamsa: ayanamsa,
      ascendantLongitude: ascSidereal,
      ascendantRashiIndex: ascRashi,
      ascendantDegrees: ascRashiDeg,
      planets: planets,
      houseRashis: houses,
      moonNakshatra: moonNak,
      moonNakshatraPada: moonNakPada,
      sunSign: rashiNames[sunRashi],
      moonSign: rashiNames[moonRashi],
      ascendantSign: rashiNames[ascRashi],
      calculatedAt: DateTime.now(),
      isOffline: true,
    );
  }
}
