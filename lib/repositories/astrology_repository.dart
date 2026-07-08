import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/daos/other_daos.dart';
import '../models/models.dart';
import '../models/user_profile.dart';
import '../services/ephemeris/ephemeris_service.dart';
import '../services/astrology/astrology_api_service.dart';
import '../services/astrology/panchang_service.dart';
import '../core/result/result.dart';

/// Repository for all astrology operations
class AstrologyRepository {
  final BirthChartDao _chartDao;
  final HoroscopeCacheDao _cacheDao;
  final DailyHistoryDao _historyDao;
  final EphemerisService _eph;

  AstrologyRepository({
    BirthChartDao? chartDao,
    HoroscopeCacheDao? cacheDao,
    DailyHistoryDao? historyDao,
    EphemerisService? eph,
  })  : _chartDao = chartDao ?? BirthChartDao(),
        _cacheDao = cacheDao ?? HoroscopeCacheDao(),
        _historyDao = historyDao ?? DailyHistoryDao(),
        _eph = eph ?? EphemerisService.instance;

  // ─── Birth Chart ──────────────────────────────────────────────────────────

  Future<Result<Kundali>> getOrCalculateKundali(UserProfile profile, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        // Check cache
        final cached = await _chartDao.getForProfile(profile.id!);
        if (cached != null) {
          final kundali = Kundali.fromJson(cached['chart_json'] as String);
          return Success(kundali);
        }
      }
      // Calculate fresh
      return await calculateAndSaveKundali(profile);
    } catch (e) {
      return Failure(CalculationFailure('Failed to get Kundali: $e'));
    }
  }

  Future<Result<Kundali>> calculateAndSaveKundali(UserProfile profile) async {
    try {
      Kundali? kundali;
      
      // 1. Check Network Connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      bool isOnline = connectivityResult.isNotEmpty && !connectivityResult.contains(ConnectivityResult.none);

      if (isOnline) {
        // 2. Attempt API Fetch
        try {
          kundali = await AstrologyApiService.instance.fetchKundali(profile);
        } catch (e) {
          // Log API failure, silently continue to offline fallback
          print('Astrology API fetch failed, falling back to offline calculations: $e');
        }
      }

      // 3. Offline Fallback if API failed or device is offline
      kundali ??= _eph.calculateKundali(
        birthDateTimeUtc: profile.birthDateTimeUtc,
        latitude: profile.latitude,
        longitude: profile.longitude,
      );

      // 4. Persist to cache
      await _chartDao.insertOrReplace({
        'profile_id': profile.id,
        'chart_json': kundali.toJson(),
        'generated_at': DateTime.now().toIso8601String(),
      });

      return Success(kundali);
    } catch (e) {
      return Failure(CalculationFailure('Kundali calculation failed: $e'));
    }
  }

  // ─── Panchang ─────────────────────────────────────────────────────────────

  Future<Result<Panchang>> getOrCalculatePanchang({
    required int profileId,
    required DateTime dateLocal,
    required double latitude,
    required double longitude,
    required int utcOffsetMinutes,
    bool forceRefresh = false,
  }) async {
    try {
      final dateStr = '${dateLocal.year}-${dateLocal.month}-${dateLocal.day}';
      
      // 1. Check Cache
      if (!forceRefresh) {
        final cached = await _cacheDao.get(
          profileId: profileId,
          cacheType: 'panchang',
          periodKey: dateStr,
        );
        if (cached != null) {
          return Success(Panchang.fromJson(cached['content_json'] as String));
        }
      }

      Panchang? panchang;
      
      // 1. Check Network Connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      bool isOnline = connectivityResult.isNotEmpty && !connectivityResult.contains(ConnectivityResult.none);

      if (isOnline) {
        // 2. Attempt API Fetch
        try {
          panchang = await AstrologyApiService.instance.fetchPanchang(dateLocal, latitude, longitude);
        } catch (e) {
          // Log API failure, silently continue to offline fallback
          print('Panchang API fetch failed, falling back to offline calculations: $e');
        }
      }

      // 3. Offline Fallback
      if (panchang == null) {
        panchang = PanchangService.instance.calculate(
          dateLocal: dateLocal,
          latitude: latitude,
          longitude: longitude,
          utcOffsetMinutes: utcOffsetMinutes,
        );
      }
      // 4. Save to Cache
      await _cacheDao.insertOrReplace({
        'profile_id': profileId,
        'cache_type': 'panchang',
        'period_key': dateStr,
        'content_json': panchang.toJson(),
        'generated_at': DateTime.now().toIso8601String(),
      });

      return Success(panchang);
    } catch (e) {
      return Failure(CalculationFailure('Panchang calculation failed: $e'));
    }
  }

  // ─── Horoscope Cache ──────────────────────────────────────────────────────

  Future<Result<Map<String, dynamic>?>> getCachedForecast({
    required int profileId,
    required String type, // 'daily', 'weekly', 'monthly', 'yearly'
    required String periodKey,
  }) async {
    try {
      final row = await _cacheDao.get(
        profileId: profileId,
        cacheType: type,
        periodKey: periodKey,
      );
      if (row == null) return const Success(null);
      return Success(jsonDecode(row['content_json'] as String) as Map<String, dynamic>);
    } catch (e) {
      return Failure(CacheFailure('$e'));
    }
  }

  Future<void> saveForecast({
    required int profileId,
    required String type,
    required String periodKey,
    required Map<String, dynamic> content,
  }) async {
    await _cacheDao.insertOrReplace({
      'profile_id': profileId,
      'cache_type': type,
      'period_key': periodKey,
      'content_json': jsonEncode(content),
      'generated_at': DateTime.now().toIso8601String(),
    });
  }

  // ─── Daily History ────────────────────────────────────────────────────────

  Future<Result<Map<String, dynamic>?>> getDailyHistory({
    required int profileId,
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final row = await _historyDao.getForDate(
        profileId: profileId,
        date: dateStr,
      );
      if (row == null) return const Success(null);
      return Success(row);
    } catch (e) {
      return Failure(DatabaseFailure('$e'));
    }
  }

  Future<void> saveDailyHistory({
    required int profileId,
    required DateTime date,
    Map<String, dynamic>? panchang,
    Map<String, dynamic>? forecast,
    String? rahuKalam,
  }) async {
    final dateStr = date.toIso8601String().split('T').first;
    await _historyDao.insertOrReplace({
      'profile_id': profileId,
      'date': dateStr,
      'panchang_json': panchang != null ? jsonEncode(panchang) : null,
      'forecast_json': forecast != null ? jsonEncode(forecast) : null,
      'rahu_kalam': rahuKalam,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
