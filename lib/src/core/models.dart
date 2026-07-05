import 'dart:convert';

import 'package:flutter/foundation.dart';

enum WorkoutType { strength, cardio }

enum WorkoutStatus { planned, active, completed, cancelled }

enum WorkoutEntryStatus { pending, done }

extension WorkoutTypeX on WorkoutType {
  String get label => this == WorkoutType.strength ? 'Силовая' : 'Кардио';

  static WorkoutType fromName(String? value) {
    return value == 'cardio' ? WorkoutType.cardio : WorkoutType.strength;
  }
}

extension WorkoutStatusX on WorkoutStatus {
  String get label => switch (this) {
        WorkoutStatus.planned => 'Запланирована',
        WorkoutStatus.active => 'Активна',
        WorkoutStatus.completed => 'Завершена',
        WorkoutStatus.cancelled => 'Отменена',
      };

  static WorkoutStatus fromName(String? value) {
    return WorkoutStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => WorkoutStatus.planned,
    );
  }
}

extension WorkoutEntryStatusX on WorkoutEntryStatus {
  static WorkoutEntryStatus fromName(String? value) {
    return value == 'done' ? WorkoutEntryStatus.done : WorkoutEntryStatus.pending;
  }
}

@immutable
class AuthSession {
  const AuthSession({
    required this.email,
    required this.isRegisterMode,
  });

  final String email;
  final bool isRegisterMode;

  Map<String, dynamic> toJson() => {
        'email': email,
        'isRegisterMode': isRegisterMode,
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      email: json['email'] as String? ?? '',
      isRegisterMode: json['isRegisterMode'] as bool? ?? false,
    );
  }
}

@immutable
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.archived,
  });

  final String id;
  final String name;
  final WorkoutType type;
  final String description;
  final bool archived;

  Exercise copyWith({
    String? id,
    String? name,
    WorkoutType? type,
    String? description,
    bool? archived,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      archived: archived ?? this.archived,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'description': description,
        'archived': archived,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: WorkoutTypeX.fromName(json['type'] as String?),
      description: json['description'] as String? ?? '',
      archived: json['archived'] as bool? ?? false,
    );
  }
}

@immutable
class WorkoutPhase {
  const WorkoutPhase({
    this.sets,
    this.weight,
    this.reps,
    this.note = '',
  });

  final int? sets;
  final double? weight;
  final int? reps;
  final String note;

  WorkoutPhase copyWith({
    int? sets,
    double? weight,
    int? reps,
    String? note,
  }) {
    return WorkoutPhase(
      sets: sets ?? this.sets,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'sets': sets,
        'weight': weight,
        'reps': reps,
        'note': note,
      };

  factory WorkoutPhase.fromJson(Map<String, dynamic> json) {
    return WorkoutPhase(
      sets: (json['sets'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      reps: (json['reps'] as num?)?.toInt(),
      note: json['note'] as String? ?? '',
    );
  }
}

@immutable
class WorkoutEntry {
  const WorkoutEntry({
    required this.id,
    required this.exerciseId,
    required this.status,
    required this.plan,
    required this.fact,
  });

  final String id;
  final String exerciseId;
  final WorkoutEntryStatus status;
  final WorkoutPhase? plan;
  final WorkoutPhase? fact;

  WorkoutEntry copyWith({
    String? id,
    String? exerciseId,
    WorkoutEntryStatus? status,
    WorkoutPhase? plan,
    WorkoutPhase? fact,
  }) {
    return WorkoutEntry(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      status: status ?? this.status,
      plan: plan ?? this.plan,
      fact: fact ?? this.fact,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseId': exerciseId,
        'status': status.name,
        'plan': plan?.toJson(),
        'fact': fact?.toJson(),
      };

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutEntry(
      id: json['id'] as String? ?? '',
      exerciseId: json['exerciseId'] as String? ?? json['exercise_id'] as String? ?? '',
      status: WorkoutEntryStatusX.fromName(json['status'] as String?),
      plan: json['plan'] is Map<String, dynamic>
          ? WorkoutPhase.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
      fact: json['fact'] is Map<String, dynamic>
          ? WorkoutPhase.fromJson(json['fact'] as Map<String, dynamic>)
          : null,
    );
  }
}

@immutable
class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.actualStartTime,
    required this.actualEndTime,
    required this.createdAt,
    required this.updatedAt,
    required this.exercises,
  });

  final String id;
  final String title;
  final WorkoutType type;
  final WorkoutStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WorkoutEntry> exercises;

  Workout copyWith({
    String? id,
    String? title,
    WorkoutType? type,
    WorkoutStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WorkoutEntry>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'status': status.name,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'scheduledStartTime': scheduledStartTime?.toIso8601String(),
        'scheduledEndTime': scheduledEndTime?.toIso8601String(),
        'actualStartTime': actualStartTime?.toIso8601String(),
        'actualEndTime': actualEndTime?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'exercises': exercises.map((item) => item.toJson()).toList(),
      };

  factory Workout.fromJson(Map<String, dynamic> json) {
    DateTime? parseOptionalDate(String key, [String? fallback]) {
      final raw = json[key] ?? (fallback == null ? null : json[fallback]);
      if (raw is! String || raw.isEmpty) {
        return null;
      }
      return DateTime.tryParse(raw);
    }

    return Workout(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: WorkoutTypeX.fromName(json['type'] as String?),
      status: WorkoutStatusX.fromName(json['status'] as String?),
      startTime: parseOptionalDate('startTime', 'start_time'),
      endTime: parseOptionalDate('endTime', 'end_time'),
      scheduledStartTime: parseOptionalDate('scheduledStartTime', 'scheduled_start_time'),
      scheduledEndTime: parseOptionalDate('scheduledEndTime', 'scheduled_end_time'),
      actualStartTime: parseOptionalDate('actualStartTime', 'actual_start_time'),
      actualEndTime: parseOptionalDate('actualEndTime', 'actual_end_time'),
      createdAt: parseOptionalDate('createdAt', 'created_at') ?? DateTime.now(),
      updatedAt: parseOptionalDate('updatedAt', 'updated_at') ?? DateTime.now(),
      exercises: (json['exercises'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(WorkoutEntry.fromJson)
          .toList(),
    );
  }
}

@immutable
class Measurement {
  const Measurement({
    required this.id,
    required this.title,
    required this.date,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    this.weight,
    this.bodyFat,
    this.chest,
    this.waist,
    this.belly,
    this.hips,
    this.arm,
    this.leg,
  });

  final String id;
  final String title;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? weight;
  final double? bodyFat;
  final double? chest;
  final double? waist;
  final double? belly;
  final double? hips;
  final double? arm;
  final double? leg;

  Measurement copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? weight,
    double? bodyFat,
    double? chest,
    double? waist,
    double? belly,
    double? hips,
    double? arm,
    double? leg,
  }) {
    return Measurement(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      belly: belly ?? this.belly,
      hips: hips ?? this.hips,
      arm: arm ?? this.arm,
      leg: leg ?? this.leg,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'weight': weight,
        'bodyFat': bodyFat,
        'chest': chest,
        'waist': waist,
        'belly': belly,
        'hips': hips,
        'arm': arm,
        'leg': leg,
      };

  factory Measurement.fromJson(Map<String, dynamic> json) {
    double? parseDouble(String key, [String? fallback]) {
      final raw = json[key] ?? (fallback == null ? null : json[fallback]);
      if (raw is num) return raw.toDouble();
      if (raw is String && raw.isNotEmpty) return double.tryParse(raw);
      return null;
    }

    DateTime parseDate(String key, [String? fallback]) {
      final raw = json[key] ?? (fallback == null ? null : json[fallback]);
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    return Measurement(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: parseDate('date'),
      note: json['note'] as String? ?? '',
      createdAt: parseDate('createdAt', 'created_at'),
      updatedAt: parseDate('updatedAt', 'updated_at'),
      weight: parseDouble('weight'),
      bodyFat: parseDouble('bodyFat', 'body_fat'),
      chest: parseDouble('chest'),
      waist: parseDouble('waist'),
      belly: parseDouble('belly'),
      hips: parseDouble('hips'),
      arm: parseDouble('arm'),
      leg: parseDouble('leg'),
    );
  }
}

@immutable
class AppSnapshot {
  const AppSnapshot({
    required this.workouts,
    required this.exercises,
    required this.measurements,
    required this.auth,
  });

  final List<Workout> workouts;
  final List<Exercise> exercises;
  final List<Measurement> measurements;
  final AuthSession? auth;

  String toEncodedJson() {
    return jsonEncode({
      'workouts': workouts.map((item) => item.toJson()).toList(),
      'exercises': exercises.map((item) => item.toJson()).toList(),
      'measurements': measurements.map((item) => item.toJson()).toList(),
      'auth': auth?.toJson(),
    });
  }

  factory AppSnapshot.fromEncodedJson(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return AppSnapshot(
      workouts: (json['workouts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Workout.fromJson)
          .toList(),
      exercises: (json['exercises'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Exercise.fromJson)
          .toList(),
      measurements: (json['measurements'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Measurement.fromJson)
          .toList(),
      auth: json['auth'] is Map<String, dynamic>
          ? AuthSession.fromJson(json['auth'] as Map<String, dynamic>)
          : null,
    );
  }
}
