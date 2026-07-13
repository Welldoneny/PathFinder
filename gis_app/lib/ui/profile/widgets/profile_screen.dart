import 'package:flutter/material.dart';
import 'package:gis_app/ui/profile/view_models/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileViewModel viewModel;
  const ProfileScreen(this.viewModel, {super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _genders = ['Мужской', 'Женский'];
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _krossController = TextEditingController();
  final _vo2Controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.viewModel.loadProfile(); // вызвали один раз при открытии
  }

  void _onViewModelChanged() {
    _ageController.text = widget.viewModel.age ?? '';
    _weightController.text = widget.viewModel.weight ?? '';
    _heightController.text = widget.viewModel.height ?? '';
    _krossController.text = widget.viewModel.kross ?? '';
    _vo2Controller.text = widget.viewModel.vo2 ?? '';
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _krossController.dispose();
    _vo2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 800 ? screenWidth * 0.4 : double.infinity;
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Профиль')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (widget.viewModel.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Профиль'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: widget.viewModel.refresh,
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки: ${widget.viewModel.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.viewModel.loadProfile,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Профиль'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: widget.viewModel.refresh,
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: formWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.deepPurple.shade100,
                                child: Text(
                                  widget.viewModel.user.login != null
                                      ? widget.viewModel.user.login![0]
                                            .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.viewModel.user.login ?? '?',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ваши персональные данные используются для расчета потребления воды и еды',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Личные данные',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),
                      TextField(
                        controller: _ageController,
                        onChanged: (value) => widget.viewModel.age = value,
                        decoration: const InputDecoration(
                          labelText: 'Возраст',
                          suffixText: 'лет',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _weightController,
                        onChanged: (value) => widget.viewModel.weight = value,
                        decoration: const InputDecoration(
                          labelText: 'Вес',
                          suffixText: 'кг',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _heightController,
                        onChanged: (value) => widget.viewModel.height = value,
                        decoration: const InputDecoration(
                          labelText: 'Рост',
                          suffixText: 'см',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      InputDecorator(
                        decoration: const InputDecoration(labelText: 'Пол'),
                        child: DropdownButton<String>(
                          value: widget.viewModel.sex,
                          isExpanded: true,
                          underline: const SizedBox(), // убираем двойную линию
                          items: _genders
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (value) => widget.viewModel.setSex = value,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _krossController,
                        onChanged: (value) => widget.viewModel.kross = value,
                        decoration: const InputDecoration(
                          labelText: 'Темп бега на 1 километр',
                          suffixText: 'минуты',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _vo2Controller,
                        onChanged: (value) => widget.viewModel.vo2 = value,
                        decoration: const InputDecoration(
                          labelText: 'VO2',
                          suffixText: 'мл/кг',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              onPressed: () async {
                                await widget.viewModel.saveProfile();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        widget.viewModel.errorMessage ??
                                            widget.viewModel.succssesMessage ??
                                            "Default",
                                      ),
                                    ),
                                  );
                                  widget.viewModel.errorMessage = null;
                                  widget.viewModel.succssesMessage = null;
                                }
                              },
                              child: const Text('Сохранить'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 250,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                if (widget.viewModel.isLoading) return;
                                if (widget.viewModel.isLoadedLocaly) {
                                  await widget.viewModel.deleteProfileLocaly();
                                } else {
                                  await widget.viewModel.saveProfileLocaly();
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        widget.viewModel.errorMessage ??
                                            widget.viewModel.succssesMessage ??
                                            "Default",
                                      ),
                                    ),
                                  );
                                }
                                widget.viewModel.errorMessage = null;
                                widget.viewModel.succssesMessage = null;
                              },
                              icon: Icon(
                                widget.viewModel.isLoadedLocaly
                                    ? Icons.delete_outline
                                    : Icons.download_outlined,
                              ),
                              label: Text(
                                widget.viewModel.isLoadedLocaly
                                    ? 'Удалить с устройства'
                                    : 'Сохранить локально',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
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
