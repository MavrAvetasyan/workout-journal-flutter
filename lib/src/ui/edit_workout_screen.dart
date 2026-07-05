import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';

class EditWorkoutScreen extends StatefulWidget {
  const EditWorkoutScreen({
    super.key,
    required this.controller,
    this.workout,
  });

  final AppController controller;
  final Workout? workout;

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late WorkoutType _type;
  late WorkoutStatus _status;
  late DateTime _start;
  late DateTime _end;
  late List<_WorkoutEntryDraft> _entries;

  @override
  void initState() {
    super.initState();
    final workout = widget.workout;
    _titleController = TextEditingController(text: workout?.title ?? '');
    _type = workout?.type ?? WorkoutType.strength;
    _status = workout?.status ?? WorkoutStatus.planned;
    _start = workout?.scheduledStartTime ?? workout?.startTime ?? DateTime.now();
    _end = workout?.scheduledEndTime ?? workout?.endTime ?? _start.add(const Duration(hours: 1));
    _entries = (workout?.exercises ?? const <WorkoutEntry>[])
        .map((entry) => _WorkoutEntryDraft.fromEntry(entry))
        .toList(growable: true);
    if (_entries.isEmpty) {
      _entries = [_WorkoutEntryDraft.blank(widget.controller.nextId())];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableExercises = widget.controller.activeExercises
        .where((item) => item.type == _type)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout == null ? 'Новая тренировка' : 'Редактирование тренировки'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название тренировки'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<WorkoutType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Тип тренировки'),
                items: WorkoutType.values
                    .map((item) => DropdownMenuItem(value: item, child: Text(item.label)))
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                      final nextAvailable = widget.controller.activeExercises
                          .where((item) => item.type == _type)
                          .toList(growable: false);
                      for (final entry in _entries) {
                        if (!nextAvailable.any((item) => item.id == entry.exerciseId)) {
                          entry.exerciseId = null;
                        }
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<WorkoutStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Статус тренировки'),
                items: const [
                  DropdownMenuItem(value: WorkoutStatus.planned, child: Text('Запланирована')),
                  DropdownMenuItem(value: WorkoutStatus.active, child: Text('Активна')),
                  DropdownMenuItem(value: WorkoutStatus.completed, child: Text('Сразу завершить')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              _DateTile(
                title: _status == WorkoutStatus.completed
                    ? 'Фактическое начало'
                    : 'Плановое начало',
                date: _start,
                onTap: () async {
                  final next = await _pickDateTime(_start);
                  if (next != null) setState(() => _start = next);
                },
              ),
              const SizedBox(height: 10),
              _DateTile(
                title: _status == WorkoutStatus.completed
                    ? 'Фактическое окончание'
                    : 'Плановое окончание',
                date: _end,
                onTap: () async {
                  final next = await _pickDateTime(_end);
                  if (next != null) setState(() => _end = next);
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Упражнения',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {
                      setState(() {
                        _entries.add(_WorkoutEntryDraft.blank(widget.controller.nextId()));
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (availableExercises.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Для этого типа тренировки пока нет упражнений в справочнике.',
                  ),
                ),
              ..._entries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WorkoutEntryEditor(
                    index: index,
                    item: item,
                    exercises: availableExercises,
                    onRemove: _entries.length == 1
                        ? null
                        : () {
                            setState(() {
                              final removed = _entries.removeAt(index);
                              removed.dispose();
                            });
                          },
                  ),
                );
              }),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить тренировку'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_end.isBefore(_start)) return;

    final entries = _entries
        .where((item) => item.exerciseId != null)
        .map((item) => item.toEntry())
        .toList(growable: false);
    if (entries.isEmpty) return;

    final now = DateTime.now();
    final workout = Workout(
      id: widget.workout?.id ?? widget.controller.nextId(),
      title: _titleController.text.trim(),
      type: _type,
      status: _status,
      startTime: _status == WorkoutStatus.completed
          ? _start
          : (_status == WorkoutStatus.active
              ? (widget.workout?.actualStartTime ?? now)
              : _start),
      endTime: _status == WorkoutStatus.completed ? _end : null,
      scheduledStartTime: _start,
      scheduledEndTime: _end,
      actualStartTime: _status == WorkoutStatus.planned
          ? widget.workout?.actualStartTime
          : (_status == WorkoutStatus.completed ? _start : (widget.workout?.actualStartTime ?? now)),
      actualEndTime: _status == WorkoutStatus.completed ? _end : widget.workout?.actualEndTime,
      createdAt: widget.workout?.createdAt ?? now,
      updatedAt: now,
      exercises: entries,
    );
    await widget.controller.saveWorkout(workout);
    if (mounted) Navigator.of(context).pop();
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.title,
    required this.date,
    required this.onTap,
  });

  final String title;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(text),
      trailing: const Icon(Icons.schedule),
      onTap: onTap,
    );
  }
}

class _WorkoutEntryEditor extends StatelessWidget {
  const _WorkoutEntryEditor({
    required this.index,
    required this.item,
    required this.exercises,
    this.onRemove,
  });

  final int index;
  final _WorkoutEntryDraft item;
  final List<Exercise> exercises;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Упражнение ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: item.exerciseId,
              decoration: const InputDecoration(labelText: 'Выбрать упражнение'),
              items: exercises
                  .map((exercise) => DropdownMenuItem(value: exercise.id, child: Text(exercise.name)))
                  .toList(growable: false),
              onChanged: (value) => item.exerciseId = value,
              validator: (value) => value == null || value.isEmpty ? 'Выбери упражнение' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _EntryNumberField(controller: item.setsController, label: 'Подходы')),
                const SizedBox(width: 10),
                Expanded(child: _EntryNumberField(controller: item.weightController, label: 'Вес, кг')),
                const SizedBox(width: 10),
                Expanded(child: _EntryNumberField(controller: item.repsController, label: 'Повторы')),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Заметка'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryNumberField extends StatelessWidget {
  const _EntryNumberField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _WorkoutEntryDraft {
  _WorkoutEntryDraft({
    required this.id,
    required this.exerciseId,
    required this.status,
    required this.setsController,
    required this.weightController,
    required this.repsController,
    required this.noteController,
  });

  factory _WorkoutEntryDraft.blank(String id) {
    return _WorkoutEntryDraft(
      id: id,
      exerciseId: null,
      status: WorkoutEntryStatus.pending,
      setsController: TextEditingController(),
      weightController: TextEditingController(),
      repsController: TextEditingController(),
      noteController: TextEditingController(),
    );
  }

  factory _WorkoutEntryDraft.fromEntry(WorkoutEntry entry) {
    final source = entry.fact ?? entry.plan;
    return _WorkoutEntryDraft(
      id: entry.id,
      exerciseId: entry.exerciseId,
      status: entry.status,
      setsController: TextEditingController(text: source?.sets?.toString() ?? ''),
      weightController: TextEditingController(text: source?.weight?.toString() ?? ''),
      repsController: TextEditingController(text: source?.reps?.toString() ?? ''),
      noteController: TextEditingController(text: source?.note ?? ''),
    );
  }

  final String id;
  String? exerciseId;
  WorkoutEntryStatus status;
  final TextEditingController setsController;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final TextEditingController noteController;

  WorkoutEntry toEntry() {
    final phase = WorkoutPhase(
      sets: int.tryParse(setsController.text),
      weight: double.tryParse(weightController.text.replaceAll(',', '.')),
      reps: int.tryParse(repsController.text),
      note: noteController.text.trim(),
    );
    return WorkoutEntry(
      id: id,
      exerciseId: exerciseId ?? '',
      status: status,
      plan: phase,
      fact: status == WorkoutEntryStatus.done ? phase : null,
    );
  }

  void dispose() {
    setsController.dispose();
    weightController.dispose();
    repsController.dispose();
    noteController.dispose();
  }
}
