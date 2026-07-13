import 'package:gis_app/data/models/user_profile.dart';
import 'package:gis_app/data/repositories/data_source_repository.dart';
import 'package:gis_app/data/services/shared_preferences_service.dart';
import 'package:gis_app/utils/result.dart';

class ProfileRepository {
  UserProfile? _cachedProfile; // ← кэш просто поле в репозитории
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final SharedPreferencesService _sharedPreferencesService;
  //bool _cacheFromRemote = false;
  Future<bool> get isLocal async => await _sharedPreferencesService.getProfileLocal();

  ProfileRepository(
    this._remoteDataSource,
    this._localDataSource,
    this._sharedPreferencesService,
  );

  Future<MyResult<UserProfile>> getProfile(int userId) async {
    // если кэш есть — сразу возвращаем
    if (_cachedProfile != null) return Ok(_cachedProfile!);

    // пробуем сервер
    final remoteResult = await _remoteDataSource.getProfile(userId);
    switch (remoteResult) {
      case Ok<UserProfile>():
        _cachedProfile = remoteResult.value;
        //_cacheFromRemote = true; // сохраняем в кэш
        return Ok(_cachedProfile!);
      case Error<UserProfile>():
        // сервер недоступен — пробуем локально
        final localResult = await _localDataSource.getProfile(userId);
        switch (localResult) {
          case Ok<UserProfile>():
            _cachedProfile = localResult.value;
           // _cacheFromRemote = false;
            await _sharedPreferencesService.setProfileLocal(true);
            return Ok(_cachedProfile!);
          case Error<UserProfile>():
            return Error(localResult.error);
        }
    }
  }

  // при сохранении — обновляем кэш
  Future<MyResult<void>> saveProfile(int userId, UserProfile profile) async {
    final result = await _remoteDataSource.saveProfile(userId, profile);
    if (result is Ok) {
      _cachedProfile = profile; // обновляем кэш
    }
    return result;
  }

  Future<MyResult<void>> saveProfileLocaly(
    int userId,
    UserProfile profile,
  ) async {
    final result = await _localDataSource.saveProfile(userId, profile);
    if (result is Ok) {
      _cachedProfile = profile;
      //_cacheFromRemote = false;
      await _sharedPreferencesService.setProfileLocal(true);
    }
    return result;
  }

  Future<MyResult<void>> deleteProfileLocaly(int userId) async {
    final result = await _localDataSource.deleteProfile(userId);
    if (result is Ok /*&& _cacheFromRemote */) {
      _cachedProfile = null; // сбрасываем только если кэш был из локального
    }
   // _cacheFromRemote  = true;
    if (result is Ok) await _sharedPreferencesService.setProfileLocal(false);
    return result;
  }

  // Future<MyResult<UserProfile>> getProfileLocaly(int userId) async {
  //   final result = await _localDataSource.getProfile(userId);
  //   if (result is Ok && !_cacheFromRemote) {
  //     _cachedProfile = (result as Ok<UserProfile>)
  //         .value; // сбрасываем только если кэш был из локального
  //     await _sharedPreferencesService.setProfileLocal(true);
  //   }
  //   return result;
  // }

  // сброс кэша если нужно
  void invalidateCache() {
    _cachedProfile = null;
  }
}
