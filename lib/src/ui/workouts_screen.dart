import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import 'widgets/ui_bits.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({
    super.key,
    required this.controller,
    required this.onEditWorkout,
  });

  final AppController controller;
  final Future<void> Function([Workout? workout]) onEditWorkout;

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  WorkoutStatus _filter = WorkoutStatus.planned;
  bool _showDoneExercises = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        Workout? activeWorkout;
        for (final item in widget.controller.workouts) {
          if (item.status == WorkoutStatus.active) {
            activeWorkout = item;
            break;
          }
        }

        final items = widget.controller.workouts.where((item) {
          if (item.status == WorkoutStatus.active) return false;
          if (_filter == WorkoutStatus.planned) return item.status == WorkoutStatus.planned;
          return item.status == WorkoutStatus.completed || item.status == WorkoutStatus.cancelled;
        }).toList(growable: false);

        return ScreenScaffold(
          title: 'История тренировок',
          kicker: 'Тренировки',
          action: IconButton.filled(
            onPressed: () => widget.onEditWorkout(),
            style: IconButton.styleFrom(
              backgroundColor: context.palette.accent,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterRow(
                filter: _filter,
                onChanged: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 18),
              if (activeWorkout != null) ...[
                _ActiveWorkoutCard(
                  workout: activeWorkout,
                  controller: widget.controller,
                  showDoneExercises: _showDoneExercises,
                  onToggleExerciseView: () {
                    setState(() => _showDoneExercises = !_showDoneExercises);
                  },
                  onEditWorkout: () => widget.onEditWorkout(activeWorkout),
                ),
                const SizedBox(height: 18),
              ],
              if (items.isEmpty && activeWorkout == null)
                const _EmptyBlock(
                  title: 'Тренировок пока нет',
                  text: 'Добавим первую тренировку, и история начнет собираться здесь.',
                )
              else
                ...items.map(
                  (workout) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _WorkoutCard(
                      workout: workout,
                      controller: widget.controller,
                      onEdit: () => widget.onEditWorkout(workout),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.onChanged,
  });

  final WorkoutStatus filter;
  final ValueChanged<WorkoutStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.accentSoft,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: context.palette.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SegmentedButton<WorkoutStatus>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: WorkoutStatus.planned,
              label: Text('Запланированные'),
            ),
            ButtonSegment(
              value: WorkoutStatus.completed,
              label: Text('Завершенные'),
            ),
          ],
          selected: {filter},
          onSelectionChanged: (value) => onChanged(value.first),
        ),
      ),
    );
  }
}

class _ActiveWorkoutCard extends StatelessWidget {
  const _ActiveWorkoutCard({
    required this.workout,
    required this.controller,
    required this.showDoneExercises,
    required this.onToggleExerciseView,
    required this.onEditWorkout,
  });

  final Workout workout;
  final AppController controller;
  final bool showDoneExercises;
  final VoidCallback onToggleExerciseView;
  final VoidCallback onEditWorkout;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final availableExercises = controller.activeExercises
        .where((item) => item.type == workout.type)
        .toList(growable: false);
    final entries = workout.exercises.where((entry) {
      if (showDoneExercises) {
        return entry.status == WorkoutEntryStatus.done;
      }
      return entry.status != WorkoutEntryStatus.done;
    }).toList(growable: false);

    final doneCount =
        workout.exercises.where((entry) => entry.status == WorkoutEntryStatus.done).length;
    final pendingCount = workout.exercises.length - doneCount;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.98),
            const Color(0xFFF7FAFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: palette.line),
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionKicker('Активная тренировка'),
                      const SizedBox(height: 8),
                      Text(
                        workout.title.isEmpty ? workout.type.label : workout.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      MetaLine(
                        workout.scheduledStartTime != null
                            ? 'План: ${formatDateTime(workout.scheduledStartTime)}'
                            : 'Без планового старта',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _TopActionButton(
                  icon: Icons.add,
                  filled: true,
                  onTap: availableExercises.isEmpty
                      ? null
                      : () => _showExercisePicker(context, availableExercises),
                ),
                const SizedBox(width: 8),
                _TopActionButton(
                  icon: Icons.edit_outlined,
                  onTap: onEditWorkout,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TinyPill(
                  text: workout.status.label,
                  color: palette.success,
                  foreground: const Color(0xFF276D4F),
                ),
                _TinyPill(text: '$pendingCount осталось'),
                _TinyPill(text: '$doneCount сделано'),
              ],
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.accentSoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: palette.line),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('Запланированные')),
                    ButtonSegment(value: true, label: Text('Сделанные')),
                  ],
                  selected: {showDoneExercises},
                  onSelectionChanged: (_) => onToggleExerciseView(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              const _EmptyInline(text: 'В этом списке пока ничего нет.')
            else
              ...entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _WorkoutEntryTile(
                    title: controller.exerciseById(entry.exerciseId)?.name ?? 'Упражнение',
                    summary: phaseSummary(
                      sets: (entry.fact ?? entry.plan)?.sets,
                      reps: (entry.fact ?? entry.plan)?.reps,
                      weight: (entry.fact ?? entry.plan)?.weight,
                      note: (entry.fact ?? entry.plan)?.note ?? '',
                    ),
                    trailing: _EntryActions(
                      onDone: entry.status == WorkoutEntryStatus.done
                          ? null
                          : () => controller.setWorkoutEntryStatus(
                                workout.id,
                                entry.id,
                                WorkoutEntryStatus.done,
                              ),
                      onCancel: entry.status == WorkoutEntryStatus.pending
                          ? null
                          : () => controller.setWorkoutEntryStatus(
                                workout.id,
                                entry.id,
                                WorkoutEntryStatus.pending,
                              ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => controller.completeWorkout(workout.id),
              child: const Text('Завершить тренировку'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExercisePicker(
    BuildContext context,
    List<Exercise> availableExercises,
  ) async {
    final existingIds = workout.exercises.map((item) => item.exerciseId).toSet();
    final items = availableExercises.where((item) => !existingIds.contains(item.id)).toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Все упражнения этого типа уже добавлены')),
      );
      return;
    }

    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            itemBuilder: (context, index) {
              final exercise = items[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(exercise.name),
                subtitle: exercise.description.trim().isEmpty
                    ? null
                    : Text(
                        exercise.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                onTap: () => Navigator.of(context).pop(exercise),
              );
            },
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemCount: items.length,
          ),
        );
      },
    );

    if (selected != null) {
      await controller.addExerciseToWorkout(workout.id, exercise: selected);
    }
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.workout,
    required this.controller,
    required this.onEdit,
  });

  final Workout workout;
  final AppController controller;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final summary = workout.exercises.isEmpty
        ? 'Без упражнений'
        : workout.exercises
            .map(
              (entry) =>
                  controller.exerciseById(entry.exerciseId)?.name ?? 'Удаленное упражнение',
            )
            .join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title.isEmpty ? workout.type.label : workout.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      MetaLine(
                        '${formatDateTime(workout.startTime)} · ${workout.type.label} · ${workout.status.label}',
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'activate') {
                      await controller.activateWorkout(workout.id);
                    } else if (value == 'delete') {
                      await controller.deleteWorkout(workout.id);
                    }
                  },
                  itemBuilder: (context) => [
                    if (workout.status == WorkoutStatus.planned)
                      const PopupMenuItem(value: 'activate', child: Text('Активировать')),
                    const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                    const PopupMenuItem(value: 'delete', child: Text('Удалить')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            MetaLine(summary),
          ],
        ),
      ),
    );
  }
}

class _WorkoutEntryTile extends StatelessWidget {
  const _WorkoutEntryTile({
    required this.title,
    required this.summary,
    required this.trailing,
  });

  final String title;
  final String summary;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  MetaLine(summary),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _EntryActions extends StatelessWidget {
  const _EntryActions({
    required this.onDone,
    required this.onCancel,
  });

  final VoidCallback? onDone;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 110),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.tonalIcon(
            onPressed: onDone,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              backgroundColor: context.palette.accentSoft,
              foregroundColor: context.palette.accent,
            ),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Готово'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            icon: const Icon(Icons.undo, size: 16),
            label: const Text('Отмена'),
          ),
        ],
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: filled ? palette.accentSoft : Colors.white,
        foregroundColor: filled ? palette.accent : palette.ink,
        side: BorderSide(color: palette.line),
        fixedSize: const Size(46, 46),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({
    required this.text,
    this.color,
    this.foreground,
  });

  final String text;
  final Color? color;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? palette.accentSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.line),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: foreground ?? palette.accent,
            ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.palette.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            MetaLine(text),
          ],
        ),
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  const _EmptyInline({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.palette.line),
      ),
      child: MetaLine(text),
    );
  }
}
