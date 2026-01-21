import 'hive_storage.dart';

/// User preferences stored in Hive
/// Example: how to reuse Hive for different data types
class UserPreferencesRepository {
  static const String _boxName = 'userPreferences';
  static const String _prefsKey = 'prefs';

  final HiveStorage _storage = HiveStorage(_boxName);

  /// Save user preferences (theme, language, notifications)
  Future<void> savePreferences({
    required String theme,
    required String language,
    required bool notificationsEnabled,
  }) async {
    await _storage.saveJson(_prefsKey, {
      'theme': theme,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
    });
  }

  /// Read user preferences from Hive
  Future<Map<String, dynamic>?> readPreferences() async {
    return _storage.readJson(_prefsKey);
  }

  /// Clear preferences
  Future<void> clearPreferences() async {
    await _storage.delete(_prefsKey);
  }
}
