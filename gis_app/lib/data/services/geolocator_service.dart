import 'package:geolocator/geolocator.dart';
import 'package:gis_app/data/models/route_point.dart';

class GeolocatorService {
  /// Получает координаты пользователя
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('GPS выключен');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Разрешение отклонено');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Разрешение отклонено навсегда');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }

  /// Возвращает расстояние в километрах между двумя точками
  double getDistanceBetween(RoutePoint last, RoutePoint current) {
    double segment = Geolocator.distanceBetween(
      last.latitude,
      last.longitude,
      current.latitude,
      current.longitude,
    );
    return segment / 1000;
  }
}
