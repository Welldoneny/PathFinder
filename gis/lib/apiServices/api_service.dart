import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_finder/model/route_point.dart';

class ApiService {
  static Future<double> getAltitude(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://api.open-elevation.com/api/v1/lookup?locations=$lat,$lng',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'][0]['elevation'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      debugPrint('Ошибка получения высоты: $e');
      return 0.0;
    }
  }

  static Future<Map<String, dynamic>?> getWeather(
    List<RoutePoint> points,
    DateTime date,
    String apiKey,
  ) async {
    try {
      // Среднее арифметическое координат
      final avgLat =
          points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
      final avgLng =
          points.map((p) => p.longitude).reduce((a, b) => a + b) /
          points.length;

      // Дата в UNIX формат
      final int unixDate = date.millisecondsSinceEpoch ~/ 1000;

      final uri = Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall/timemachine'
        '?lat=$avgLat&lon=$avgLng&dt=$unixDate&appid=$apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = data['data'][0];
        return {
          'temp':
              (weather['temp'] as num).toDouble() -
              273.15, // Кельвины в Цельсии
          'humidity': weather['humidity'] as int,
        };
      }

      debugPrint('Ошибка погоды: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Ошибка получения погоды: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> predict({
    required int? age,
    required bool? sex,
    required double? weight,
    required double? height,
    required double? timePer1kmMin,
    required double? vo2,
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
          'age': age,
          'sex': sex,
          'weight_kg': weight,
          'height_cm': height,
          'time_per_1km_min': timePer1kmMin,
          'VO2max_mlkg_min': vo2,
          'backpack_weight_kg': gearWeight,
          'avg_temp_C': temp,
          'humidity_pct': humidity,
          'distance_km': distanceKm,
          'total_ascent_m': totalAscent,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      debugPrint('Ошибка ML модели: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Ошибка запроса к ML модели: $e');
      return null;
    }
  }
}
