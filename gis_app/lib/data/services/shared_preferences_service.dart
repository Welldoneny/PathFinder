// data/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gis_app/data/models/user.dart';

class SharedPreferencesService {
  static const _keyUserId = 'user_id';
  static const _keyUserLogin = 'user_login';

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, user.id);
    await prefs.setString(_keyUserLogin, user.login ?? '');
  }

  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyUserId);
    final login = prefs.getString(_keyUserLogin);
    if (id == null) return null;
    return User(id: id, login: login);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserLogin);
  }

  static const _keyProfileLocal = 'profile_local';

  Future<void> setProfileLocal(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProfileLocal, value);
  }

  Future<bool> getProfileLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyProfileLocal) ?? false;
  }
}
