import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';

class EditMeasurementScreen extends StatefulWidget {
  const EditMeasurementScreen({
    super.key,
    required this.controller,
    this.measurement,
  });

  final AppController controller;
  final Measurement? measurement;

  @override
  State<EditMeasurementScreen> createState() => _EditMeasurementScreenState();
}

class _EditMeasurementScreenState extends State<EditMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _weightController;
  late final TextEditingController _bodyFatController;
  late final TextEditingController _chestController;
  late final TextEditingController _waistController;
  late final TextEditingController _bellyController;
  late final TextEditingController _hipsController;
  late final TextEditingController _armController;
  late final TextEditingController _legController;
  late final TextEditingController _noteController;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final item = widget.measurement;
    _titleController = TextEditingController(text: item?.title ?? '');
    _weightController = TextEditingController(text: item?.weight?.toString() ?? '');
    _bodyFatController = TextEditingController(text: item?.bodyFat?.toString() ?? '');
    _chestController = TextEditingController(text: item?.chest?.toString() ?? '');
    _waistController = TextEditingController(text: item?.waist?.toString() ?? '');
    _bellyController = TextEditingController(text: item?.belly?.toString() ?? '');
    _hipsController = TextEditingController(text: item?.hips?.toString() ?? '');
    _armController = TextEditingController(text: item?.arm?.toString() ?? '');
    _legController = TextEditingController(text: item?.leg?.toString() ?? '');
    _noteController = TextEditingController(text: item?.note ?? '');
    _date = item?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _bellyController.dispose();
    _hipsController.dispose();
    _armController.dispose();
    _legController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.measurement == null ? 'Новый замер' : 'Редактирование замера'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название записи'),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Дата замера'),
                subtitle: Text(
                  '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              _DoubleFieldRow(
                left: _NumberField(controller: _weightController, label: 'Вес, кг'),
                right: _NumberField(controller: _bodyFatController, label: 'Процент жира'),
              ),
              const SizedBox(height: 12),
              _DoubleFieldRow(
                left: _NumberField(controller: _chestController, label: 'Грудь'),
                right: _NumberField(controller: _waistController, label: 'Талия'),
              ),
              const SizedBox(height: 12),
              _DoubleFieldRow(
                left: _NumberField(controller: _bellyController, label: 'Живот'),
                right: _NumberField(controller: _hipsController, label: 'Бедра'),
              ),
              const SizedBox(height: 12),
              _DoubleFieldRow(
                left: _NumberField(controller: _armController, label: 'Рука'),
                right: _NumberField(controller: _legController, label: 'Нога'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Заметка'),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить замер'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final measurement = Measurement(
      id: widget.measurement?.id ?? widget.controller.nextId(),
      title: _titleController.text.trim(),
      date: _date,
      note: _noteController.text.trim(),
      createdAt: widget.measurement?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      weight: _parseDouble(_weightController.text),
      bodyFat: _parseDouble(_bodyFatController.text),
      chest: _parseDouble(_chestController.text),
      waist: _parseDouble(_waistController.text),
      belly: _parseDouble(_bellyController.text),
      hips: _parseDouble(_hipsController.text),
      arm: _parseDouble(_armController.text),
      leg: _parseDouble(_legController.text),
    );
    await widget.controller.saveMeasurement(measurement);
    if (mounted) Navigator.of(context).pop();
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }
}

class _DoubleFieldRow extends StatelessWidget {
  const _DoubleFieldRow({
    required this.left,
    required this.right,
  });

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
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
