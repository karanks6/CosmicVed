import 'package:sweph/sweph.dart';

/// Pure-Dart Astronomical Engine using the Swiss Ephemeris (`sweph` package)
/// Provides ultra-high precision calculations matching NASA JPL ephemerides.
class EphemerisService {
  // Singleton instance
  static final EphemerisService instance = EphemerisService._();
  EphemerisService._();

  static const _ayanamsaMode = SiderealMode.SE_SIDM_LAHIRI;
  static const _swephFlags = SwephFlag(64 * 1024 | 256); // SEFLG_SIDEREAL | SEFLG_SPEED (bitwise OR of values: 65536 | 256)

  static SwephFlag get _flags => _swephFlags;

  static double calculateAyanamsa(DateTime date) {
    final jd = getJulianDay(date);
    return Sweph.swe_get_ayanamsa_ut(jd);
  }

  static double getJulianDay(DateTime date) {
    // swe_julday expects UTC time. Since our input is UTC, this is fine.
    // However, to be perfectly accurate, we provide year, month, day, hour (decimal).
    final timeFrac = date.hour + date.minute / 60.0 + date.second / 3600.0;
    return Sweph.swe_julday(date.year, date.month, date.day, timeFrac, CalendarType.SE_GREG_CAL);
  }

  /// Ensure sidereal mode is set before any calculations
  static void _ensureSiderealMode() {
    Sweph.swe_set_sid_mode(_ayanamsaMode);
  }

  // Returns Sun's sidereal longitude (0-360)
  static double getSunLongitude(double jd) {
    _ensureSiderealMode();
    final pos = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, _flags);
    return pos.longitude;
  }

  // Returns Moon's sidereal longitude (0-360)
  static double getMoonLongitude(double jd) {
    _ensureSiderealMode();
    final pos = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, _flags);
    return pos.longitude;
  }
  
  // Calculate specific planet
  static CoordinatesWithSpeed getPlanet(double jd, HeavenlyBody body) {
    _ensureSiderealMode();
    return Sweph.swe_calc_ut(jd, body, _flags);
  }

  // Returns Ascendant (Lagna) Sidereal
  static double getAscendant(double jd, double lat, double lon, double ayanamsa) {
    _ensureSiderealMode();
    // Calculate houses in Placidus (or Whole Sign 'W'). We just need the Ascendant.
    final houses = Sweph.swe_houses_ex(jd, _flags, lat, lon, Hsys.P);
    // ascmc[0] is Ascendant
    return houses.ascmc[0];
  }
}
