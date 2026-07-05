import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import 'edit_exercise_screen.dart';
import 'edit_measurement_screen.dart';
import 'edit_workout_screen.dart';
import 'exercises_screen.dart';
import 'measurements_screen.dart';
import 'more_screen.dart';
import 'workouts_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      WorkoutsScreen(
        controller: widget.controller,
        onEditWorkout: _openWorkoutEditor,
      ),
      ExercisesScreen(
        controller: widget.controller,
        onEditExercise: _openExerciseEditor,
      ),
      MeasurementsScreen(
        controller: widget.controller,
        onEditMeasurement: _openMeasurementEditor,
      ),
      MoreScreen(controller: widget.controller),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Тренировки'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Упражнения'),
          NavigationDestination(icon: Icon(Icons.straighten), label: 'Замеры'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Еще'),
        ],
      ),
    );
  }

  Future<void> _openWorkoutEditor([Workout? workout]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EditWorkoutScreen(
          controller: widget.controller,
          workout: workout,
        ),
      ),
    );
  }

  Future<void> _openExerciseEditor([Exercise? exercise]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EditExerciseScreen(
          controller: widget.controller,
          exercise: exercise,
        ),
      ),
    );
  }

  Future<void> _openMeasurementEditor([Measurement? measurement]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EditMeasurementScreen(
          controller: widget.controller,
          measurement: measurement,
        ),
      ),
    );
  }
}
