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
  final _codeController = TextEditingController();

  bool _codeRequested = false;
  bool _submitting = false;
  String? _debugCode;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCodeStep = _codeRequested;

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
                            isCodeStep
                                ? 'Подтверди вход кодом'
                                : 'Войти по коду из письма',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          MetaLine(
                            isCodeStep
                                ? 'Мы отправили код на ${_emailController.text.trim()}. Введи его ниже.'
                                : 'Введи почту. Мы отправим код входа красивым письмом без пароля.',
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            enabled: !isCodeStep && !_submitting,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Введи email';
                              }
                              return null;
                            },
                          ),
                          if (isCodeStep) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _codeController,
                              enabled: !_submitting,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Код из письма',
                              ),
                              validator: (value) {
                                if (!isCodeStep) return null;
                                if (value == null || value.trim().length < 4) {
                                  return 'Введи код';
                                }
                                return null;
                              },
                            ),
                          ],
                          if (_debugCode != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F7FF),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFD9E6FF),
                                ),
                              ),
                              child: Text(
                                'Тестовый код: $_debugCode',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: _submitting
                                ? null
                                : (isCodeStep ? _verifyCode : _requestCode),
                            child: Text(
                              isCodeStep ? 'Войти' : 'Получить код',
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _submitting
                                ? null
                                : (isCodeStep ? _requestCode : _clearForm),
                            child: Text(
                              isCodeStep ? 'Отправить код еще раз' : 'Очистить',
                            ),
                          ),
                          if (isCodeStep) ...[
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _submitting ? null : _backToEmail,
                              child: const Text('Изменить почту'),
                            ),
                          ],
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

  Future<void> _requestCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final response = await widget.controller.requestSignInCode(
        email: _emailController.text,
      );
      if (!mounted) return;
      setState(() {
        _codeRequested = true;
        _debugCode = response.debugCode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Код отправлен на почту')),
      );
    } on ApiException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.controller.signInWithCode(
        email: _emailController.text,
        code: _codeController.text,
      );
    } on ApiException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _backToEmail() {
    setState(() {
      _codeRequested = false;
      _codeController.clear();
      _debugCode = null;
    });
  }

  void _clearForm() {
    _emailController.clear();
    _codeController.clear();
    setState(() {
      _codeRequested = false;
      _debugCode = null;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
