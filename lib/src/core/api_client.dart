import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.email,
    required this.userId,
  });

  final String token;
  final String email;
  final String userId;
}

class LoginCodeRequestResponse {
  const LoginCodeRequestResponse({
    required this.expiresInSeconds,
    required this.nextRequestInSeconds,
    this.debugCode,
  });

  final int expiresInSeconds;
  final int nextRequestInSeconds;
  final String? debugCode;
}

class SyncResponse {
  const SyncResponse({
    required this.workouts,
    required this.exercises,
    required this.measurements,
  });

  final List<Workout> workouts;
  final List<Exercise> exercises;
  final List<Measurement> measurements;

  bool get isEmpty =>
      workouts.isEmpty && exercises.isEmpty && measurements.isEmpty;
}

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        baseUrl = baseUrl ?? _resolveBaseUrl();

  final http.Client _httpClient;
  final String baseUrl;

  static String _resolveBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    return 'http://10.0.2.2:8000/api';
  }

  Future<LoginCodeRequestResponse> requestLoginCode({
    required String email,
  }) async {
    final json = await _send(
      'POST',
      '/auth/request-code',
      body: {
        'email': email.trim().toLowerCase(),
      },
    );
    return LoginCodeRequestResponse(
      expiresInSeconds: (json['expires_in_seconds'] as num?)?.toInt() ?? 600,
      nextRequestInSeconds:
          (json['next_request_in_seconds'] as num?)?.toInt() ?? 30,
      debugCode: json['debug_code'] as String?,
    );
  }

  Future<AuthResponse> verifyLoginCode({
    required String email,
    required String code,
  }) async {
    final json = await _send(
      'POST',
      '/auth/verify-code',
      body: {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
      },
    );
    return _parseAuthResponse(json);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    final json = await _send(
      'POST',
      '/auth/register',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    return _parseAuthResponse(json);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _send(
      'POST',
      '/auth/login',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    return _parseAuthResponse(json);
  }

  Future<SyncResponse> fetchSync({
    required String accessToken,
  }) async {
    final json = await _send(
      'GET',
      '/sync',
      accessToken: accessToken,
    );
    return _parseSyncResponse(json);
  }

  Future<SyncResponse> pushSync({
    required String accessToken,
    required List<Workout> workouts,
    required List<Exercise> exercises,
    required List<Measurement> measurements,
  }) async {
    final json = await _send(
      'PUT',
      '/sync',
      accessToken: accessToken,
      body: {
        'workouts': workouts.map(_workoutToJson).toList(),
        'exercises': exercises.map(_exerciseToJson).toList(),
        'measurements': measurements.map(_measurementToJson).toList(),
      },
    );
    return _parseSyncResponse(json);
  }

  AuthResponse _parseAuthResponse(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return AuthResponse(
      token: json['access_token'] as String? ?? '',
      email: user['email'] as String? ?? '',
      userId: user['id'] as String? ?? '',
    );
  }

  SyncResponse _parseSyncResponse(Map<String, dynamic> json) {
    return SyncResponse(
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
    );
  }

  Map<String, dynamic> _exerciseToJson(Exercise exercise) {
    return {
      'id': exercise.id,
      'name': exercise.name,
      'type': exercise.type.name,
      'description': exercise.description,
      'archived': exercise.archived,
    };
  }

  Map<String, dynamic> _workoutPhaseToJson(WorkoutPhase? phase) {
    if (phase == null) {
      return {};
    }
    return {
      'sets': phase.sets,
      'weight': phase.weight,
      'reps': phase.reps,
      'note': phase.note,
    };
  }

  Map<String, dynamic> _workoutEntryToJson(WorkoutEntry entry) {
    return {
      'id': entry.id,
      'exercise_id': entry.exerciseId,
      'status': entry.status.name,
      'plan': entry.plan == null ? null : _workoutPhaseToJson(entry.plan),
      'fact': entry.fact == null ? null : _workoutPhaseToJson(entry.fact),
    };
  }

  Map<String, dynamic> _workoutToJson(Workout workout) {
    return {
      'id': workout.id,
      'title': workout.title,
      'type': workout.type.name,
      'status': workout.status.name,
      'start_time': workout.startTime?.toIso8601String(),
      'end_time': workout.endTime?.toIso8601String(),
      'scheduled_start_time': workout.scheduledStartTime?.toIso8601String(),
      'scheduled_end_time': workout.scheduledEndTime?.toIso8601String(),
      'actual_start_time': workout.actualStartTime?.toIso8601String(),
      'actual_end_time': workout.actualEndTime?.toIso8601String(),
      'created_at': workout.createdAt.toIso8601String(),
      'updated_at': workout.updatedAt.toIso8601String(),
      'exercises': workout.exercises.map(_workoutEntryToJson).toList(),
    };
  }

  Map<String, dynamic> _measurementToJson(Measurement measurement) {
    return {
      'id': measurement.id,
      'title': measurement.title,
      'date': measurement.date.toIso8601String().split('T').first,
      'note': measurement.note,
      'created_at': measurement.createdAt.toIso8601String(),
      'updated_at': measurement.updatedAt.toIso8601String(),
      'weight': measurement.weight,
      'body_fat': measurement.bodyFat,
      'chest': measurement.chest,
      'waist': measurement.waist,
      'belly': measurement.belly,
      'hips': measurement.hips,
      'arm': measurement.arm,
      'leg': measurement.leg,
    };
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    String? accessToken,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };

    late http.Response response;
    final encodedBody = body == null ? null : jsonEncode(body);

    switch (method) {
      case 'GET':
        response = await _httpClient.get(uri, headers: headers);
      case 'POST':
        response = await _httpClient.post(
          uri,
          headers: headers,
          body: encodedBody,
        );
      case 'PUT':
        response = await _httpClient.put(
          uri,
          headers: headers,
          body: encodedBody,
        );
      default:
        throw UnsupportedError('Unsupported method: $method');
    }

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        decoded['detail'] as String? ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }
}
