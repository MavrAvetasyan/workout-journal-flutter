import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import 'widgets/ui_bits.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({
    super.key,
    required this.controller,
    required this.onEditExercise,
  });

  final AppController controller;
  final Future<void> Function([Exercise? exercise]) onEditExercise;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.activeExercises;
        return ScreenScaffold(
          title: 'Справочник',
          kicker: 'Упражнения',
          action: IconButton.filled(
            onPressed: () => onEditExercise(),
            icon: const Icon(Icons.add),
          ),
          child: items.isEmpty
              ? const _EmptyExerciseState()
              : Column(
                  children: items
                      .map(
                        (exercise) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              title: Text(exercise.name),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: MetaLine(exercise.type.label),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    await onEditExercise(exercise);
                                  } else {
                                    await controller.archiveExercise(exercise.id);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                                  PopupMenuItem(value: 'archive', child: Text('Скрыть')),
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

class _EmptyExerciseState extends StatelessWidget {
  const _EmptyExerciseState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Справочник пока пуст'),
            SizedBox(height: 8),
            MetaLine(
              'Добавим упражнения один раз, а потом будем просто выбирать их внутри тренировок.',
            ),
          ],
        ),
      ),
    );
  }
}
