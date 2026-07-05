import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import 'widgets/ui_bits.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({
    super.key,
    required this.controller,
    required this.onEditMeasurement,
  });

  final AppController controller;
  final Future<void> Function([Measurement? measurement]) onEditMeasurement;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.measurements;
        return ScreenScaffold(
          title: 'Прогресс тела',
          kicker: 'Замеры',
          action: IconButton.filled(
            onPressed: () => onEditMeasurement(),
            icon: const Icon(Icons.add),
          ),
          child: items.isEmpty
              ? const _EmptyMeasurementsState()
              : Column(
                  children: items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              title: Text(item.title.isEmpty ? 'Замер' : item.title),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: MetaLine(
                                  [
                                    formatDateOnly(item.date),
                                    if (item.weight != null) 'Вес: ${item.weight}',
                                    if (item.bodyFat != null) 'Жир: ${item.bodyFat}%',
                                  ].join(' · '),
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    await onEditMeasurement(item);
                                  } else {
                                    await controller.deleteMeasurement(item.id);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                                  PopupMenuItem(value: 'delete', child: Text('Удалить')),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        );
      },
    );
  }
}

class _EmptyMeasurementsState extends StatelessWidget {
  const _EmptyMeasurementsState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Замеров пока нет'),
            SizedBox(height: 8),
            MetaLine(
              'Сохраним первый замер, чтобы потом смотреть изменения по весу и объемам.',
            ),
          ],
        ),
      ),
    );
  }
}
