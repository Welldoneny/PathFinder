import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/services/shared_preferences_service.dart';
import 'package:gis_app/utils/result.dart';

class AuthRepository {
  final SharedPreferencesService _sharedPreferenceService;

  AuthRepository({required SharedPreferencesService sharedPreferenceService})
    : _sharedPreferenceService = sharedPreferenceService;

  Future<MyResult<void>> saveUser(User user) async {
    try {
      await _sharedPreferenceService.saveUser(user);
      return Ok(null);
    } catch (e) {
      return Error(Exception("Не удалось сохранить данные для входа")); 
    }
  }
}
