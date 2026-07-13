import 'package:flutter/material.dart';
import 'package:gis_app/ui/settings/view_models/settings_view_model.dart';
import 'package:gis_app/ui/settings/widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.viewModel});
  final SettingsViewModel viewModel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _languages = [
    'Русский',
    'Українська',
    'Deutsch',
    'English',
  ];
  final List<String> _maps = ['OpenStreetMap', 'Satelite'];
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 800 ? screenWidth * 0.4 : double.infinity;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: formWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Интерфейс",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          settingsTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Тема',
                            subtitle: 'Светлая или тёмная',
                            trailing: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'light',
                                  label: Text('Светлая'),
                                ),
                                ButtonSegment(
                                  value: 'dark',
                                  label: Text('Тёмная'),
                                ),
                              ],
                              selected: {widget.viewModel.theme},
                              onSelectionChanged: (value) =>
                                  widget.viewModel.setTheme = value.first,
                            ),
                          ),
                          settingsTile(
                            icon: Icons.language,
                            title: 'Язык',
                            subtitle: 'Язык интерфейса',
                            showDivider: false,
                            trailing: DropdownButton<String>(
                              value: widget.viewModel.language,
                              underline: const SizedBox(),
                              items: _languages
                                  .map(
                                    (l) => DropdownMenuItem(
                                      value: l,
                                      child: Text(l),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  widget.viewModel.setLanguage = value!,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Карта",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          settingsTile(
                            icon: Icons.map_outlined,
                            title: 'Карта по умолчанию',
                            subtitle: 'Используется при запуске',
                            trailing: DropdownButton<String>(
                              value: widget.viewModel.defaultMap,
                              underline: const SizedBox(),
                              items: _maps
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  widget.viewModel.setDefaultMap = value!,
                            ),
                          ),
                          settingsTile(
                            icon: Icons.folder_outlined,
                            title: 'Папка экспорта',
                            subtitle:
                                widget.viewModel.exportPath ?? 'Не выбрана',
                            showDivider: false,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                // TODO: FilePicker
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "О приложении",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: settingsTile(
                        icon: Icons.info_outline,
                        title: 'Версия',
                        showDivider: false,
                        trailing: const Text(
                          '1.0.0',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
