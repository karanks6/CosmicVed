import 'dart:math' as math;
import '../../models/models.dart';
import '../../constants/astrology_constants.dart';
import '../ephemeris/ephemeris_service.dart';

/// Panchang (Hindu almanac) calculator
class PanchangService {
  PanchangService._();
  static final PanchangService instance = PanchangService._();

  final _eph = EphemerisService.instance;

  /// Calculate Panchang for a given date and location
  Panchang calculate({
    required DateTime dateLocal,
    required double latitude,
    required double longitude,
    required int utcOffsetMinutes,
  }) {
    // Convert local date to UTC noon for calculations
    final utcDate = dateLocal.subtract(Duration(minutes: utcOffsetMinutes));
    final jd = EphemerisService.getJulianDay(utcDate);
    final ayanamsa = EphemerisService.calculateAyanamsa(utcDate);

    final tropSun = EphemerisService.getSunLongitude(jd);
    final tropMoon = EphemerisService.getMoonLongitude(jd);

    final sidSun = (tropSun - ayanamsa) % 360.0;
    final sidMoon = (tropMoon - ayanamsa) % 360.0;

    // ── Tithi ──
    // Tithi = Moon - Sun elongation / 12 degrees
    double elongation = (sidMoon - sidSun) % 360.0;
    if (elongation < 0) elongation += 360.0;
    final tithiNum = (elongation / 12).floor() + 1; // 1–30
    final isShukla = tithiNum <= 15;
    final tithiName = AstrologyConstants.tithis[tithiNum - 1];

    // ── Vara (Day of Week) ──
    // JD day starts at noon, weekday from astronomical JD
    final jdInt = (jd + 1.5).floor();
    final varaIndex = jdInt % 7; // 0=Sun, 1=Mon, ..., 6=Sat
    final varaName = AstrologyConstants.varas[varaIndex];
    final varaEnglish = AstrologyConstants.varasEnglish[varaIndex];

    // ── Nakshatra ──
    final normalizedMoon = ((sidMoon % 360) + 360) % 360;
    final nkIdx = (normalizedMoon / (360.0 / 27)).floor() % 27;
    final nkPada = ((normalizedMoon % (360.0 / 27)) / (360.0 / 27 / 4)).floor() + 1;

    // ── Yoga ──
    // Yoga = (Sun + Moon sidereal) / (360/27)
    double yogaLon = ((sidSun + sidMoon) % 360);
    final yogaIndex = (yogaLon / (360.0 / 27)).floor() % 27;
    final yogaName = AstrologyConstants.yogas[yogaIndex];

    // ── Karana ──
    // Half-tithi = karana
    final karanaIndex = ((tithiNum - 1) * 2 + (elongation % 12 > 6 ? 1 : 0)) % 11;
    final karanaName = AstrologyConstants.karanas[karanaIndex];

    // ── Rahu Kalam (Sunrise/Sunset based) ──
    // Approximate: use 6:00 AM–6:00 PM as day period
    final rahuData = _calculateRahuKalam(varaIndex, dateLocal, utcOffsetMinutes);

    // ── Moon Phase ──
    final moonPhase = (elongation / 360.0 * 100).clamp(0.0, 100.0);

    // ── Abhijit Muhurta (midday auspicious period) ──
    // Approximately 11:36 AM to 12:24 PM local solar time
    final sunriseEst = DateTime(
        dateLocal.year, dateLocal.month, dateLocal.day, 6, 0);
    final sunsetEst = DateTime(
        dateLocal.year, dateLocal.month, dateLocal.day, 18, 0);
    final dayDuration = sunsetEst.difference(sunriseEst).inMinutes;
    final abhijitStart = sunriseEst.add(
      Duration(minutes: (dayDuration * 11.5 / 15).round()),
    );
    final abhijitEnd = abhijitStart.add(const Duration(minutes: 48));
    final abhijitMuhurta = '${_fmtTime(abhijitStart)} – ${_fmtTime(abhijitEnd)}';

    return Panchang(
      date: dateLocal,
      tithi: tithiName,
      tithiNumber: tithiNum,
      vara: varaName,
      varaEnglish: varaEnglish,
      nakshatra: AstrologyConstants.nakshatras[nkIdx],
      nakshatraIndex: nkIdx,
      yoga: yogaName,
      yogaIndex: yogaIndex,
      karana: karanaName,
      moonLongitude: sidMoon,
      sunLongitude: sidSun,
      rahuKalamStart: rahuData['rahu_start']!,
      rahuKalamEnd: rahuData['rahu_end']!,
      yamagandamStart: rahuData['yama_start']!,
      yamagandamEnd: rahuData['yama_end']!,
      gulikaKalamStart: rahuData['gulika_start']!,
      gulikaKalamEnd: rahuData['gulika_end']!,
      abhijitMuhurta: abhijitMuhurta,
      moonPhasePercent: moonPhase,
      isShuklapaksha: isShukla,
      isOffline: true,
    );
  }

  Map<String, String> _calculateRahuKalam(
    int varaIndex,
    DateTime date,
    int utcOffsetMinutes,
  ) {
    // Approximate sunrise/sunset: 6:00 AM / 6:00 PM
    // Each "segment" = 1.5 hours of the 12-hour day
    const baseHour = 6.0; // 6:00 AM
    const segmentHours = 1.5;

    // Rahu Kalam segments (1-indexed, 1=6:00-7:30, 2=7:30-9:00, etc.)
    // Day: Sun=7, Mon=2, Tue=7(wait—), using traditional lookup:
    const rahuSegments = [7, 2, 7, 5, 6, 4, 3]; // Sun=7,Mon=2,...,Sat=3 (1-based segments)
    // Yamagandam
    const yamaSegments = [5, 4, 3, 2, 1, 7, 6];
    // Gulika
    const gulikaSegments = [6, 5, 4, 3, 2, 1, 7];

    String _segmentTime(int segIndex) {
      final start = baseHour + (segIndex - 1) * segmentHours;
      final end = start + segmentHours;
      final startH = start.floor();
      final startM = ((start - startH) * 60).round();
      final endH = end.floor();
      final endM = ((end - endH) * 60).round();
      return '${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')} - ${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';
    }

    final rahuSeg = rahuSegments[varaIndex];
    final yamaSeg = yamaSegments[varaIndex];
    final gulikaSeg = gulikaSegments[varaIndex];

    final rahuTime = _segmentTime(rahuSeg).split(' - ');
    final yamaTime = _segmentTime(yamaSeg).split(' - ');
    final gulikaTime = _segmentTime(gulikaSeg).split(' - ');

    return {
      'rahu_start': rahuTime[0],
      'rahu_end': rahuTime[1],
      'yama_start': yamaTime[0],
      'yama_end': yamaTime[1],
      'gulika_start': gulikaTime[0],
      'gulika_end': gulikaTime[1],
    };
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
