import 'dart:convert';

import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/utils/result.dart';
import 'package:http/http.dart' as http;
/// сервис по работе с Elevation API
class ElevationService {
  /// получить высоту для одной точки
  Future<MyResult<double>> getAltitude(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://api.open-elevation.com/api/v1/lookup?locations=$lat,$lng',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Ok((data['results'][0]['elevation'] as num).toDouble());
      }
      return Error(Exception("Статус код не равен 200"));
    } catch (e) {
      return Error(Exception("Ошибка получения высоты"));
    }
  }
  /// получить высоту для списка точек
  Future<MyResult<List<double>>> getAltitudes(List<RoutePoint> points) async {
  try {
    final uri = Uri.parse('https://api.open-elevation.com/api/v1/lookup');
    
    final body = jsonEncode({
      'locations': points.map((p) => {
        'latitude': p.latitude,
        'longitude': p.longitude,
      }).toList(),
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final altitudes = (data['results'] as List)
          .map((r) => (r['elevation'] as num).toDouble())
          .toList();
      return Ok(altitudes);
    }
    return Error(Exception('Статус код не равен 200'));
  } catch (e) {
    return Error(Exception('Ошибка получения высоты: $e'));
  }
}
}