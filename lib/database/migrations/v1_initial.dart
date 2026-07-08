import 'package:sqflite/sqflite.dart';

/// Version 1 — Initial database schema
class V1InitialMigration {
  static Future<void> up(Database db) async {
    final batch = db.batch();

    // ── User Profiles ──────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS user_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT NOT NULL CHECK(gender IN ('male','female','other')),
        date_of_birth TEXT NOT NULL,
        time_of_birth TEXT NOT NULL,
        birth_city TEXT NOT NULL,
        birth_country TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timezone_id TEXT NOT NULL,
        utc_offset_minutes INTEGER NOT NULL DEFAULT 0,
        avatar_index INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ── Birth Charts ───────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS birth_charts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        chart_json TEXT NOT NULL,
        navamsa_json TEXT,
        dasha_json TEXT,
        generated_at TEXT NOT NULL,
        FOREIGN KEY(profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    // ── Numerology Results ─────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS numerology_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        result_type TEXT NOT NULL,
        input_name TEXT,
        result_number INTEGER NOT NULL,
        result_json TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        FOREIGN KEY(profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE,
        UNIQUE(profile_id, result_type, input_name)
      )
    ''');

    // ── Horoscope Cache ────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS horoscope_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        cache_type TEXT NOT NULL,
        period_key TEXT NOT NULL,
        content_json TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        UNIQUE(profile_id, cache_type, period_key),
        FOREIGN KEY(profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    // ── Compatibility Reports ──────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS compatibility_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id_a INTEGER NOT NULL,
        profile_id_b INTEGER NOT NULL,
        compat_type TEXT NOT NULL,
        total_score REAL,
        result_json TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        FOREIGN KEY(profile_id_a) REFERENCES user_profiles(id) ON DELETE CASCADE,
        FOREIGN KEY(profile_id_b) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    // ── Remedies ───────────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS remedies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        remedy_type TEXT NOT NULL,
        planet TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        reason TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY(profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    // ── Learning Progress ──────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS learning_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        lesson_id TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        quiz_score INTEGER,
        completed_at TEXT,
        UNIQUE(profile_id, lesson_id),
        FOREIGN KEY(profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    // ── PDF Reports ────────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS pdf_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        report_type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size_bytes INTEGER,
        generated_at TEXT NOT NULL,
        FOREIGN KEY(profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    // ── Favorites ──────────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        item_type TEXT NOT NULL,
        item_id TEXT NOT NULL,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(profile_id, item_type, item_id),
        FOREIGN KEY(profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    // ── Daily History ──────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS daily_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        panchang_json TEXT,
        forecast_json TEXT,
        rahu_kalam TEXT,
        muhurta_json TEXT,
        created_at TEXT NOT NULL,
        UNIQUE(profile_id, date),
        FOREIGN KEY(profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE
      )
    ''');

    // ── Settings (key-value store) ─────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ─── Indexes ────────────────────────────────────────────────────────────
    batch.execute('CREATE INDEX IF NOT EXISTS idx_profiles_active ON user_profiles(is_active)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_charts_profile ON birth_charts(profile_id)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_numerology_profile ON numerology_results(profile_id)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_cache_profile_type ON horoscope_cache(profile_id, cache_type)');
    batch.execute('CREATE INDEX IF NOT EXISTS idx_history_profile_date ON daily_history(profile_id, date)');

    await batch.commit(noResult: true);
  }
}
