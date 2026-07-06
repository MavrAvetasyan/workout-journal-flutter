import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'api_client.dart';
import 'app_storage.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.storage,
    required this.api,
  });

  final AppStorage storage;
  final ApiClient api;
  final Uuid _uuid = const Uuid();

  AuthSession? _auth;
  List<Workout> _workouts = const [];
  List<Exercise> _exercises = const [];
  List<Measurement> _measurements = const [];

  AuthSession? get auth => _auth;
  bool get isSignedIn => _auth != null;
  List<Workout> get workouts => List.unmodifiable(_workouts);
  List<Exercise> get exercises => List.unmodifiable(_exercises);
  List<Exercise> get activeExercises =>
      _exercises.where((item) => !item.archived).toList(growable: false);
  List<Measurement> get measurements => List.unmodifiable(_measurements);

  Future<void> load() async {
    final snapshot = await storage.load();
    _auth = snapshot.auth;
    _workouts = snapshot.workouts;
    _exercises = snapshot.exercises;
    _measurements = snapshot.measurements;

    if (_hasRemoteSession) {
      try {
        await _pullRemote();
      } catch (_) {
        // Keep local data when the server is unreachable.
      }
    }

    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
    required bool registerMode,
  }) async {
    final localSnapshot = AppSnapshot(
      workouts: _workouts,
      exercises: _exercises,
      measurements: _measurements,
      auth: _auth,
    );

    final response = registerMode
        ? await api.register(email: email, password: password)
        : await api.login(email: email, password: password);

    _auth = AuthSession(
      email: response.email,
      isRegisterMode: registerMode,
      accessToken: response.token,
      userId: response.userId,
    );

    final remote = await api.fetchSync(accessToken: response.token);
    if (remote.isEmpty && _snapshotHasData(localSnapshot)) {
      await _pushRemote();
    } else {
      _applyRemote(remote);
    }

    await _persist(syncRemote: false);
  }

  Future<void> signOut() async {
    _auth = null;
    await _persist(syncRemote: false);
  }

  Exercise? exerciseById(String id) {
    for (final item in _exercises) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> saveExercise({
    String? id,
    required String name,
    required WorkoutType type,
    required String description,
  }) async {
    final exercise = Exercise(
      id: id ?? _uuid.v4(),
      name: name.trim(),
      type: type,
      description: description.trim(),
      archived: false,
    );

    final list = [..._exercises];
    final index = list.indexWhere((item) => item.id == exercise.id);
    if (index >= 0) {
      list[index] = exercise;
    } else {
      list.add(exercise);
    }
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    _exercises = list;
    await _persist();
  }

  Future<void> archiveExercise(String id) async {
    _exercises = _exercises
        .map((item) => item.id == id ? item.copyWith(archived: true) : item)
        .toList(growable: false);
    await _persist();
  }

  Future<void> saveMeasurement(Measurement measurement) async {
    final list = [..._measurements];
    final index = list.indexWhere((item) => item.id == measurement.id);
    if (index >= 0) {
      list[index] = measurement;
    } else {
      list.add(measurement);
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    _measurements = list;
    await _persist();
  }

  Future<void> deleteMeasurement(String id) async {
    _measurements =
        _measurements.where((item) => item.id != id).toList(growable: false);
    await _persist();
  }

  Future<void> saveWorkout(Workout workout) async {
    final list = [..._workouts];
    final index = list.indexWhere((item) => item.id == workout.id);
    if (index >= 0) {
      list[index] = workout;
    } else {
      list.add(workout);
    }
    list.sort(
      (a, b) => (b.startTime ?? b.createdAt).compareTo(
        a.startTime ?? a.createdAt,
      ),
    );
    _workouts = list;
    await _persist();
  }

  Future<void> deleteWorkout(String id) async {
    _workouts = _workouts.where((item) => item.id != id).toList(
          growable: false,
        );
    await _persist();
  }

  Future<void> activateWorkout(String id) async {
    _workouts = _workouts.map((workout) {
      if (workout.id != id) {
        return workout.status == WorkoutStatus.active
            ? workout.copyWith(
                status: WorkoutStatus.planned,
                updatedAt: DateTime.now(),
              )
            : workout;
      }
      final startedAt = workout.actualStartTime ?? DateTime.now();
      return workout.copyWith(
        status: WorkoutStatus.active,
        actualStartTime: startedAt,
        startTime: startedAt,
        updatedAt: DateTime.now(),
      );
    }).toList(growable: false);
    await _persist();
  }

  Future<void> completeWorkout(String id) async {
    _workouts = _workouts.map((workout) {
      if (workout.id != id) return workout;
      final end = DateTime.now();
      final start =
          workout.actualStartTime ?? workout.scheduledStartTime ?? DateTime.now();
      final entries = workout.exercises
          .map(
            (entry) => entry.status == WorkoutEntryStatus.done
                ? entry
                : entry.copyWith(
                    status: WorkoutEntryStatus.done,
                    fact: entry.fact ?? entry.plan,
                  ),
          )
          .toList(growable: false);
      return workout.copyWith(
        status: WorkoutStatus.completed,
        actualStartTime: start,
        actualEndTime: end,
        startTime: start,
        endTime: end,
        exercises: entries,
        updatedAt: end,
      );
    }).toList(growable: false);
    await _persist();
  }

  Future<void> setWorkoutEntryStatus(
    String workoutId,
    String entryId,
    WorkoutEntryStatus status,
  ) async {
    _workouts = _workouts.map((workout) {
      if (workout.id != workoutId) return workout;
      final entries = workout.exercises.map((entry) {
        if (entry.id != entryId) return entry;
        return entry.copyWith(
          status: status,
          fact:
              status == WorkoutEntryStatus.done ? (entry.fact ?? entry.plan) : entry.fact,
        );
      }).toList(growable: false);
      return workout.copyWith(exercises: entries, updatedAt: DateTime.now());
    }).toList(growable: false);
    await _persist();
  }

  Future<void> toggleWorkoutEntry(String workoutId, String entryId) async {
    _workouts = _workouts.map((workout) {
      if (workout.id != workoutId) return workout;
      final entries = workout.exercises.map((entry) {
        if (entry.id != entryId) return entry;
        final makeDone = entry.status != WorkoutEntryStatus.done;
        return entry.copyWith(
          status: makeDone ? WorkoutEntryStatus.done : WorkoutEntryStatus.pending,
          fact: makeDone ? (entry.fact ?? entry.plan) : entry.fact,
        );
      }).toList(growable: false);
      return workout.copyWith(exercises: entries, updatedAt: DateTime.now());
    }).toList(growable: false);
    await _persist();
  }

  Future<void> addExerciseToWorkout(
    String workoutId, {
    required Exercise exercise,
  }) async {
    _workouts = _workouts.map((workout) {
      if (workout.id != workoutId) return workout;
      final nextEntry = WorkoutEntry(
        id: _uuid.v4(),
        exerciseId: exercise.id,
        status: WorkoutEntryStatus.pending,
        plan: const WorkoutPhase(),
        fact: null,
      );
      return workout.copyWith(
        exercises: [...workout.exercises, nextEntry],
        updatedAt: DateTime.now(),
      );
    }).toList(growable: false);
    await _persist();
  }

  Future<void> clearAll() async {
    _workouts = const [];
    _exercises = const [];
    _measurements = const [];
    await _persist();
  }

  String nextId() => _uuid.v4();

  bool get _hasRemoteSession =>
      _auth != null && _auth!.accessToken.trim().isNotEmpty;

  bool _snapshotHasData(AppSnapshot snapshot) {
    return snapshot.workouts.isNotEmpty ||
        snapshot.exercises.isNotEmpty ||
        snapshot.measurements.isNotEmpty;
  }

  void _applyRemote(SyncResponse remote) {
    _workouts = remote.workouts;
    _exercises = remote.exercises;
    _measurements = remote.measurements;
  }

  Future<void> _pullRemote() async {
    final session = _auth;
    if (session == null || session.accessToken.isEmpty) {
      return;
    }
    final remote = await api.fetchSync(accessToken: session.accessToken);
    _applyRemote(remote);
    await _persist(syncRemote: false);
  }

  Future<void> _pushRemote() async {
    final session = _auth;
    if (session == null || session.accessToken.isEmpty) {
      return;
    }
    final remote = await api.pushSync(
      accessToken: session.accessToken,
      workouts: _workouts,
      exercises: _exercises,
      measurements: _measurements,
    );
    _applyRemote(remote);
  }

  Future<void> _persist({bool syncRemote = true}) async {
    await storage.save(
      AppSnapshot(
        workouts: _workouts,
        exercises: _exercises,
        measurements: _measurements,
        auth: _auth,
      ),
    );

    if (syncRemote && _hasRemoteSession) {
      try {
        await _pushRemote();
        await storage.save(
          AppSnapshot(
            workouts: _workouts,
            exercises: _exercises,
            measurements: _measurements,
            auth: _auth,
          ),
        );
      } catch (_) {
        // Local snapshot stays available offline.
      }
    }

    notifyListeners();
  }
}
