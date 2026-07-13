// ignore_for_file: unnecessary_getters_setters

import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/repositories/registration_repository.dart';
import 'package:gis_app/utils/result.dart';

class RegistrationViewModel {
  RegistrationViewModel({
    required RegistrationRepository registrationRepository,
  }) : // Repositories are manually assigned because they're private members.
       _registrationRepository = registrationRepository;

  final RegistrationRepository _registrationRepository;
  String? _username;
  String? _password;
  String? _confirmPassword;

  String? get username => _username;
  String? get password => _password;
  String? get confirmPassword => _confirmPassword;

  set username(String? value) {
    _username = value;
  }

  set password(String? value) {
    _password = value;
  }

  set confirmPassword(String? value) {
    _confirmPassword = value;
  }

  Future<MyResult<User>> registration() async {
    if (password != confirmPassword) {
      return Error(Exception('Пароли не совпадаютR'));
    }
    final result = await _registrationRepository.registration(_username ?? '', _password ?? '');
    switch (result) {
      case Ok<User>():
        return Ok(result.value);
      case Error<User>():
        return Error(result.error);
    }
  }
}
