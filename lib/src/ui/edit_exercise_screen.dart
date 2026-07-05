import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';

class EditExerciseScreen extends StatefulWidget {
  const EditExerciseScreen({
    super.key,
    required this.controller,
    this.exercise,
  });

  final AppController controller;
  final Exercise? exercise;

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late WorkoutType _type;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _descriptionController = TextEditingController(text: widget.exercise?.description ?? '');
    _type = widget.exercise?.type ?? WorkoutType.strength;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Новое упражнение' : 'Редактирование упражнения'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название упражнения'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Введи название'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<WorkoutType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Тип упражнения'),
                items: WorkoutType.values
                    .map((item) => DropdownMenuItem(value: item, child: Text(item.label)))
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Описание или заметка'),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить упражнение'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.controller.saveExercise(
      id: widget.exercise?.id,
      name: _nameController.text,
      type: _type,
      description: _descriptionController.text,
    );
    if (mounted) Navigator.of(context).pop();
  }
}
