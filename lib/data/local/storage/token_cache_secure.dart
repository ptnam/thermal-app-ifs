import 'package:thermal_mobile/domain/models/auth_tokens.dart';
import '../../../core/logger/app_logger.dart';
import 'secure_token_storage.dart';

/// Generic cache interface for auth tokens (backend-agnostic)
abstract class ITokenCache {
  Future<void> save(AuthTokens tokens);
  Future<AuthTokens?> read();
  Future<void> clear();
  Future<bool> hasValidSession();
}

/// Local token cache adapter that works with any TokenStorage backend (Hive, SecureStorage, etc.)
class TokenCacheAdapter implements ITokenCache {
  final TokenStorage _storage;
  final AppLogger _logger;

  TokenCacheAdapter(this._storage, {AppLogger? logger})
      : _logger = logger ?? AppLogger(tag: 'TokenCacheAdapter');

  @override
  Future<void> save(AuthTokens tokens) async {
    try {
      
      await _storage.saveTokens({
        'accessToken': tokens.accessToken,
        'refreshToken': tokens.refreshToken,
        'tokenType': tokens.tokenType,
        'expiresIn': tokens.expiresIn,
      });
      _logger.info('Auth tokens saved');
    } catch (e, st) {
      _logger.error('Failed to save tokens', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<AuthTokens?> read() async {
    try {
      
      final tokenData = await _storage.getTokens();
      
      if (tokenData == null) {
        return null;
      }

      return AuthTokens(
        accessToken: tokenData['accessToken'] as String? ?? '',
        refreshToken: tokenData['refreshToken'] as String? ?? '',
        tokenType: tokenData['tokenType'] as String? ?? 'Bearer',
        expiresIn: tokenData['expiresIn'] as int? ?? 0,
      );
    } catch (e, st) {
      _logger.error('Failed to read tokens', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      
      await _storage.clearTokens();
      _logger.info('Auth tokens cleared');
    } catch (e, st) {
      _logger.error('Failed to clear tokens', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<bool> hasValidSession() async {
    try {
      final tokens = await read();
      final isValid = tokens?.hasValidAccessToken ?? false;
      
      return isValid;
    } catch (e) {
      _logger.error('Failed to check session', error: e);
      return false;
    }
  }
}

/// Backward compatibility alias (keep old name for minimal refactor)
typedef TokenCacheSecure = TokenCacheAdapter;
