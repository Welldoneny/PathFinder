import 'package:flutter/material.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/repositories/data_source_repository.dart';
import 'package:gis_app/data/repositories/geolocator_repository.dart';
import 'package:gis_app/data/repositories/route_repository.dart';
import 'package:gis_app/data/services/db_service.dart';
import 'package:gis_app/data/services/elevation_service.dart';
import 'package:gis_app/data/services/file_manager_service.dart';
import 'package:gis_app/data/services/geolocator_service.dart';
import 'package:gis_app/data/services/local_service.dart';
import 'package:gis_app/data/services/weather_service.dart';
import 'package:gis_app/ui/map/view_models/main_view_model.dart';
import 'package:gis_app/ui/register/view_models/registration_view_model.dart';
import 'package:gis_app/ui/map/widgets/main_screen.dart';
import 'package:gis_app/utils/result.dart';

class RegistrationScreen extends StatelessWidget {
  final RegistrationViewModel viewModel;
  const RegistrationScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 800 ? screenWidth * 0.4 : double.infinity;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: formWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Регистрация',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  TextField(
                    onChanged: (value) => viewModel.username = value,
                    decoration: const InputDecoration(labelText: 'Логин'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => viewModel.password = value,
                    decoration: const InputDecoration(labelText: 'Пароль'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => viewModel.confirmPassword = value,
                    decoration: const InputDecoration(
                      labelText: 'Повторите пароль',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (viewModel.username?.isEmpty ?? true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Введите логин')),
                        );
                        return;
                      }
                      if (viewModel.password?.isEmpty ?? true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Введите пароль')),
                        );
                        return;
                      }
                      if (viewModel.confirmPassword?.isEmpty ?? true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Подтвердите пароль')),
                        );
                        return;
                      }
                      final result = await viewModel.registration();
                      if (!context.mounted) {
                        return; // проверяем что виджет ещё жив
                      }
                      switch (result) {
                        case Ok<User>():
                          User user = result.value;

                          final routeRepository = RouteRepository(
                            ElevationService(),
                            RemoteDataSource(dbService: ServerService.instance),
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
                                    geolocatorRepository: GeolocatorRepository(
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
                            SnackBar(content: Text(result.error.toString())),
                          );
                      }
                    },
                    child: const Text('Зарегистрироваться'),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Уже есть аккаунт? Войдите!'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
