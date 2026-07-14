import 'package:gis_app/data/models/predict_model.dart';
import 'package:gis_app/data/models/route_import.dart';
import 'package:gis_app/data/models/route_model.dart';
import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/models/user_profile.dart';
import 'package:gis_app/data/models/weather_model.dart';
import 'package:gis_app/data/repositories/data_source_repository.dart';
import 'package:gis_app/data/services/db_service.dart';
import 'package:gis_app/data/services/elevation_service.dart';
import 'package:gis_app/data/services/export_service.dart';
import 'package:gis_app/data/services/file_manager_service.dart';
import 'package:gis_app/data/services/geolocator_service.dart';
import 'package:gis_app/data/services/weather_service.dart';
import 'package:gis_app/utils/result.dart';

class RouteRepository {
  final ElevationService _elevationService;
  final RemoteDataSource _remoteDataSource;
  // ignore: unused_field
  final LocalDataSource _localDataSource;
  final FileManagerService _fileManagerService;
  final GeolocatorService _geolocatorService;
  final WeatherService _weatherService;
  final ServerService _serverService;

  RouteRepository(
    this._elevationService,
    this._remoteDataSource,
    this._localDataSource,
    this._fileManagerService,
    this._geolocatorService,
    this._weatherService,
    this._serverService,
  );

  List<RouteModel>? cachedRoutes;

  /// запрашивает у сервиса высоты для всего списка
  Future<MyResult<List<RoutePoint>>> getAltitude(
    List<RoutePoint> routePoints,
  ) async {
    try {
      final result = await _elevationService.getAltitudes(routePoints);
      switch (result) {
        case Ok<List<double>>():
          for (int i = 0; i < routePoints.length; i++) {
            routePoints[i].altitude = result.value[i];
          }
          return Ok(routePoints);
        case Error<List<double>>():
          return Error(result.error);
      }
    } on Exception catch (e) {
      return Error(e);
    }
  }

  /// считает абсолютный подъем для маршрута
  double countAscent(List<RoutePoint> routePoints) {
    double totalAscent = 0;
    for (int i = 0; i < routePoints.length - 1; i++) {
      double altiDiff = routePoints[i + 1].altitude! - routePoints[i].altitude!;
      if (altiDiff > 0) totalAscent += altiDiff;
    }
    return totalAscent;
  }

  // добавляет маршрут в БД
  Future<MyResult<void>> addRoute(
    User user,
    double distance,
    List<RoutePoint> routePoints,
  ) async {
    final totalAscent = countAscent(routePoints);
    final result = await _remoteDataSource.addRoute(
      user,
      distance,
      totalAscent,
      routePoints,
    );
    switch (result) {
      case Ok<void>():
        invalidateCache();
        return Ok(null);
      case Error<void>():
        final localResult = await _localDataSource.addRoute(
          user,
          distance,
          totalAscent,
          routePoints,
        );
        switch (localResult) {
          case Ok<void>():
            invalidateCache();
            return Ok(null);
          case Error<void>():
            return Error(localResult.error);
        }
    }
  }

  Future<MyResult<void>> changeRouteName(
    String newName,
    int routeId,
    int userId,
    bool isLocal,
  ) async {
    final result = isLocal
        ? await _localDataSource.changeRouteName(newName, routeId, userId)
        : await _remoteDataSource.changeRouteName(newName, routeId, userId);
    switch (result) {
      case Ok<void>():
        for (var route in cachedRoutes!) {
          if (route.routeId == routeId && route.isLocal == isLocal) {
            route.name = newName;
          }
        }
        return result;
      case Error<void>():
        return result;
    }
  }

  Future<MyResult<void>> deleteRoute(
    int routeId,
    int userId,
    bool isLocal,
  ) async {
    final result = isLocal
        ? await _localDataSource.deleteRoute(routeId, userId)
        : await _remoteDataSource.deleteRoute(routeId, userId);
    switch (result) {
      case Ok<void>():
        for (int i = 0; i < cachedRoutes!.length; i++) {
          var route = cachedRoutes![i];
          if (route.routeId == routeId && route.isLocal == isLocal) {
            cachedRoutes!.removeAt(i);
          }
        }
        return result;
      case Error<void>():
        return result;
    }
  }

  Future<MyResult<void>> exportRoute(RouteModel route, String format) async {
    return ExportService.exportRoute(
      route.routePoints,
      route.name ?? "Без названия",
      format,
    );
  }

  Future<MyResult<void>> downloadRoute(User user, RouteModel route) async {
    final result = await _localDataSource.downloadRoute(user, route);
    return result;
  }

  /// Достает маршрут из файловой системы
  Future<MyResult<RouteImport>> importRoute() async {
    try {
      final points = await _fileManagerService.pickAndParseFile();
      if (points == null) return Error(Exception('Файл не выбран'));
      if (points.isEmpty) {
        return Error(Exception('Не удалось загрузить маршрут'));
      }
      double distance = 0;
      for (int i = 1; i < points.length; i++) {
        final segment = _geolocatorService.getDistanceBetween(
          points[i - 1],
          points[i],
        );
        distance += segment;
      }
      RouteImport routeImport = RouteImport(
        points: points,
        totalDistance: distance,
      );
      return Ok(routeImport);
    } on Exception catch (e) {
      return Error(e);
    }
  }

  Future<MyResult<List<RouteModel>>> getRoutes(int userId) async {
    if (cachedRoutes != null) return Ok(cachedRoutes!);

    // получаем оба списка
    final remoteResult = await _remoteDataSource.getRoutes(userId);
    final localResult = await _localDataSource.getRoutes(userId);

    final remoteRoutes = remoteResult is Ok<List<RouteModel>>
        ? (remoteResult).value
        : <RouteModel>[];
    final localRoutes = localResult is Ok<List<RouteModel>>
        ? (localResult).value
        : <RouteModel>[];

    // если оба пустые и оба Error — реальная ошибка
    if (remoteResult is Error && localResult is Error) {
      return Error(
        Exception('Не удалось загрузить маршруты ни с сервера, ни локально'),
      );
    }

    // объединяем — для совпадающих ID берём локальную версию
    // (она помечена isLocal: true и значит доступна офлайн)
    // final localIds = localRoutes.map((r) => r.routeId).toSet();
    // final merged = [
    //   ...localRoutes, // сначала локальные (isLocal: true)
    //   ...remoteRoutes.where(
    //     (r) => !localIds.contains(r.routeId),
    //   ), // остальные с сервера
    // ];
    final merged = remoteRoutes + localRoutes;
    cachedRoutes = merged;
    return Ok(merged);
  }

  void invalidateCache() {
    cachedRoutes = null;
  }

  Future<MyResult<void>> updateRoute(
    int routeId,
    User user,
    double td,
    List<RoutePoint> rp,
    bool isLocal,
  ) async {
    final totalAscent = countAscent(rp);
    final result = isLocal
        ? await _localDataSource.updateRoute(routeId, user, totalAscent, td, rp)
        : await _remoteDataSource.updateRoute(routeId, user, totalAscent, td, rp);
    return result;
  }

  Future<MyResult<PredictResult>> predictRoute(
    DateTime? selectedDate,
    double? weight,
    int userId,
    RouteModel route,
  ) async {
    final weather = await _weatherService.getWeather(
      route.routePoints,
      selectedDate ?? DateTime.now(),
    );
    switch (weather) {
      case Ok<WeatherModel>():
        final profile = await _remoteDataSource.getProfile(userId);
        switch (profile) {
          case Ok<UserProfile>():
            final result = await _serverService.predict(
              profile: profile.value,
              gearWeight: weight,
              temp: weather.value.temp,
              humidity: weather.value.humidity,
              distanceKm: route.totaldistance,
              totalAscent: route.totalAscent,
            );
            switch (result) {
              case Ok<PredictResult>():
                return result;
              case Error<PredictResult>():
                return Error(Exception(result.error));
            }
          case Error<UserProfile>():
            return Error(Exception(profile.error));
        }
      case Error<WeatherModel>():
        return Error(Exception(weather.error));
    }
  }
}
