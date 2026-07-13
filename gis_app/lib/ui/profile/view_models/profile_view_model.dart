import 'package:flutter/foundation.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/models/user_profile.dart';
import 'package:gis_app/data/repositories/profile_repository.dart';
import 'package:gis_app/utils/result.dart';

class ProfileViewModel extends ChangeNotifier {
  final User user;

  String? age;
  String? weight;
  String? height;
  String? sex;
  String? kross;
  String? vo2;
  final ProfileRepository profileRepository;
  bool isLoadedLocaly = false;
  bool isLoading = true;
  String? errorMessage;
  String? succssesMessage;

  ProfileViewModel(
    this.user,
    this.profileRepository,
  );
  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    final result = await profileRepository.getProfile(user.id);
    switch (result) {
      case Ok<UserProfile>():
        age = result.value.age;
        weight = result.value.weight;
        height = result.value.height;
        sex = result.value.sex;
        kross = result.value.kross;
        vo2 = result.value.vo2;
        isLoadedLocaly = await profileRepository.isLocal;
        errorMessage = null;
      case Error<UserProfile>():
        errorMessage = result.error.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    UserProfile userProfile = UserProfile(age, weight, height, sex, kross, vo2);
    final res = await profileRepository.saveProfile(user.id, userProfile);
    switch (res) {
      case Ok<void>():
        succssesMessage = "Данные успешно сохранены";
      case Error<void>():
        errorMessage = "Ошибка сохранения данных: $res.error";
    }
  }

  Future<void> saveProfileLocaly() async {
    UserProfile userProfile = UserProfile(age, weight, height, sex, kross, vo2);
    final res = await profileRepository.saveProfileLocaly(user.id, userProfile);
    switch (res) {
      case Ok<void>():
        succssesMessage = "Данные успешно сохранены";
        isLoadedLocaly = true;
      case Error<void>():
        errorMessage = "Ошибка сохранения данных: ${res.error}";
    }
    notifyListeners();
  }

  Future<void> deleteProfileLocaly() async {
    final result = await profileRepository.deleteProfileLocaly(user.id);
    switch (result) {
      case Ok<void>():
        succssesMessage = "Данные успешно удалены";
        isLoadedLocaly = false;
      case Error<void>():
        errorMessage = "Ошибка при удалении данных ${result.error}";
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    profileRepository.invalidateCache();
    await loadProfile();
  }

  // ViewModel
  set setSex(String? value) {
    sex = value;
    notifyListeners();
  }
}
