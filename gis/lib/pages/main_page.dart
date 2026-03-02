import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_finder/apiServices/api_service.dart';
import 'package:path_finder/db/db_service.dart';
import 'package:path_finder/map/geolocator.dart';
import 'package:path_finder/map/map_widget.dart';
import 'package:path_finder/model/route_point.dart';
import 'package:path_finder/styles.dart/button_style.dart';
import 'package:path_finder/widgets/burger_widget.dart';
import 'package:path_finder/features/drawer_widget.dart';
import 'package:path_finder/features/layers_button_widget.dart';
import 'package:path_finder/widgets/geoposition_button_widget.dart';

class MainPage extends StatefulWidget {
  final String login;
  final int id;
  const MainPage({super.key, required this.id, required this.login});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final MapController _mapController;
  bool _isRouteMode = false;
  LatLng? _userLocation;
  bool _isLocated = false;
  double _distanceKm = 0.0;
  double _totalAscent = 0.0;
  late final List<RoutePoint> _routePoints = [];
  String _currentUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _switchToOsm() {
    setState(() {
      _currentUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    });
  }

  void _switchToSatellite() {
    setState(() {
      _currentUrl =
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    });
  }

  void _switchToThunderForestOutDoors() {
    setState(() {
      _currentUrl =
          'https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=a7d5d95c2e774682b6de7364ae3ac1f3';
    });
  }

  void _switchToThunderForestLandScape() {
    setState(() {
      _currentUrl =
          'https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png?apikey=a7d5d95c2e774682b6de7364ae3ac1f3';
    });
  }

  void _switchToThunderForestCycle() {
    setState(() {
      _currentUrl =
          'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=a7d5d95c2e774682b6de7364ae3ac1f3';
    });
  }

  void _switchToThunderForestAtlas() {
    setState(() {
      _currentUrl =
          'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=a7d5d95c2e774682b6de7364ae3ac1f3';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(id: widget.id, login: widget.login),
      body: Stack(
        children: [
          /// КАРТА
          MyMap(
            mapController: _mapController,
            currentUrl: _currentUrl,
            isRouteMode: _isRouteMode,
            onMapTap: _addRoutePoint,
            routePoints: _routePoints,
            userLocation: _userLocation,
            isLocated: _isLocated,
          ),

          /// БУРГЕР СЛЕВА
          buildDrawerButton(),

          /// КНОПКА СМЕНЫ КАРТЫ СПРАВА
          Positioned(
            top: 30,
            right: 16,
            child: Column(
              children: [
                MapTypeButton(onSelected: (value) => setMap(value)),
                SizedBox(height: 10),
                LocationButton(
                  onPressed: _moveToCurrentLocation,
                  style: buttonStyle,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isRouteMode && _routePoints.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  FloatingActionButton(
                    mini: true,
                    onPressed: _saveRoute,
                    tooltip: "Сохранить маршрут",
                    child: const Icon(Icons.save),
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    mini: true,
                    onPressed: _removeLastRoutePoint,
                    tooltip: "Удалить последнюю точку",
                    child: const Icon(Icons.undo),
                  ),
                ],
              ),
            ),

          FloatingActionButton(
            onPressed: _toggleRouteMode,
            child: Icon(_isRouteMode ? Icons.close : Icons.add),
          ),
        ],
      ),
    );
  }

  void setMap(String value) {
    switch (value) {
      case 'osm':
        _switchToOsm();
      case 'sat':
        _switchToSatellite();
      case 'out':
        _switchToThunderForestOutDoors();
      case 'ocm':
        _switchToThunderForestCycle();
      case 'atl':
        _switchToThunderForestAtlas();
      case 'lds':
        _switchToThunderForestLandScape();
      default:
        _switchToOsm();
    }
  }

  void _addRoutePoint(LatLng latLng) async {
    double altitude = await ApiService.getAltitude(latLng.latitude, latLng.longitude);

    if (_routePoints.isNotEmpty) {
      final last = _routePoints.last;
      final segment = Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        latLng.latitude,
        latLng.longitude,
      );
      final altiDiff  = altitude - last.altitude;
      if(altiDiff > 0) _totalAscent += altiDiff;
      _distanceKm += segment / 1000;
    }

    setState(() {
      _routePoints.add(
        RoutePoint(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          altitude: altitude,
        ),
      );
    });
  }

void _removeLastRoutePoint() {
  if (_routePoints.isEmpty) return;

  if (_routePoints.length >= 2) {
    final last = _routePoints.last;
    final prev = _routePoints[_routePoints.length - 2];
    final segment = Geolocator.distanceBetween(
      prev.latitude, prev.longitude,
      last.latitude, last.longitude,
    );
    final diff = last.altitude - prev.altitude;
    _totalAscent -= diff > 0 ? diff : 0;
    _distanceKm -= segment / 1000;
    if (_distanceKm < 0) _distanceKm = 0;
  }

  setState(() {
    _routePoints.removeLast();
  });
}

  void _toggleRouteMode() {
    setState(() {
      _isRouteMode = !_isRouteMode;

      if (!_isRouteMode) {
        _routePoints.clear();
        _distanceKm = 0.0;
        _totalAscent = 0.0;
      }
    });
  }

  Future<void> _moveToCurrentLocation() async {
    if (!_isLocated) {
      try {
        final position = await determinePosition();

        final latLng = LatLng(position.latitude, position.longitude);

        setState(() {
          _isLocated = true;
          _userLocation = latLng;
        });

        _mapController.move(latLng, 15);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      setState(() {
        _isLocated = !_isLocated;
      });
    }
  }

  Future<void> _saveRoute() async {
    if (_routePoints.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Маршрут пустой')));
      return;
    }

    final points = _routePoints
        .map((p) => {'lat': p.latitude, 'lng': p.longitude, 'alt': p.altitude})
        .toList();

    final success = await DbService.saveRoute(
      userId: widget.id,
      distanceKm: _distanceKm,
      totalAscent: _totalAscent,
      points: points,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Маршрут сохранён' : 'Ошибка сохранения'),
      ),
    );
  }
}
