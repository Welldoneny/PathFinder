import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final int id;
  final String login;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final double? timePer1kmMin;
  final double? vo2;
  final void Function({
    required int? id,
    required int? age,
    required double? weight,
    required double? height,
    required String? gender,
    required double? timePer1kmMin,
    required double? vo2,
  })?
  onSavePressed;

  const ProfilePage({
    super.key,
    required this.id,
    required this.login,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.timePer1kmMin,
    this.vo2,
    this.onSavePressed,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _timePer1kmMinController = TextEditingController();
  final _vo2Controller = TextEditingController();
  String? _selectedGender;

  final List<String> _genders = ['Мужской', 'Женский'];

  @override
  void initState() {
    super.initState();
    _ageController.text = widget.age?.toString() ?? '';
    _weightController.text = widget.weight?.toString() ?? '';
    _heightController.text = widget.height?.toString() ?? '';
    _selectedGender = widget.gender;
    _timePer1kmMinController.text = widget.timePer1kmMin?.toString() ?? '';
    _vo2Controller.text = widget.vo2?.toString() ?? '';
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _timePer1kmMinController.dispose();
    _vo2Controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSavePressed?.call(
      id: widget.id,
      age: int.tryParse(_ageController.text),
      weight: double.tryParse(_weightController.text),
      height: double.tryParse(_heightController.text),
      gender: _selectedGender,
      timePer1kmMin: double.tryParse(_timePer1kmMinController.text),
      vo2: double.tryParse(_vo2Controller.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    widget.login[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  widget.login,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Ваши персональные данные используемые для расчета потребления воды и еды с помощью методов искусственного интеллекта',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Личные данные',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Возраст',
                  suffixText: 'лет',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Вес',
                  suffixText: 'кг',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Рост',
                  suffixText: 'см',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Пол',
                  border: OutlineInputBorder(),
                ),
                items: _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _timePer1kmMinController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Темп бега на 1 километр',
                  suffixText: 'минуты',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _vo2Controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'VO2',
                  suffixText: 'мл/кг',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('Сохранить'),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
