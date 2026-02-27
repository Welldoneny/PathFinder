import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  const MainPage({super.key, required this.login});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final MapController _mapController;
  bool _isRouteMode = false;
  LatLng? _userLocation;
  bool _isLocated = false;
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
      drawer: MyDrawer(login: widget.login,),
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
                    onPressed: () {},
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
    double altitude = 1;

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

    setState(() {
      _routePoints.removeLast();
    });
  }

  void _toggleRouteMode() {
    setState(() {
      _isRouteMode = !_isRouteMode;

      if (!_isRouteMode) {
        _routePoints.clear();
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
    }
    else {
        setState(() {
          _isLocated = !_isLocated;
        });
    }
  }
}
