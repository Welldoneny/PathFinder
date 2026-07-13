import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/models/user_credentials.dart';
import 'package:gis_app/data/services/db_service.dart';
import 'package:gis_app/utils/crypto.dart';
import 'package:gis_app/utils/result.dart';

/// Репозиторий для управления логикой аутентификации пользователя.
class LoginRepository {
  LoginRepository({required ServerService dbService}) : _dbService = dbService;

  final ServerService _dbService;

  /// Выполняет попытку входа пользователя с заданными именем пользователя и паролем.
Future<MyResult<User>> login(String username, String password) async {
  final credentialsResult = await _dbService.getUserCredentials(username);

  switch (credentialsResult) {
    case Error<UserCredentials>():
      return Error(credentialsResult.error); // пробрасываем ошибку
    case Ok<UserCredentials>():
      final credentials = credentialsResult.value;
      final inputHash = hashString(password + credentials.salt);
      if (inputHash == credentials.hashPassword) {
        return Ok(User(id: credentials.id));
      } else {
        return Error(Exception('Invalid username or password'));
      }
  }
}
}
