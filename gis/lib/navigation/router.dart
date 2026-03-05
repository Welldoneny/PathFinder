import 'package:flutter/material.dart';
import 'package:path_finder/crypto/crypto.dart';
import 'package:path_finder/crypto/salt.dart';
import 'package:path_finder/db/db_service.dart';
import 'package:path_finder/pages/main_page.dart';
import 'package:path_finder/pages/login_page.dart';
import 'package:path_finder/pages/profile_page.dart';
import 'package:path_finder/pages/registration_page.dart';
import 'package:path_finder/pages/routes_page.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String routes = '/routes';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (context) => LoginPage(
            onLoginPressed: (login, password, rememberMe) async {
              Future<bool?> isConnected = DbService.chechConnect();
              if (await isConnected == false) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Не удалось подключиться к базе данных"),
                  ),
                );
                return;
              }

              final credentials = await DbService.getUserCredentials(login);
              debugPrint("after credentials");
              if (!context.mounted) return;

              if (credentials == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Неверный логин или пароль")),
                );
                return;
              }

              final salt = credentials['salt']!;
              final hashPassword = credentials['hashPassword']!;

              if (hashPassword == hashString(password + salt)) {
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(
                  context,
                  AppRouter.main,
                  arguments: {
                    'id': credentials['id'],
                    'login': login,
                    'rememberMe': rememberMe,
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Неверный логин или пароль")),
                );
              }
            },
            onCreateAccountPressed: () {
              Navigator.pushReplacementNamed(context, AppRouter.register);
            },
          ),
        );

      case register:
        return MaterialPageRoute(
          builder: (context) => RegisterPage(
            onLoginPressed: () {
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
            onRegisterPressed: (login, password) async {
              Future<bool?> isConnected = DbService.chechConnect();
              if (await isConnected == false) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Не удалось подключиться к базе данных"),
                  ),
                );
                return;
              }
              final salt = await DbService.getNewSalt();
              String rightSalt = salt ?? generateSalt();
              final hashPassword = hashString(password + rightSalt);
              try {
                Future<bool?> isAdded = DbService.addNewUser(
                  login,
                  rightSalt,
                  hashPassword,
                );
                if (await isAdded == true) {
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(
                    context,
                    AppRouter.main,
                    arguments: {'login': login},
                  );
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Не удалось зарегистрироваться на этот логин",
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Не удалось зарегистрироваться, попробуйте позже",
                    ),
                  ),
                );
              }
            },
          ),
        );

      case profile:
        final args = settings.arguments as Map<String, dynamic>?;
        final int id = args?['id'] ?? 0;
        final String login = args?['login'] ?? '';
        return MaterialPageRoute(
          builder: (context) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: DbService.getProfile(id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final profile = snapshot.data;
                final String? gender = profile?['sex'] == null
                    ? null
                    : (profile!['sex'] == true ? 'Мужской' : 'Женский');
                final int? age = profile?['age'];
                final double? weight = profile?['weight'];
                final double? height = profile?['height'];
                final double? timePer1kmMin = profile?['timePer1kmMin'];
                final double? vo2 = profile?['vo2'];
                return ProfilePage(
                  id: args?['id'] ?? 0,
                  login: login,
                  age: age,
                  weight: weight,
                  height: height,
                  gender: gender,
                  timePer1kmMin: timePer1kmMin,
                  vo2: vo2,
                  onSavePressed:
                      ({
                        id,
                        age,
                        weight,
                        height,
                        gender,
                        timePer1kmMin,
                        vo2,
                      }) async {
                        Future<bool?> isConnected = DbService.chechConnect();
                        if (await isConnected == false) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Не удалось подключиться к базе данных",
                              ),
                            ),
                          );
                          return;
                        }
                        bool sex = (gender == 'Мужской') ? true : false;
                        try {
                          Future<bool?> isAdded = DbService.saveProfile(
                            id,
                            age,
                            sex,
                            weight,
                            height,
                            timePer1kmMin,
                            vo2,
                          );
                          if (await isAdded == true) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Данные сохранены')),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Не удалось сохранить"),
                            ),
                          );
                        }
                      },
                );
              },
            );
          },
        );

      case routes:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => RoutesPage(
            userId: args?['id'] ?? 0,
            onSelectRoute: (routeId) async {
              final points = await DbService.getRoutePoints(routeId);
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(
                context,
                AppRouter.main,
                arguments: {
                  'id': args?['id'] ?? 0,
                  'login': args?['login'] ?? '',
                  'routePoints': points,
                },
              );
            },
            onCalculateRoute: (routeId) {
              // переход к расчёту ИИ
            },
            onDeleteRoute: (routeId) async {
              final isDeleted = DbService.deleteRoute(routeId);
              if (await isDeleted == true) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Успешно удалено")),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Не удалось удалить")),
                );
              }
            },
          ),
        );

      case main:
        final args = settings.arguments as Map<String, dynamic>?;

        final login = args?['login'] as String;
        final id = args?['id'] as int;
        final routePoints = args?['routePoints'];
        //final rememberMe = args?['rememberMe'] as bool? ?? false;

        return MaterialPageRoute(
          builder: (_) => MainPage(id: id, login: login, routePoints: routePoints),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
