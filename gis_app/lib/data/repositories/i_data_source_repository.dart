import 'package:gis_app/data/models/route_model.dart';
import 'package:gis_app/data/models/route_point.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/models/user_profile.dart';
import 'package:gis_app/utils/result.dart';
/// абстрактный класс для объединения локальной и удаленной системы
abstract class DataSource {
  Future<MyResult<void>> addRoute(User user, double distance, double totalAscent, List<RoutePoint> points);
  Future<MyResult<UserProfile>> getProfile(int userId);
  Future<MyResult<void>> saveProfile(int usedrId, UserProfile userProfile);
  Future<MyResult<List<RouteModel>>> getRoutes(int userId);
  Future<MyResult<void>> updateRoute(int routeId, User user, double ta, double td, List<RoutePoint> rp);
}