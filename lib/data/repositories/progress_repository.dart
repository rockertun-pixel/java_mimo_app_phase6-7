import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress_model.dart';

abstract interface class ProgressRepository {
  Future<UserProgressModel> load();
  Future<void> save(UserProgressModel progress);
}

class LocalProgressRepository implements ProgressRepository {
  const LocalProgressRepository();

  static const _key = 'user_progress_v2';
  static const _legacyKey = 'user_progress';

  @override
  Future<UserProgressModel> load() async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getString(_key);
    if (current != null) {
      try {
        return UserProgressModel.decode(current);
      } on FormatException {
        // Recover to an empty profile if local JSON was interrupted/corrupted.
        return UserProgressModel.empty();
      } on TypeError {
        return UserProgressModel.empty();
      }
    }

    final legacy = preferences.getString(_legacyKey);
    if (legacy == null) return UserProgressModel.empty();

    UserProgressModel migrated;
    try {
      // Missing new fields default to a full energy bar and a zero streak.
      migrated = UserProgressModel.decode(legacy);
    } on FormatException {
      migrated = UserProgressModel.empty();
    } on TypeError {
      migrated = UserProgressModel.empty();
    }

    await save(migrated);
    await preferences.remove(_legacyKey);
    return migrated;
  }

  @override
  Future<void> save(UserProgressModel progress) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, progress.encode());
  }
}
