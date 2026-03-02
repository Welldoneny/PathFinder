import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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

  static Future<Map<String, dynamic>?> getWeather(double lat, double lng) async {
    // сюда позже добавишь погоду
    return null;
  }
}