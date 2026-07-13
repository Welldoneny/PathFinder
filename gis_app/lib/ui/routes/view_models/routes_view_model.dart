import 'package:flutter/material.dart';
import 'package:gis_app/data/models/predict_model.dart';
import 'package:gis_app/data/models/route_model.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/repositories/route_repository.dart';
import 'package:gis_app/utils/result.dart';

class RoutesViewModel extends ChangeNotifier {
  final RouteRepository _routeRepository;
  final User user;

  List<RouteModel> routes = [];
  bool isLoading = false;
  double food = 0;
  double water = 0;
  double time = 0;
  String? errorMessage;
  String? succssesMessage;

  RoutesViewModel(this._routeRepository, this.user);

  Future<void> loadRoutes() async {
    isLoading = true;
    notifyListeners();

    final result = await _routeRepository.getRoutes(user.id);
    switch (result) {
      case Ok<List<RouteModel>>():
        routes = result.value;
        errorMessage = null;
      case Error<List<RouteModel>>():
        errorMessage = result.error.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _routeRepository.invalidateCache();
    await loadRoutes();
  }

  Future<void> predictRoute(
    DateTime? selectedDate,
    double? weight,
    int userId,
    RouteModel route,
  ) async {
    final result = await _routeRepository.predictRoute(
      selectedDate,
      weight,
      userId,
      route,
    );
    switch (result) {
      case Ok<PredictResult>():
        food = result.value.food;
        water = result.value.water;
        time = result.value.time;
      case Error<PredictResult>():
        errorMessage = result.error.toString();
    }
    notifyListeners();
  }

  Future<void> downloadRoute(RouteModel route) async {
    final result = await _routeRepository.downloadRoute(user, route);
    switch (result) {
      case Ok<void>():
        errorMessage = null;
        route.isLocal = true;
      case Error<void>():
        errorMessage = result.error.toString();
    }

    notifyListeners();
  }

  Future<void> changeRouteName(
    String newName,
    int routeId,
    int userId,
    bool isLocal,
  ) async {
    final result = await _routeRepository.changeRouteName(
      newName,
      routeId,
      userId,
      isLocal,
    );
    switch (result) {
      case Ok<void>():
        errorMessage = null;
      case Error<void>():
        errorMessage = result.error.toString();
    }
    notifyListeners();
  }

  Future<void> deleteRoute(int routeId, int userId, bool isLocal) async {
    final result = await _routeRepository.deleteRoute(routeId, userId, isLocal);
    switch (result) {
      case Ok<void>():
        errorMessage = null;
      case Error<void>():
        errorMessage = result.error.toString();
    }
    notifyListeners();
  }

  Future<void> export(RouteModel route, String format) async {
    final result = await _routeRepository.exportRoute(
      route,
      format
    );
    switch (result) {
      case Ok<void>():
        succssesMessage = 'Маршрут сохранён';
        notifyListeners();
      case Error<void>():
        errorMessage = result.error.toString();
        notifyListeners();
    }
  }

  Future<void> getRoutes() async {}
}
