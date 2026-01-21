/// Abstract interface for token storage (agnostic to backend: Hive, SecureStorage, SharedPreferences, etc.)
abstract class TokenStorage {
  /// Save token to storage
  Future<void> saveToken(String key, String value);

  /// Get token from storage
  Future<String?> getToken(String key);

  /// Delete token from storage
  Future<void> deleteToken(String key);

  /// Clear all tokens (typically used for logout)
  Future<void> clearAll();
}
