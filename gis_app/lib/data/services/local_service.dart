import 'dart:convert';
import 'dart:io';

import 'package:gis_app/data/models/route_model.dart';
import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/utils/result.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalService {
  Database? _db;

  Future<Database> _getDb() async {
    if (_db != null) return _db!;

    final dir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(join(dir.path, 'PathFinder'));
    await dbDir.create(recursive: true);
    final path = join(dbDir.path, 'local_routes.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE local_routes (
          user_id INTEGER,
          route_id INTEGER,
          name TEXT,
          distance_km REAL,
          total_ascent_m REAL,
          created_at TEXT,
          points TEXT,
          PRIMARY KEY(user_id, route_id)
        )
      ''');
        await db.execute('''
        CREATE TABLE local_profile (
          id INTEGER PRIMARY KEY,
          data TEXT
        )
      ''');
      },
    );
    return _db!;
  }

  Future<MyResult<void>> saveProfile(
    int userId,
    Map<String, dynamic> profile,
  ) async {
    final db = await _getDb();
    try {
      await db.insert('local_profile', {
        'id': userId,
        'data': jsonEncode(profile),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return Ok(null);
    } catch (e) {
      return Error(Exception(e));
    }
  }

  Future<MyResult<Map<String, String?>>> getProfile(int userId) async {
    final db = await _getDb();

    final result = await db.query(
      'local_profile',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isEmpty) return Error(Exception("Пустой"));
    final Map<String, dynamic> decoded = jsonDecode(
      result.first['data'] as String,
    );

    // Конвертируем Map<String, dynamic> в Map<String, String?>
    final Map<String, String?> stringMap = {};
    decoded.forEach((key, value) {
      if (value != null) {
        stringMap[key] = value.toString();
      } else {
        stringMap[key] = null;
      }
    });

    return Ok(stringMap);
  }

  Future<MyResult<void>> deleteProfile(int userId) async {
    try {
      final db = await _getDb();
      await db.delete('local_profile', where: 'id = ?', whereArgs: [userId]);
      return Ok(null);
    } catch (e) {
      return Error(Exception(e));
    }
  }

  Future<MyResult<List<RouteModel>>> getRoutes(int userId) async {
    try {
      final db = await _getDb();
      final result = await db.query(
        'local_routes',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      final routes = result.map((row) {
        final pointsJson = jsonDecode(row['points'] as String) as List;
        final points = pointsJson
            .map((p) => RoutePoint.fromJson(p as Map<String, dynamic>))
            .toList();

        return RouteModel(
          row['route_id'] as int,
          points,
          row['total_ascent_m'] != null
              ? (row['total_ascent_m'] as num).toDouble()
              : 0,
          row['distance_km'] != null
              ? (row['distance_km'] as num).toDouble()
              : 0,
          DateTime.parse(row['created_at'] as String),
          row['name'] as String?,
          true, // isLocal
        );
      }).toList();

      return Ok(routes);
    } catch (e) {
      return Error(Exception('Failed to get local routes: $e'));
    }
  }

  Future<MyResult<void>> addRoute(
    int userId,
    double distance,
    double totalAscent,
    List<RoutePoint> routePoints,
  ) async {
    try {
      final db = await _getDb();
      await db.insert('local_routes', {
        'id': userId,
        'distance': distance,
        'total_asc': totalAscent,
        'points': jsonEncode(routePoints),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return Ok(null);
    } catch (e) {
      return Error(Exception(e));
    }
  }

  Future<MyResult<void>> downloadRoute(User user, RouteModel route) async {
    try {
      final db = await _getDb();
      await db.insert('local_routes', {
        'user_id': user.id,
        'route_id': route.routeId,
        'name': route.name,
        'created_at': route.createdAt.toString(),
        'distance_km': route.totaldistance,
        'total_ascent_m': route.totalAscent,
        'points': jsonEncode(route.routePoints),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return Ok(null);
    } catch (e) {
      return Error(Exception(e));
    }
  }

  Future<MyResult<void>> changeRouteName(
    String newName,
    int routeId,
    int userId,
  ) async {
    try {
      final db = await _getDb();
      await db.update(
        'local_routes',
        {'name': newName},
        where: 'user_id = ? AND route_id = ?',
        whereArgs: [userId, routeId],
      );
      return Ok(null);
    } catch (e) {
      return Error(Exception(e));
    }
  }

  Future<MyResult<void>> deleteRoute(int routeId, int userId) async {
    try {
      final db = await _getDb();
      await db.delete(
        'local_routes',
        where: 'route_id = ? AND user_id = ?',
        whereArgs: [routeId, userId],
      );
      return Ok(null);
    } catch (e) {
      return Error(Exception(e));
    }
  }
}
