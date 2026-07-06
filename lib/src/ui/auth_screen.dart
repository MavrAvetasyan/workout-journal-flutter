import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/app_controller.dart';
import 'widgets/ui_bits.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registerMode = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F2EA), Color(0xFFE6EEFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionKicker('Аккаунт'),
                          const SizedBox(height: 8),
                          Text(
                            _registerMode ? 'Создать аккаунт' : 'Войти в журнал тренировок',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          const MetaLine(
                            'Пока переносим мобильную версию шаг за шагом. Вход сохраняет локальную сессию, чтобы можно было продолжать работу в приложении.',
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                return 'Введи email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: const InputDecoration(labelText: 'Пароль'),
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Минимум 6 символов';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile.adaptive(
                            value: _showPassword,
                            title: const Text('Показать пароль'),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) => setState(() => _showPassword = value),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text(_registerMode ? 'Создать аккаунт' : 'Войти'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () => setState(() => _registerMode = !_registerMode),
                            child: Text(
                              _registerMode ? 'У меня уже есть аккаунт' : 'Создать аккаунт',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await widget.controller.signIn(
        email: _emailController.text,
        password: _passwordController.text,
        registerMode: _registerMode,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}
