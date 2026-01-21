import 'package:thermal_mobile/data/local/hive/hive_repository.dart';
import 'package:thermal_mobile/domain/models/auth_tokens.dart';
import '../../../core/logger/app_logger.dart';
import '../../../di/injection.dart' show getIt;

/// Hive-based token storage implementing the same interface as SecureTokenStorage
class HiveTokenStorage {
  final AppLogger _logger;

  static const String _tokensKey = 'authTokens';

  HiveTokenStorage({AppLogger? logger})
      : _logger = logger ?? AppLogger(tag: 'HiveTokenStorage');

  /// Save tokens as a map to Hive
  Future<void> saveTokens(Map<String, dynamic> tokenData) async {
    try {
      
      final repo = getIt<HiveRepository<AuthTokens>>();
      final tokens = AuthTokens(
        accessToken: tokenData['accessToken'] as String? ?? '',
        refreshToken: tokenData['refreshToken'] as String? ?? '',
        tokenType: 'Bearer',
        expiresIn: 0,
      );
      await repo.put(_tokensKey, tokens);
      _logger.info('Tokens saved to Hive');
    } catch (e, st) {
      _logger.error('Failed to save tokens to Hive', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Get tokens as a map from Hive
  Future<Map<String, dynamic>?> getTokens() async {
    try {
  final repo = getIt<HiveRepository<AuthTokens>>();
  final tokens = repo.get(_tokensKey);

      if (tokens == null) {
        return null;
      }

      return {
        'accessToken': tokens.accessToken,
        'refreshToken': tokens.refreshToken,
      };
    } catch (e, st) {
      _logger.error('Failed to read tokens from Hive', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Clear tokens from Hive
  Future<void> clearTokens() async {
    try {
  final repo = getIt<HiveRepository<AuthTokens>>();
  await repo.delete(_tokensKey);
      _logger.info('Tokens cleared from Hive');
    } catch (e, st) {
      _logger.error('Failed to clear tokens from Hive', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Check if tokens exist
  Future<bool> hasTokens() async {
    try {
      final tokens = await getTokens();
      return tokens != null && tokens.isNotEmpty;
    } catch (e) {
      _logger.error('Failed to check if tokens exist', error: e);
      return false;
    }
  }
}