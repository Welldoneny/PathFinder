// Онлайн — обращается к REST API
import 'package:gis_app/data/models/route_model.dart';
import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/models/user_profile.dart';
import 'package:gis_app/data/repositories/i_data_source_repository.dart';
import 'package:gis_app/data/services/db_service.dart';
import 'package:gis_app/data/services/local_service.dart';
import 'package:gis_app/utils/result.dart';

///реализация онлайн системы обращается к серверу
class RemoteDataSource implements DataSource {
  RemoteDataSource({required ServerService dbService})
    : _serverService = dbService;

  final ServerService _serverService;

  @override
  /// добавляет новый маршрут в БД
  Future<MyResult<void>> addRoute(
    User user,
    double distance,
    double totalAscent,
    List<RoutePoint> routePoints,
  ) async {
    return await _serverService.addRoute(
      user,
      distance,
      totalAscent,
      routePoints,
    );
  }

  @override
  /// возвращает профиль пользователя с БД по его айди
  Future<MyResult<UserProfile>> getProfile(int userId) async {
    final result = await _serverService.getProfile(userId);
    return result;
  }

  @override
  /// сохраняет профиль пользователя в БД
  Future<MyResult<void>> saveProfile(
    int userId,
    UserProfile userProfile,
  ) async {
    String? age = userProfile.age;
    String? sex = userProfile.sex;
    String? weight = userProfile.weight;
    String? height = userProfile.height;
    String? time1km = userProfile.kross;
    String? vo2 = userProfile.vo2;
    return await _serverService.saveProfile(
      userId,
      age,
      sex,
      weight,
      height,
      time1km,
      vo2,
    );
  }

  @override
  /// забирает с БД все маршруты пользователя по айди
  Future<MyResult<List<RouteModel>>> getRoutes(int userId) async {
    final result = await _serverService.getRoutes(userId);
    return result;
  }
  
  @override
  /// обновляет данные определенного существуюшего в БД маршрута
  Future<MyResult<void>> updateRoute(int routeId, User user, double ta, double td, List<RoutePoint> rp) async {
    final result = await _serverService.updateRoute(routeId, user, td, ta, rp);
    return result;
  }

  /// Меняет название маршрута в БД
  Future<MyResult<void>> changeRouteName(String newName, int routeId, int userId) async {
    return _serverService.changeRouteName(newName, userId, routeId);
  }

  Future<MyResult<void>> deleteRoute(int routeId, int userId) async {
    return _serverService.deleteRoute(routeId, userId);
  }
}

// Оффлайн — обращается к SQLite
class LocalDataSource implements DataSource {
  final LocalService _localService;

  LocalDataSource({required LocalService localDB}) : _localService = localDB;
  @override
  /// (НЕ ИСПОЛЬЗОВАТЬ) добавляет новый маршрут в локальную БД 
  Future<MyResult<void>> addRoute(
    User user,
    double distance,
    double totalAscent,
    List<RoutePoint> points,
  ) async{
    return _localService.addRoute(user.id, distance, totalAscent, points);
    //return Ok(null);
  }

  /// скачивает маршрут локально
  Future<MyResult<void>> downloadRoute(User user, RouteModel route) async{
    return _localService.downloadRoute(user, route);
  }

  Future<MyResult<void>> changeRouteName(String newName, int routeId, int userId) async {
    return _localService.changeRouteName(newName, routeId, userId);
  }

  Future<MyResult<void>> deleteRoute(int routeId, int userId) async {
    return _localService.deleteRoute(routeId, userId);
  }

  @override
  /// возвращает профиль пользователя
  Future<MyResult<UserProfile>> getProfile(int userId) async {
    try {
      final result = await _localService.getProfile(userId);
      switch (result) {
        case Ok<Map<String, String?>>():
          UserProfile userProfile = UserProfile(
            result.value['age'],
            result.value['weight'],
            result.value['height'],
            result.value['sex'],
            result.value['kross'],
            result.value['vo2'],
          );
          return Ok(userProfile);
        case Error<Map<String, String?>>():
          return Error(result.error);
      }
    } catch (e) {
      return Error(Exception('$e'));
    }
  }

  @override
  /// сохраняет профиль пользователя
  Future<MyResult<void>> saveProfile(
    int userId,
    UserProfile userProfile,
  ) async {
    Map<String, String?> userprof = {
      "age": userProfile.age,
      "weight": userProfile.weight,
      "height": userProfile.height,
      "sex": userProfile.sex,
      "kross": userProfile.kross,
      "vo2": userProfile.vo2,
    };
    return await _localService.saveProfile(userId, userprof);
  }

  /// удаляет профиль пользователя
  Future<MyResult<void>> deleteProfile(int userId) async {
    return await _localService.deleteProfile(userId);
  }

  @override
  /// вытаскивает все маршруты из профиля пользователя
  Future<MyResult<List<RouteModel>>> getRoutes(int userId) async{
    final result = await _localService.getRoutes(userId);
    return result;
  }
  
  @override
  Future<MyResult<void>> updateRoute(int routeId, User user, double ta, double td, List<RoutePoint> rp) async{
    final result = await _localService.updateRoute(routeId, user.id, ta, td, rp);
    return result;
  }
}
