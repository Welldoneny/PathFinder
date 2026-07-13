import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/utils/epsg3857norepeat.dart';
import 'package:latlong2/latlong.dart';

class MyMap extends StatelessWidget {
  final MapController mapController;
  final bool isLocated;
  final bool isRouteMode;
  final LatLng? userLocation;
  final String currentUrl;
  final List<RoutePoint> routePoints;
  final void Function(LatLng latLng)? onMapTap;
  const MyMap({
    super.key,
    required this.mapController,
    required this.userLocation,
    this.isLocated = false,
    required this.currentUrl,
    required this.routePoints,
    this.onMapTap,
    required this.isRouteMode,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        crs: const Epsg3857NoRepeat(), // чтобы карта не повторялась при прокрутке
        initialCenter: LatLng(49.57, 82.37),
        initialZoom: 9.2,
        cameraConstraint: const CameraConstraint.containLatitude(), // ограничения чтобы камера не уходила далеко
        onTap: (tapPosition, latLng) {
          if (isRouteMode && onMapTap != null) {
            onMapTap!(latLng);
          }
        },
      ),
      children: [
        // картографическая подложка
        TileLayer(
          key: ValueKey(currentUrl),
          urlTemplate: currentUrl,
          userAgentPackageName: 'PathFinder',
        ),
        // маркер пользователя если прожата кнопка геопозиции и она известна
        if (isLocated && userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userLocation!,
                width: 40,
                height: 40,
                child: Icon(Icons.location_on, color: Colors.blue),
              ),
            ],
          ),
          // если есть точки маршрута
        if (routePoints.isNotEmpty) ...[
          // линии соединяющие точки маршрута
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints
                    .map((p) => LatLng(p.latitude, p.longitude))
                    .toList(),
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ],
          ),
          // маркер начала маршрута
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  routePoints.first.latitude,
                  routePoints.first.longitude,
                ),
                width: 32,
                height: 32,
                child: const Icon(Icons.flag_circle, color: Colors.green, size: 32),
              ),
            ],
          ),
        ],
        // маркер финиша
        if (routePoints.length >= 2)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  routePoints.last.latitude,
                  routePoints.last.longitude,
                ),
                width: 32,
                height: 32,
                child: const Icon(
                  Icons.flag,
                  color: Colors.green,
                  size: 32,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
