import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function(String login, String password)? onRegisterPressed;
  final VoidCallback? onLoginPressed;

  const RegisterPage({
    super.key,
    this.onRegisterPressed,
    this.onLoginPressed,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_loginController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не введен логин')),
      );
      return;      
    }
    if (_passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не введен пароль')),
      );
      return;      
    }
    if (_confirmPasswordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Подтвердите пароль')),
      );
      return;      
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароли не совпадают')),
      );
      return;
    }

    widget.onRegisterPressed?.call(
      _loginController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                const Text(
                  'Регистрация',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: _loginController,
                  decoration: const InputDecoration(
                    labelText: 'Логин',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Повторите пароль',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Зарегистрироваться'),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: widget.onLoginPressed,
                  child: const Text('Уже есть аккаунт? Войдите!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}