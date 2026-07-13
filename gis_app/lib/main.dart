import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/repositories/auth_repository.dart';
import 'package:gis_app/data/repositories/data_source_repository.dart';
import 'package:gis_app/data/repositories/geolocator_repository.dart';
import 'package:gis_app/data/repositories/login_repository.dart';
import 'package:gis_app/data/repositories/route_repository.dart';
import 'package:gis_app/data/services/local_service.dart';
import 'package:gis_app/data/services/shared_preferences_service.dart';
import 'package:gis_app/data/services/db_service.dart';
import 'package:gis_app/data/services/elevation_service.dart';
import 'package:gis_app/data/services/file_manager_service.dart';
import 'package:gis_app/data/services/geolocator_service.dart';
import 'package:gis_app/data/services/weather_service.dart';
import 'package:gis_app/ui/login/view_models/login_view_model.dart';
import 'package:gis_app/ui/login/widgets/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gis_app/ui/map/view_models/main_view_model.dart';
import 'package:gis_app/ui/map/widgets/main_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final sharedPreferencesService = SharedPreferencesService();
  final savedUser = await sharedPreferencesService.getSavedUser();
  runApp(MyApp(savedUser: savedUser));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.savedUser});

  final User? savedUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: savedUser == null
          ? LoginScreen(
              viewModel: LoginViewModel(
                loginRepository: LoginRepository(
                  dbService: ServerService.instance,
                ),
                authRepository: AuthRepository(sharedPreferenceService: SharedPreferencesService()),
              ),
            )
          : MainScreen(
              user: savedUser!,
              viewModel: MainViewModel(
                user: savedUser!,
                geolocatorRepository: GeolocatorRepository(GeolocatorService()),
                routeRepository: RouteRepository(
                  ElevationService(),
                  RemoteDataSource(dbService: ServerService.instance),
                  LocalDataSource(localDB: LocalService()),
                  FileManagerService(),
                  GeolocatorService(),
                  WeatherService(),
                  ServerService.instance
                ),
              ),
            ),
    );
  }
}
