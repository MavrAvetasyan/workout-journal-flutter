import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import 'widgets/ui_bits.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ScreenScaffold(
          title: 'Данные и настройки',
          kicker: 'Еще',
          child: Column(
            children: [
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: const Text('Аккаунт'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: MetaLine(controller.auth?.email ?? 'Вход не выполнен'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Локальные данные', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      const MetaLine(
                        'Сейчас мобильная версия хранит тренировки, упражнения и замеры внутри приложения на этом устройстве.',
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => controller.clearAll(),
                        child: const Text('Очистить локальные данные'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => controller.signOut(),
                child: const Text('Выйти'),
              ),
            ],
          ),
        );
      },
    );
  }
}
