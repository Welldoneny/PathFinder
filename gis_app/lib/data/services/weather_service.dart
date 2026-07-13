import 'dart:convert';

import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/data/models/weather_model.dart';
import 'package:gis_app/utils/result.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  Future<MyResult<WeatherModel>> getWeather(
    List<RoutePoint> points,
    DateTime date,
  ) async {
    String apiKey = dotenv.env['WEATHER_KEY'] ?? '';
    try {
      final avgLat =
          points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
      final avgLng =
          points.map((p) => p.longitude).reduce((a, b) => a + b) /
          points.length;
      final int unixDate = date.millisecondsSinceEpoch ~/ 1000;
      final uri = Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall/timemachine'
        '?lat=$avgLat&lon=$avgLng&dt=$unixDate&appid=$apiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = data['data'][0];
        WeatherModel weatherModel = WeatherModel(
          temp: weather['temp'] - 273.15,
          humidity: weather['humidity'],
        );
        return Ok(weatherModel);
      }
      return Error(Exception(response.statusCode));
    } catch (e) {
      return Error(Exception(e));
    }
  }
}
