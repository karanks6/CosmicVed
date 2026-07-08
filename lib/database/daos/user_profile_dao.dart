import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

/// DAO for user profile CRUD operations
class UserProfileDao {
  Future<Database> get _db => AppDatabase.instance.database;

  // ── Create ────────────────────────────────────────────────────────────────
  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _db;
    // Deactivate all other profiles when inserting new one
    if (data['is_active'] == 1) {
      await db.update(
        'user_profiles',
        {'is_active': 0},
        where: 'is_active = 1',
      );
    }
    return db.insert('user_profiles', data);
  }

  // ── Read ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<Map<String, dynamic>?> getActive() async {
    final db = await _db;
    final rows = await db.query(
      'user_profiles',
      where: 'is_active = 1 AND is_archived = 0',
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<List<Map<String, dynamic>>> getAll({bool includeArchived = false}) async {
    final db = await _db;
    return db.query(
      'user_profiles',
      where: includeArchived ? null : 'is_archived = 0',
      orderBy: 'is_active DESC, created_at ASC',
    );
  }

  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM user_profiles WHERE is_archived = 0');
    return (result.first['c'] as int?) ?? 0;
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await _db;
    data['updated_at'] = DateTime.now().toIso8601String();
    return db.update('user_profiles', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setActive(int id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update('user_profiles', {'is_active': 0});
      await txn.update(
        'user_profiles',
        {'is_active': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // ── Delete / Archive ──────────────────────────────────────────────────────
  Future<int> archive(int id) async {
    final db = await _db;
    return db.update(
      'user_profiles',
      {
        'is_archived': 1,
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('user_profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete('user_profiles');
  }
}
