import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

/// DAO for numerology results
class NumerologyDao {
  Future<Database> get _db => AppDatabase.instance.database;

  Future<int> insertOrReplace(Map<String, dynamic> data) async {
    final db = await _db;
    return db.insert(
      'numerology_results',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> get({
    required int profileId,
    required String resultType,
    String? inputName,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'numerology_results',
      where: 'profile_id = ? AND result_type = ?${inputName != null ? ' AND input_name = ?' : ''}',
      whereArgs: [profileId, resultType, if (inputName != null) inputName],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllForProfile(int profileId) async {
    final db = await _db;
    return db.query(
      'numerology_results',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'generated_at DESC',
    );
  }

  Future<void> deleteForProfile(int profileId) async {
    final db = await _db;
    await db.delete(
      'numerology_results',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
  }
}

/// DAO for horoscope cache
class HoroscopeCacheDao {
  Future<Database> get _db => AppDatabase.instance.database;

  Future<void> insertOrReplace(Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert(
      'horoscope_cache',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> get({
    required int profileId,
    required String cacheType,
    required String periodKey,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'horoscope_cache',
      where: 'profile_id = ? AND cache_type = ? AND period_key = ?',
      whereArgs: [profileId, cacheType, periodKey],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<void> clearOlderThan(DateTime cutoff) async {
    final db = await _db;
    await db.delete(
      'horoscope_cache',
      where: 'generated_at < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }
}

/// DAO for birth charts
class BirthChartDao {
  Future<Database> get _db => AppDatabase.instance.database;

  Future<int> insertOrReplace(Map<String, dynamic> data) async {
    final db = await _db;
    // Delete existing chart for this profile before inserting
    await db.delete(
      'birth_charts',
      where: 'profile_id = ?',
      whereArgs: [data['profile_id']],
    );
    return db.insert('birth_charts', data);
  }

  Future<Map<String, dynamic>?> getForProfile(int profileId) async {
    final db = await _db;
    final rows = await db.query(
      'birth_charts',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'generated_at DESC',
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<void> deleteForProfile(int profileId) async {
    final db = await _db;
    await db.delete(
      'birth_charts',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
  }
}

/// DAO for daily history
class DailyHistoryDao {
  Future<Database> get _db => AppDatabase.instance.database;

  Future<void> insertOrReplace(Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert(
      'daily_history',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getForDate({
    required int profileId,
    required String date,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'daily_history',
      where: 'profile_id = ? AND date = ?',
      whereArgs: [profileId, date],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<List<Map<String, dynamic>>> getRecent(int profileId, {int limit = 30}) async {
    final db = await _db;
    return db.query(
      'daily_history',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }
}
