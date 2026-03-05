import 'dart:convert';

import 'package:path_finder/model/route_point.dart';
import 'package:postgres/postgres.dart';

class DbService {
  static Future<Connection?> _connect() async {
    try {
      return await Connection.open(
        Endpoint(
          host: 'localhost',
          port: 5432,
          database: 'mydb',
          username: 'myuser',
          password: 'mysecretpassword',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> chechConnect() async {
    final conn = await _connect();
    if (conn == null) {
      return false;
    } else {
      return true;
    }
  }

  static Future<Map<String, dynamic>?> getUserCredentials(String login) async {
    final conn = await _connect();
    if (conn == null) return null;
    try {
      final result = await conn.execute(
        'SELECT id, salt, hash_password FROM users WHERE login = \$1',
        parameters: [login],
      );
      if (result.isEmpty) return null;
      return {
        'id': result.first[0] as int,
        'salt': result.first[1] as String,
        'hashPassword': result.first[2] as String,
      };
    } finally {
      await conn.close();
    }
  }

  static Future<String?> getNewSalt() async {
    final conn = await _connect();
    if (conn == null) return null;
    try {
      final result = await conn.execute(
        'SELECT encode(gen_random_bytes(16), \'hex\')',
      );

      if (result.isEmpty) return null;
      return result.first[0] as String;
    } finally {
      await conn.close();
    }
  }

  static Future<bool?> addNewUser(
    String login,
    String salt,
    String hash,
  ) async {
    final conn = await _connect();
    if (conn == null) return null;
    try {
      await conn.runTx((tx) async {
        final result = await tx.execute(
          'INSERT INTO users (login, hash_password, salt) VALUES (\$1, \$2, \$3) RETURNING id',
          parameters: [login, hash, salt],
        );

        final int newId = result.first[0] as int;

        await tx.execute(
          'INSERT INTO users_profile (user_id) VALUES (\$1)',
          parameters: [newId],
        );
      });
      return true;
    } catch (e) {
      return false;
    } finally {
      await conn.close();
    }
  }

  static Future<bool?> saveProfile(
    int? id,
    int? age,
    bool? sex,
    double? weight,
    double? height,
    double? time1km,
    double? vo2,
  ) async {
    final conn = await _connect();
    if (conn == null) return null;
    try {
      await conn.execute(
        'UPDATE users_profile SET age = \$2, sex = \$3, weight_kg = \$4, height_cm = \$5, time_per_1km_min = \$6, VO2max_mlkg_min = \$7 WHERE user_id = \$1',
        parameters: [id, age, sex, weight, height, time1km, vo2],
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      await conn.close();
    }
  }

  static Future<Map<String, dynamic>?> getProfile(int userId) async {
    final conn = await _connect();
    if (conn == null) return null;
    try {
      final result = await conn.execute(
        'SELECT age, sex, weight_kg, height_cm, time_per_1km_min, VO2max_mlkg_min '
        'FROM users_profile WHERE user_id = \$1',
        parameters: [userId],
      );
      if (result.isEmpty) return null;
      final row = result.first;
      return {
        'age': row[0] as int?,
        'sex': row[1] as bool?,
        'weight': row[2] as double?,
        'height': row[3] as double?,
        'timePer1kmMin': row[4] as double?,
        'vo2': row[5] as double?,
      };
    } finally {
      await conn.close();
    }
  }

  static Future<bool> saveRoute({
    required int userId,
    required double? distanceKm,
    required double? totalAscent,
    required List<Map<String, dynamic>> points,
  }) async {
    final conn = await _connect();
    if (conn == null) return false;
    try {
      await conn.execute(
        'INSERT INTO routes (user_id, distance_km, total_ascent_m, points) '
        'VALUES (\$1, \$2, \$3, \$4)',
        parameters: [userId, distanceKm, totalAscent, jsonEncode(points)],
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      await conn.close();
    }
  }

  static Future<List<Map<String, dynamic>>> getRoutes(int userId) async {
    final conn = await _connect();
    if (conn == null) return [];
    try {
      final result = await conn.execute(
        'SELECT id, name, distance_km, total_ascent_m, created_at '
        'FROM routes WHERE user_id = \$1 ORDER BY created_at DESC',
        parameters: [userId],
      );
      return result
          .map(
            (row) => {
              'id': (row[0] as num).toInt(),
              'name': row[1] as String?,
              'distance_km': row[2] != null ? (row[2] as num).toDouble() : null,
              'total_ascent_m': row[3] != null
                  ? (row[3] as num).toDouble()
                  : null,
              'created_at': row[4] as DateTime,
            },
          )
          .toList();
    } finally {
      await conn.close();
    }
  }

  static Future<bool?> deleteRoute(int routeId) async {
    final conn = await _connect();
    if (conn == null) return null;
    try {
      await conn.execute(
        'DELETE FROM routes WHERE id = \$1',
        parameters: [routeId],
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      await conn.close();
    }
  }

  static Future<bool?> updateRouteName(int routeId, String name) async {
    final conn = await _connect();
    if (conn == null) return null;
    try {
      await conn.execute(
        'UPDATE routes SET name = \$1 WHERE id = \$2',
        parameters: [name, routeId],
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      await conn.close();
    }
  }

  static Future<List<RoutePoint>> getRoutePoints(int routeId) async {
    final conn = await _connect();
    if (conn == null) return [];
    try {
      final result = await conn.execute(
        'SELECT points FROM routes WHERE id = \$1',
        parameters: [routeId],
      );
      if (result.isEmpty) return [];
      final List points = result.first[0] as List;
      return points
          .map(
            (p) => RoutePoint(
              latitude: (p['lat'] as num).toDouble(),
              longitude: (p['lng'] as num).toDouble(),
              altitude: (p['alt'] as num).toDouble(),
            ),
          )
          .toList();
    } finally {
      await conn.close();
    }
  }

  static Future<Map<String, dynamic>?> getRouteInfo(int routeId) async {
    final conn = await _connect();
    if (conn == null) return null;
    try {
      final result = await conn.execute(
        'SELECT distance_km, total_ascent_m FROM routes WHERE id = \$1',
        parameters: [routeId],
      );
      if (result.isEmpty) return null;
      return {
        'distance_km': result.first[0] != null
            ? (result.first[0] as num).toDouble()
            : null,
        'total_ascent_m': result.first[1] != null
            ? (result.first[1] as num).toDouble()
            : null,
      };
    } finally {
      await conn.close();
    }
  }
}
