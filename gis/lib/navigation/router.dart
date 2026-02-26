import 'package:flutter/material.dart';
import 'package:path_finder/pages/main_page.dart';
import 'package:path_finder/pages/login_page.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String main = '/main';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (context) => LoginPage(
            onLoginPressed: (login, password, rememberMe) {
              Navigator.pushReplacementNamed(
                context,
                AppRouter.main,
                arguments: {'login': login, 'rememberMe': rememberMe},
              );
            },
          ),
        );

      // case register:
      //   return MaterialPageRoute(
      //     builder: (_) => const RegisterPage(),
      //   );

      case main:
        final args = settings.arguments as Map<String, dynamic>?;

        final login = args?['login'] as String;
        //final rememberMe = args?['rememberMe'] as bool? ?? false;

        return MaterialPageRoute(
          builder: (_) => MainPage(login: login),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
