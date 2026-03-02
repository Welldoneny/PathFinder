import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final String login;
  final int id;
  const MyDrawer({super.key, required this.id, required this.login});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Меню', style: TextStyle(fontSize: 20)),
                  Text(login, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Профиль'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {'id': id, 'login': login}, // передай логин
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Маршруты'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/routes');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Руководство пользователя'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/guide');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Темная тема'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dark_mode');
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Выйти'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
