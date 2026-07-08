import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import 'migrations/v1_initial.dart';

/// Central SQLite database manager for CosmicVed
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await V1InitialMigration.up(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Future migration logic
        if (oldVersion < 1) await V1InitialMigration.up(db);
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
