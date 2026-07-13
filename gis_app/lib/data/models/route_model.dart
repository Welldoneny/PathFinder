import 'package:gis_app/data/models/route_point.dart';

class RouteModel {
  int routeId;
  double totaldistance = 0;
  double totalAscent = 0;
  String? name;
  DateTime createdAt;
  bool isLocal;
  List<RoutePoint> routePoints = [];

  RouteModel(
    this.routeId,
    this.routePoints,
    this.totalAscent,
    this.totaldistance,
    this.createdAt,
    this.name,
    this.isLocal,
  );
}
