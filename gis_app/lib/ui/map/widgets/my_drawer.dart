import 'package:flutter/material.dart';
import 'package:gis_app/data/models/user.dart';
import 'package:gis_app/data/repositories/auth_repository.dart';
import 'package:gis_app/data/repositories/login_repository.dart';
import 'package:gis_app/data/services/shared_preferences_service.dart';
import 'package:gis_app/data/services/db_service.dart';
import 'package:gis_app/ui/guid/widgets/guide_screen.dart';
import 'package:gis_app/ui/login/view_models/login_view_model.dart';
import 'package:gis_app/ui/login/widgets/login_screen.dart';
import 'package:gis_app/ui/map/view_models/main_view_model.dart';
import 'package:gis_app/ui/profile/view_models/profile_view_model.dart';
import 'package:gis_app/ui/profile/widgets/profile_screen.dart';
import 'package:gis_app/ui/routes/view_models/routes_view_model.dart';
import 'package:gis_app/ui/routes/widgets/routes_screen.dart';
import 'package:gis_app/ui/settings/view_models/settings_view_model.dart';
import 'package:gis_app/ui/settings/widgets/settings_screen.dart';

class MyDrawer extends StatelessWidget {
  final User user;
  final MainViewModel viewModel;
  final ProfileViewModel profileViewModel;
  final RoutesViewModel routesViewModel;
  final SettingsViewModel settingsViewModel;
  const MyDrawer({
    super.key,
    required this.user,
    required this.viewModel,
    required this.profileViewModel,
    required this.routesViewModel,
    required this.settingsViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Меню', style: TextStyle(fontSize: 20)),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(user.login ?? " ", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Профиль'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      profileViewModel, // используем готовый, не создаём новый
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Маршруты'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoutesScreen(routesViewModel, mainViewModel: viewModel, user),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Импортировать маршрут'),
              onTap: () async {
                Navigator.pop(context); // закрываем drawer
                await viewModel.importRoute();
                if (viewModel.errorMessage != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage!)),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Руководство пользователя'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GuideScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(viewModel: settingsViewModel),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Темная тема'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Выйти'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => LoginScreen(
                      viewModel: LoginViewModel(
                        loginRepository: LoginRepository(
                          dbService: ServerService.instance,
                        ),
                        authRepository: AuthRepository(
                          sharedPreferenceService: SharedPreferencesService(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
