import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final void Function(String login, String password, bool rememberMe)?
  onLoginPressed;

  final VoidCallback? onCreateAccountPressed;

  const LoginPage({
    this.onLoginPressed,
    this.onCreateAccountPressed,
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_loginController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Не введен логин')));
      return;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Не введен пароль')));
      return;
    }
    widget.onLoginPressed?.call(
      _loginController.text.trim(),
      _passwordController.text,
      _rememberMe,
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
                  'Вход',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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

                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Запомнить меня'),
                  ],
                ),

                const SizedBox(height: 24),

                ElevatedButton(onPressed: _submit, child: const Text('Войти')),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: widget.onCreateAccountPressed,
                  child: const Text('Нет аккаунта? Создайте!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
