import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/services/db_service.dart';
import 'package:gis_app/utils/crypto.dart';
import 'package:gis_app/utils/result.dart';

/// Репозиторий для управления логикой регистрации пользователя.
class RegistrationRepository {
  RegistrationRepository({required ServerService dbService})
    : _dbService = dbService;

  final ServerService _dbService;

  /// Выполняет попытку регистрации пользователя с заданными именем пользователя и паролем.
  Future<MyResult<User>> registration(String username, String password) async {
    final saltResult = await _dbService.getNewSalt();
    switch (saltResult) {
      case Error<String>():
        return Error(saltResult.error); // пробрасываем ошибку
      case Ok<String>():
        final salt = saltResult.value;
        final hashPassword = hashString(password + salt);
        final registrationResult = await _dbService.addNewUser(
          username,
          salt,
          hashPassword,
        );
        switch (registrationResult) {
          case Error<User>():
            return Error(registrationResult.error); // пробрасываем ошибку
          case Ok<User>():
            return Ok(registrationResult.value);
        }
    }
  }
}
