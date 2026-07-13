import 'package:flutter/foundation.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/repositories/auth_repository.dart';
import 'package:gis_app/data/repositories/login_repository.dart';
import 'package:gis_app/utils/result.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required LoginRepository loginRepository,
    required AuthRepository authRepository,
  }) : _authRepository =
           authRepository, // Repositories are manually assigned because they're private members.
       _loginRepository = loginRepository;

  final LoginRepository _loginRepository;
  final AuthRepository _authRepository;
  String? username;
  String? password;
  bool rememberMe = false;
  String? errorMessage;

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    notifyListeners();
  }

  Future<MyResult<User>> login() async {
    final result = await _loginRepository.login(username ?? '', password ?? '');
    switch (result) {
      case Ok<User>():
        User user = result.value;
        user.login = username; // сохраняем логин в объекте User
        if (rememberMe) {
          final res = await _authRepository.saveUser((result).value);
          switch (res) {
            case Ok<void>():
              errorMessage = null;
            case Error<void>():
              errorMessage = res.error.toString();
              notifyListeners();
          }
        }
        return Ok(user);
      case Error<User>():
        return Error(result.error);
    }
  }
}
