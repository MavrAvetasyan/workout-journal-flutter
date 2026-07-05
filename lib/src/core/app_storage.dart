import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppStorage {
  static const _snapshotKey = 'workout_journal_flutter_snapshot_v1';

  Future<AppSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) {
      return const AppSnapshot(
        workouts: [],
        exercises: [],
        measurements: [],
        auth: null,
      );
    }

    return AppSnapshot.fromEncodedJson(raw);
  }

  Future<void> save(AppSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_snapshotKey, snapshot.toEncodedJson());
  }
}
