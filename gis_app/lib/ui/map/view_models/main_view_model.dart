import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gis_app/data/models/route_import.dart';
import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/repositories/geolocator_repository.dart';
import 'package:gis_app/data/repositories/route_repository.dart';
import 'package:gis_app/utils/result.dart';
import 'package:latlong2/latlong.dart';

class MainViewModel extends ChangeNotifier {
  final GeolocatorRepository _geolocatorRepository;
  final RouteRepository _routeRepository;
  MainViewModel({
    required GeolocatorRepository geolocatorRepository,
    required RouteRepository routeRepository,
    required this.user,
  }) : _routeRepository = routeRepository,
       _geolocatorRepository = geolocatorRepository;
  // прожата ли кнопка показать геолокацию
  bool isLocated = false;
  // включен ли режим рисования маршрута
  bool isRouteMode = false;
  // включен ли режим редактирования существующего маршрута
  bool isEditingMode = false;
  // включается для отображения индикатора во время длинных процессов
  bool isLoading = false;
  bool isMoveNeeded = false;
  late bool isLocal;
  // список точек маршрута
  List<RoutePoint> routePoints = [];
  // данные пользователя
  final User user;
  // длина пути
  double totalDistance = 0;
  double totalAscent = 0;
  int routeId = -1;
  // тип карты по умолчанию
  String currentMapType = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  // координаты пользователя
  LatLng? userLocation;
  // сообщение ошибки если не получился какой либо из репозиториев
  String? errorMessage;
  String? succssesMessage;

  void setRoute(
    int ri,
    List<RoutePoint> rp,
    double td,
    double ta,
    bool isLocal,
  ) {
    routeId = ri;
    routePoints = rp;
    totalDistance = td;
    totalAscent = ta;
    this.isLocal = isLocal;
    isEditingMode = true;
    isRouteMode = true;
    isMoveNeeded = true;
    notifyListeners();
  }

  /// Получает текущую геолокацию пользователя и обновляет состояние.
  Future<void> updateLocation() async {
    final result = await _geolocatorRepository.getCurrentPosition();
    switch (result) {
      case Ok<Position>():
        userLocation = LatLng(result.value.latitude, result.value.longitude);
        isLocated = true;
        errorMessage = null;
        notifyListeners();
      case Error<Position>():
        errorMessage = result.error.toString();
        notifyListeners();
    }
  }

  /// Отключает отображение текущей геолокации на карте.
  void disableLocation() {
    isLocated = false;
    notifyListeners();
  }

  /// Изменяет тип карты и обновляет состояние.
  void changeMapType(String value) {
    switch (value) {
      case 'osm':
        currentMapType = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case 'sat':
        currentMapType =
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case 'lds':
        currentMapType =
            'https://api.thunderforest.com/landscape/{z}/{x}/{y}.png?apikey=a7d5d95c2e774682b6de7364ae3ac1f3';
      case 'out':
        currentMapType =
            'https://api.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=a7d5d95c2e774682b6de7364ae3ac1f3';
      case 'ocm':
        currentMapType =
            'https://api.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=a7d5d95c2e774682b6de7364ae3ac1f3';
      default:
        errorMessage = "Выбранная карта недоступна";
    }
    notifyListeners();
  }

  /// Включает режим прокладывания маршрута
  void startRouteMode() {
    isRouteMode = true;
    notifyListeners();
  }

  /// Отключает режим прокладывания маршрута
  void stopRouteMode() {
    isRouteMode = false;
    routePoints.clear();
    totalDistance = 0;
    isEditingMode = false;
    isLocated = false;
    isMoveNeeded = false;
    notifyListeners();
  }

  /// Добавляет точку маршрута при нажатии на карту
  void addPointToRoute(LatLng coords) {
    RoutePoint current = RoutePoint(
      latitude: coords.latitude,
      longitude: coords.longitude,
      altitude: 0,
    );
    if (routePoints.isNotEmpty) {
      final dist = _geolocatorRepository.getDistanceBetween(
        routePoints.last,
        current,
      );

      totalDistance += dist;
    }
    routePoints.add(current);
    notifyListeners();
  }

  /// удаляет точку маршрута
  void deleteLastPoint() {
    if (routePoints.isEmpty) {
      return;
    }
    if (routePoints.length >= 2) {
      final last = routePoints.last;
      final prev = routePoints[routePoints.length - 2];
      final segment = _geolocatorRepository.getDistanceBetween(prev, last);

      totalDistance -= segment;
      if (totalDistance < 0) totalDistance = 0;
    }
    routePoints.removeLast();
    notifyListeners();
  }

  /// Добавляет новый маршрут
  Future<void> addRoute() async {
    isLoading = true;
    notifyListeners();

    List<RoutePoint> pointsToSave = routePoints;
    String? successMessageOverride;

    // 1. Пытаемся получить высоты
    final altitudeResult = await _routeRepository.getAltitude(routePoints);

    switch (altitudeResult) {
      case Ok<List<RoutePoint>>():
        pointsToSave = altitudeResult.value; // используем точки с высотами
        break;

      case Error<List<RoutePoint>>():
        errorMessage = altitudeResult.error.toString();
        successMessageOverride =
            "Маршрут сохранен без высот, обновите маршрут позже";
        // pointsToSave остаётся оригинальным
        break;
    }

    // 2. Сохраняем маршрут (один раз!)
    final saveResult = await _routeRepository.addRoute(
      user,
      totalDistance,
      pointsToSave,
    );

    switch (saveResult) {
      case Ok<void>():
        succssesMessage = successMessageOverride ?? "Маршрут сохранен";
        isEditingMode = true;
        // если были ошибки по высотам — они уже остались в errorMessage
        break;

      case Error<void>():
        errorMessage = saveResult.error.toString();
        break;
    }

    isLoading = false;
    notifyListeners();
  }

  /// обновляет существующий маршрут
  Future<void> saveChangesRoute() async {
    isLoading = true;
    notifyListeners();

    List<RoutePoint> pointsToSave = routePoints;
    String? successMessageOverride;

    final altitudeResult = await _routeRepository.getAltitude(routePoints);
    switch (altitudeResult) {
      case Ok<List<RoutePoint>>():
        pointsToSave = altitudeResult.value;
        break;
      case Error<List<RoutePoint>>():
        successMessageOverride = "Маршрут обновлен без высот";
        break;
    }

    final result = await _routeRepository.updateRoute(
      routeId,
      user,
      totalDistance,
      pointsToSave,
      isLocal,
    );

    switch (result) {
      case Ok<void>():
        succssesMessage = successMessageOverride ?? "Маршрут обновлен";
      case Error<void>():
        errorMessage = result.error.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  /// импортирует маршрут в формате GPX или KML из файловой системы
  Future<void> importRoute() async {
    final result = await _routeRepository.importRoute();
    switch (result) {
      case Ok<RouteImport>():
        routePoints = result.value.points;
        totalDistance = result.value.totalDistance;
        isRouteMode = true; // сразу включаем режим маршрута
        errorMessage = null;
        isMoveNeeded = true;
        notifyListeners();
      case Error<RouteImport>():
        errorMessage = result.error.toString();
        notifyListeners();
    }
  }

  /// возвращает начало маршрута
  LatLng? get routeStart => routePoints.isNotEmpty
      ? LatLng(routePoints.first.latitude, routePoints.first.longitude)
      : null;

  void clearMoveNeededFlag() {
    isMoveNeeded = false;
  }
}
