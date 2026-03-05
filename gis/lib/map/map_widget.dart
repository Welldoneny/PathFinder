import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_finder/map/espg3857norepeat.dart';
import 'package:path_finder/model/route_point.dart';

class MyMap extends StatelessWidget {
  final MapController mapController;
  final String currentUrl;
  final bool isRouteMode;
  final void Function(LatLng latLng)? onMapTap;
  final List<RoutePoint> routePoints;
  final LatLng? userLocation;
  final bool isLocated;

  const MyMap({
    required this.mapController,
    required this.currentUrl,
    required this.isRouteMode,
    required this.onMapTap,
    required this.routePoints,
    required this.isLocated,
    this.userLocation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        crs: const Epsg3857NoRepeat(),
        initialCenter: const LatLng(51.509364, -0.128928),
        initialZoom: 9.2,
        cameraConstraint: const CameraConstraint.containLatitude(),
        onTap: (tapPosition, latLng) {
          if (isRouteMode && onMapTap != null) {
            onMapTap!(latLng);
          }
        },
      ),
      children: [
        TileLayer(
          key: ValueKey(currentUrl),
          urlTemplate: currentUrl,
          // tileProvider: NetworkTileProvider(
          //   cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
          //     maxCacheSize: 1_000_000_000, // 1 GB is the default
          //   ),
          // ),
          userAgentPackageName: 'PathFinder',
        ),
        if (userLocation != null && isLocated == true)
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
                  Icons.flag_circle,
                  color: Colors.green,
                  size: 32,
                ),
              ),
            ],
          ),
        if (routePoints.isNotEmpty) ...[
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
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  routePoints.first.latitude,
                  routePoints.first.longitude,
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
      ],
    );
  }
}
