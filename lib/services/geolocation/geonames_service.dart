import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../models/models.dart';

/// Offline GeoNames city lookup service
///
/// Bundles a SQLite database of ~130,000 cities with latitude, longitude,
/// and IANA timezone ID. Users never need to manually enter coordinates.
class GeonamesService {
  GeonamesService._();
  static final GeonamesService instance = GeonamesService._();

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationSupportDirectory();
    final dbFile = File(p.join(dir.path, 'geonames.db'));

    // Check if we need to copy the db from assets
    bool shouldCopy = false;
    ByteData? assetData;
    
    if (!dbFile.existsSync() || dbFile.lengthSync() < 100000) {
      shouldCopy = true;
    } else {
      try {
        assetData = await rootBundle.load('assets/data/geonames.db');
        if (dbFile.lengthSync() != assetData.lengthInBytes) {
          shouldCopy = true;
        }
      } catch (_) {
        shouldCopy = true;
      }
    }

    if (shouldCopy) {
      try {
        assetData ??= await rootBundle.load('assets/data/geonames.db');
        final bytes = assetData.buffer.asUint8List(
          assetData.offsetInBytes,
          assetData.lengthInBytes,
        );
        await dbFile.writeAsBytes(bytes, flush: true);
      } catch (e) {
        print('CRITICAL: Failed to load geonames.db. Did you restart the app? Error: $e');
        rethrow;
      }
    }

    return openDatabase(
      dbFile.path,
      readOnly: true,
    );
  }

  /// Search cities by partial name, optionally filtered by country code
  Future<List<GeoCity>> searchCities(
    String query, {
    String? countryCode,
    int limit = 20,
  }) async {
    if (query.trim().length < 2) return [];

    final db = await _database;
    final normalized = query.trim().toLowerCase();

    bool hasAlternateNames = false;
    try {
      final columns = await db.rawQuery('PRAGMA table_info(cities)');
      hasAlternateNames = columns.any((c) => (c['name'] as String?)?.toLowerCase() == 'alternate_names');
    } catch (_) {}

    // Try exact prefix match first, then contains
    final whereClause = countryCode != null
        ? (hasAlternateNames 
            ? '(ascii_name LIKE ? OR alternate_names LIKE ?) AND country_code = ?'
            : 'ascii_name LIKE ? AND country_code = ?')
        : (hasAlternateNames 
            ? 'ascii_name LIKE ? OR alternate_names LIKE ?'
            : 'ascii_name LIKE ?');

    final args = countryCode != null
        ? (hasAlternateNames 
            ? ['$normalized%', '%$normalized%', countryCode.toUpperCase()]
            : ['$normalized%', countryCode.toUpperCase()])
        : (hasAlternateNames 
            ? ['$normalized%', '%$normalized%']
            : ['$normalized%']);

    var results = await db.query(
      'cities',
      where: whereClause,
      whereArgs: args,
      orderBy: 'population DESC',
      limit: limit,
    );

    // Fall back to contains if no prefix results
    if (results.isEmpty) {
      final containsArgs = countryCode != null
          ? (hasAlternateNames 
              ? ['%$normalized%', '%$normalized%', countryCode.toUpperCase()]
              : ['%$normalized%', countryCode.toUpperCase()])
          : (hasAlternateNames 
              ? ['%$normalized%', '%$normalized%']
              : ['%$normalized%']);
              
      results = await db.query(
        'cities',
        where: countryCode != null
            ? (hasAlternateNames 
                ? '(ascii_name LIKE ? OR alternate_names LIKE ?) AND country_code = ?'
                : 'ascii_name LIKE ? AND country_code = ?')
            : (hasAlternateNames 
                ? 'ascii_name LIKE ? OR alternate_names LIKE ?'
                : 'ascii_name LIKE ?'),
        whereArgs: containsArgs,
        orderBy: 'population DESC',
        limit: limit,
      );
    }

    return results.map(GeoCity.fromMap).toList();
  }

  /// Get city by exact ID (for reliable round-trip lookup)
  Future<GeoCity?> getCityById(int id) async {
    final db = await _database;
    final rows = await db.query(
      'cities',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty ? GeoCity.fromMap(rows.first) : null;
  }

  /// Get nearest city to given coordinates
  Future<GeoCity?> getNearestCity(double lat, double lon) async {
    final db = await _database;
    // Approximate bounding box search (±2 degrees) then pick nearest
    final rows = await db.query(
      'cities',
      where: 'latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?',
      whereArgs: [lat - 2, lat + 2, lon - 2, lon + 2],
      orderBy: 'population DESC',
      limit: 50,
    );

    if (rows.isEmpty) return null;

    // Find closest by Haversine distance
    double minDist = double.infinity;
    Map<String, dynamic>? nearest;

    for (final row in rows) {
      final cityLat = (row['latitude'] as num).toDouble();
      final cityLon = (row['longitude'] as num).toDouble();
      final dist = _haversineKm(lat, lon, cityLat, cityLon);
      if (dist < minDist) {
        minDist = dist;
        nearest = row;
      }
    }

    return nearest != null ? GeoCity.fromMap(nearest) : null;
  }

  /// Get all countries (for filtering)
  Future<List<Map<String, String>>> getCountries() async {
    final db = await _database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT country_code, country_name FROM cities ORDER BY country_name',
    );
    return rows
        .map((r) => {
              'code': r['country_code'] as String,
              'name': r['country_name'] as String,
            })
        .toList();
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = _sin2(dLat / 2) +
        _cos(_rad(lat1)) * _cos(_rad(lat2)) * _sin2(dLon / 2);
    return r * 2 * _asin(_sqrt(a));
  }

  double _rad(double d) => d * 3.141592653589793 / 180;
  double _sin2(double r) {
    final s = _sin(r);
    return s * s;
  }

  // ignore: non_constant_identifier_names
  double _sin(double r) => double.parse(
      (r - r * r * r / 6 + r * r * r * r * r / 120).toStringAsFixed(10));
  double _cos(double r) {
    final s = _sin(r);
    return (1 - s * s) < 0 ? 0 : _sqrt(1 - s * s);
  }

  double _asin(double x) => x + x * x * x / 6 + 3 * x * x * x * x * x / 40;
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double r = x;
    for (int i = 0; i < 50; i++) {
      r = (r + x / r) / 2;
    }
    return r;
  }
}
