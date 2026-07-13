import 'package:gis_app/data/models/route_point.dart';

class RouteImport {
  final List<RoutePoint> points;
  final double totalDistance;

  RouteImport({required this.points, required this.totalDistance});
}