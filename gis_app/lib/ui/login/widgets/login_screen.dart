import 'package:flutter/material.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/repositories/data_source_repository.dart';
import 'package:gis_app/data/repositories/registration_repository.dart';
import 'package:gis_app/data/repositories/route_repository.dart';
import 'package:gis_app/data/services/db_service.dart';
import 'package:gis_app/data/services/elevation_service.dart';
import 'package:gis_app/data/services/file_manager_service.dart';
import 'package:gis_app/data/services/geolocator_service.dart';
import 'package:gis_app/data/services/local_service.dart';
import 'package:gis_app/data/services/weather_service.dart';
import 'package:gis_app/ui/login/view_models/login_view_model.dart';
import 'package:gis_app/ui/map/view_models/main_view_model.dart';
import 'package:gis_app/ui/register/view_models/registration_view_model.dart';
import 'package:gis_app/ui/map/widgets/main_screen.dart';
import 'package:gis_app/ui/register/widgets/registration_screen.dart';
import 'package:gis_app/utils/result.dart';
import 'package:gis_app/data/repositories/geolocator_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // для больших экранов ограничиваем ширину формы, а для маленьких - растягиваем на всю ширину
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 800 ? screenWidth * 0.4 : double.infinity;
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          // системные элементы не перекроют контент
          body: SafeArea(
            child: Center(
              // скроллер если уж очень маленький экран
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: formWidth,
                  child: Column(
                    // растянуть на всю ширину
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Вход',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      TextField(
                        onChanged: (value) => widget.viewModel.username = value,
                        decoration: const InputDecoration(labelText: 'Логин'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) => widget.viewModel.password = value,
                        decoration: const InputDecoration(labelText: 'Пароль'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      // после поля пароля
                      Row(
                        children: [
                          Checkbox(
                            value: widget.viewModel.rememberMe,
                            onChanged: (_) {
                              widget.viewModel.toggleRememberMe();
                            },
                          ),
                          const Text('Запомнить меня'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      //Кнопка входа
                      ElevatedButton(
                        onPressed: () async {
                          // валидация входных данных
                          if (widget.viewModel.username?.isEmpty ?? true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Введите логин')),
                            );
                            return;
                          }
                          if (widget.viewModel.password?.isEmpty ?? true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Введите пароль')),
                            );
                            return;
                          }
                          final result = await widget.viewModel.login();
                          if (!context.mounted) {
                            return; // проверяем что виджет ещё жив
                          }
                          if (widget.viewModel.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(widget.viewModel.errorMessage!),
                              ),
                            );
                          }
                          switch (result) {
                            case Ok<User>():
                              User user = result.value;

                              final routeRepository = RouteRepository(
                                ElevationService(),
                                RemoteDataSource(
                                  dbService: ServerService.instance,
                                ),
                                LocalDataSource(localDB: LocalService()),
                                FileManagerService(),
                                GeolocatorService(),
                                WeatherService(),
                                ServerService.instance,
                              );
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => MainScreen(
                                      user: user,
                                      viewModel: MainViewModel(
                                        geolocatorRepository:
                                            GeolocatorRepository(
                                              GeolocatorService(),
                                            ),
                                        routeRepository: routeRepository,
                                        user: user,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            case Error<User>():
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result.error.toString()),
                                ),
                              );
                          }
                        },
                        child: const Text('Войти'),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => RegistrationScreen(
                                viewModel: RegistrationViewModel(
                                  registrationRepository:
                                      RegistrationRepository(
                                        dbService: ServerService.instance,
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('Нет аккаунта? Создайте!'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
