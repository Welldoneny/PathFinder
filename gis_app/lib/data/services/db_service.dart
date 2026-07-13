import 'dart:convert';

import 'package:gis_app/data/models/predict_model.dart';
import 'package:gis_app/data/models/route_model.dart';
import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/models/user_credentials.dart';
import 'package:gis_app/data/models/user_profile.dart';
import 'package:gis_app/utils/result.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Сервис для взаимодействия с базой данных PostgreSQL.
class ServerService {
  Future<MyResult<PredictResult>> predict({
    required UserProfile profile,
    required double? gearWeight,
    required double? temp,
    required int? humidity,
    required double? distanceKm,
    required double? totalAscent,
  }) async {
    try {
      final uri = Uri.parse('http://localhost:8000/predict');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'age': double.tryParse(profile.age ?? '') ?? 0,
          'sex': profile.sex == 'Мужской' ? 1.0 : 0.0,
          'weight_kg': double.tryParse(profile.weight ?? '') ?? 0,
          'height_cm': double.tryParse(profile.height ?? '') ?? 0,
          'time_per_1km_min': double.tryParse(profile.kross ?? '') ?? 0,
          'VO2max_mlkg_min': double.tryParse(profile.vo2 ?? '') ?? 0,
          'backpack_weight_kg': gearWeight,
          'avg_temp_C': temp,
          'humidity_pct': humidity,
          'distance_km': distanceKm,
          'total_ascent_m': totalAscent,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Ok(PredictResult.fromJson(data));
      }
      return Error(Exception(response.statusCode));
    } catch (e) {
      return Error(Exception(e));
    }
  }

  ServerService._(); // приватный конструктор
  static final ServerService instance = ServerService._();

  /// Устанавливает соединение с базой данных PostgreSQL.
  Future<Connection?> _connect() async {
    try {
      return await Connection.open(
        Endpoint(
          host: dotenv.env['DB_HOST'] ?? 'localhost',
          port: int.parse(dotenv.env['DB_PORT'] ?? '5432'),
          database: dotenv.env['DB_NAME'] ?? '',
          username: dotenv.env['DB_USER'] ?? '',
          password: dotenv.env['DB_PASSWORD'] ?? '',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Connection timeout'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Проверяет соединение с базой данных.
  Future<MyResult<void>> checkConnect() async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    } else {
      await conn.close();
      return Ok(null);
    }
  }

  /// Получает учетные данные пользователя по логину.
  Future<MyResult<UserCredentials>> getUserCredentials(String login) async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    }
    try {
      final result = await conn.execute(
        'SELECT id, salt, hash_password FROM users WHERE login = \$1',
        parameters: [login],
      );
      if (result.isEmpty) return Error(Exception('User not found'));
      return Ok(
        UserCredentials(
          id: result.first[0] as int,
          salt: result.first[1] as String,
          hashPassword: result.first[2] as String,
        ),
      );
    } finally {
      await conn.close();
    }
  }

  /// Генерирует новую соль для хеширования пароля.
  Future<MyResult<String>> getNewSalt() async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    }
    try {
      final result = await conn.execute(
        'SELECT encode(gen_random_bytes(16), \'hex\')',
      );

      if (result.isEmpty) return Error(Exception('Failed to generate salt'));
      return Ok(result.first[0] as String);
    } finally {
      await conn.close();
    }
  }

  /// Добавляет нового пользователя в базу данных и создает его профиль
  Future<MyResult<User>> addNewUser(
    String login,
    String salt,
    String hash,
  ) async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    }
    try {
      final int newId = await conn.runTx((tx) async {
        final result = await tx.execute(
          'INSERT INTO users (login, hash_password, salt) VALUES (\$1, \$2, \$3) RETURNING id',
          parameters: [login, hash, salt],
        );

        final int newId = result.first[0] as int;

        await tx.execute(
          'INSERT INTO users_profile (user_id) VALUES (\$1)',
          parameters: [newId],
        );
        return newId;
      });
      return Ok(User(id: newId, login: login));
    } catch (e) {
      return Error(Exception('Failed to add new user: $e'));
    } finally {
      await conn.close();
    }
  }

  /// добавляет новый маршрут
  Future<MyResult<void>> addRoute(
    User user,
    double distance,
    double totalAscent,
    List<RoutePoint> routePoints,
  ) async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    }
    try {
      await conn.execute(
        'INSERT INTO routes (user_id, distance_km, total_ascent_m, points) '
        'VALUES (\$1, \$2, \$3, \$4)',
        parameters: [user.id, distance, totalAscent, jsonEncode(routePoints)],
      );
      return Ok(null);
    } catch (e) {
      return Error(Exception('Failed to add new route: $e'));
    } finally {
      await conn.close();
    }
  }

  /// возвращает данные профиля пользователя
  Future<MyResult<UserProfile>> getProfile(int userId) async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    }
    try {
      final result = await conn.execute(
        'SELECT age, weight_kg, height_cm, sex, time_per_1km_min, VO2max_mlkg_min '
        'FROM users_profile WHERE user_id = \$1',
        parameters: [userId],
      );
      if (result.isEmpty) return Error(Exception('Loaded empty profile'));
      final row = result.first;
      UserProfile userProfile = UserProfile(
        row[0]?.toString(),
        row[1]?.toString(),
        row[2]?.toString(),
        row[3] != null ? (row[3] as bool ? "Мужской" : "Женский") : null,
        row[4]?.toString(),
        row[5]?.toString(),
      );
      return Ok(userProfile);
    } catch (e) {
      return Error(Exception('Failed to load profile: $e'));
    } finally {
      await conn.close();
    }
  }

  Future<MyResult<void>> saveProfile(
    int id,
    String? age,
    String? sex,
    String? weight,
    String? height,
    String? time1km,
    String? vo2,
  ) async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception("Не удалось подключиться к базе данных"));
    }
    bool sexy = sex == "Мужской" ? true : false;
    try {
      await conn.execute(
        'UPDATE users_profile SET age = \$2, sex = \$3, weight_kg = \$4, height_cm = \$5, time_per_1km_min = \$6, VO2max_mlkg_min = \$7 WHERE user_id = \$1',
        parameters: [id, age, sexy, weight, height, time1km, vo2],
      );
      return Ok(null);
    } catch (e) {
      return Error(Exception("Ошибка при попытке обновления данных"));
    } finally {
      await conn.close();
    }
  }

  Future<MyResult<List<RouteModel>>> getRoutes(int userId) async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    }
    try {
      final result = await conn.execute(
        'SELECT id, name, distance_km, total_ascent_m, created_at, points '
        'FROM routes WHERE user_id = \$1 ORDER BY created_at DESC',
        parameters: [userId],
      );

      final routes = result.map((row) {
        final pointsRaw = row[5];
        final List<dynamic> pointsJson;

        if (pointsRaw is String) {
          pointsJson = jsonDecode(pointsRaw) as List;
        } else {
          pointsJson = pointsRaw as List<dynamic>;
        }
        final points = pointsJson
            .map((p) => RoutePoint.fromJson(p as Map<String, dynamic>))
            .toList();

        return RouteModel(
          row[0] as int,
          points,
          row[3] != null ? (row[3] as num).toDouble() : 0,
          row[2] != null ? (row[2] as num).toDouble() : 0,
          row[4] as DateTime,
          row[1] as String?,
          false,
        );
      }).toList();
      return Ok(routes);
    } catch (e) {
      return Error(Exception('Failed to get routes: $e'));
    } finally {
      await conn.close();
    }
  }

  Future<MyResult<void>> updateRoute(
    int routeId,
    User user,
    double distance,
    double totalAscent,
    List<RoutePoint> routePoints,
  ) async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    }
    try {
      await conn.execute(
        'UPDATE routes SET distance_km = \$1, total_ascent_m = \$2, points = \$3 '
        'WHERE id = \$4 AND user_id = \$5',
        parameters: [
          distance,
          totalAscent,
          jsonEncode(routePoints),
          routeId,
          user.id,
        ],
      );
      return Ok(null);
    } catch (e) {
      return Error(Exception('Failed to update route: $e'));
    } finally {
      await conn.close();
    }
  }

  Future<MyResult<void>> changeRouteName(
    String newName,
    int userId,
    int routeId,
  ) async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    }
    try {
      await conn.execute(
        'UPDATE routes SET name = \$1 WHERE id = \$2 AND user_id = \$3',
        parameters: [newName, routeId, userId],
      );
      return Ok(null);
    } catch (e) {
      return Error(Exception('Failed to update route\'s name: $e'));
    } finally {
      await conn.close();
    }
  }

  Future<MyResult<void>> deleteRoute(int routeId, int userId) async {
    final conn = await _connect();
    if (conn == null) {
      return Error(Exception('Failed to connect to the database'));
    }
    try {
      await conn.execute('DELETE FROM routes WHERE id = \$1 AND user_id = \$2', parameters: [routeId, userId]);
      return Ok(null);
    } catch (e) {
      return Error(Exception('Failed to delete route $e'));
    }
    finally {
      await conn.close();
    }
  }
}
