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
          builder: (_) => const LoginPage(),
        );

      // case register:
      //   return MaterialPageRoute(
      //     builder: (_) => const RegisterPage(),
      //   );

      case main:
        return MaterialPageRoute(
          builder: (_) => const MainPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}