import 'package:geolocator/geolocator.dart';
import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/data/services/geolocator_service.dart';
import 'package:gis_app/utils/result.dart';

class GeolocatorRepository {
  final GeolocatorService _geolocatorService;

  GeolocatorRepository(this._geolocatorService);
  // запрашивает у сервиса текующую позицию
  Future<MyResult<Position>> getCurrentPosition() async {
    try {
      final position = await _geolocatorService.getCurrentPosition();
      return Ok(position);
    } on Exception catch (e) {
      return Error(e);
    }
  }
  // запрашивает у сервиса расстояние между двумя точками
  double getDistanceBetween(RoutePoint last, RoutePoint current) {
      final distance = _geolocatorService.getDistanceBetween(last, current);
      return distance;
  }
}