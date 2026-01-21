import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/logger/app_logger.dart';

/// Secure token storage interface (unified format for all backends)
abstract class TokenStorage {
  /// Save tokens as a map (backend handles serialization)
  Future<void> saveTokens(Map<String, dynamic> tokenData);

  /// Get tokens as a map
  Future<Map<String, dynamic>?> getTokens();

  /// Clear tokens
  Future<void> clearTokens();

  /// Check if tokens exist
  Future<bool> hasTokens();
}

/// Implementation using flutter_secure_storage (encrypted on device)
class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage;
  final AppLogger _logger;
  
  static const String _accessTokenKey = 'access_token_secure';
  static const String _refreshTokenKey = 'refresh_token_secure';
  static const String _tokenMetaKey = 'token_meta_secure';
  
  SecureTokenStorage({
    FlutterSecureStorage? storage,
    AppLogger? logger,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _logger = logger ?? AppLogger(tag: 'SecureTokenStorage');
  
  @override
  Future<void> saveTokens(Map<String, dynamic> tokenData) async {
    try {
      
      final accessToken = tokenData['accessToken'] as String? ?? '';
      final refreshToken = tokenData['refreshToken'] as String? ?? '';
      
      // Save tokens individually
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
        // Save metadata (timestamp) for token lifecycle tracking
        _storage.write(
          key: _tokenMetaKey,
          value: jsonEncode({
            'savedAt': DateTime.now().toIso8601String(),
            'hasAccessToken': true,
            'hasRefreshToken': true,
          }),
        ),
      ]);
      
      _logger.info('Tokens saved successfully');
    } catch (e, st) {
      _logger.error('Failed to save tokens', error: e, stackTrace: st);
      rethrow;
    }
  }
  
  @override
  Future<Map<String, dynamic>?> getTokens() async {
    try {
      
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      
      if (accessToken == null || refreshToken == null) {
        return null;
      }
      
      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } catch (e, st) {
      _logger.error('Failed to read tokens', error: e, stackTrace: st);
      rethrow;
    }
  }
  
  @override
  Future<void> clearTokens() async {
    try {
      
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _tokenMetaKey),
      ]);
      
      _logger.info('Tokens cleared successfully');
    } catch (e, st) {
      _logger.error('Failed to clear tokens', error: e, stackTrace: st);
      rethrow;
    }
  }
  
  @override
  Future<bool> hasTokens() async {
    try {
      final tokens = await getTokens();
      return tokens != null && tokens.isNotEmpty;
    } catch (e) {
      _logger.error('Failed to check if tokens exist', error: e);
      return false;
    }
  }
  
  /// Advanced: Check if tokens are expired or about to expire
  Future<bool> areTokensValid() async {
    try {
      final metaStr = await _storage.read(key: _tokenMetaKey);
      if (metaStr == null) return false;
      
      final meta = jsonDecode(metaStr) as Map<String, dynamic>;
      final savedAt = DateTime.tryParse(meta['savedAt'] as String? ?? '');
      
      if (savedAt == null) return false;
      
      // Tokens valid for 24 hours (adjust based on your API)
      final expirationTime = savedAt.add(const Duration(hours: 24));
      final isValid = DateTime.now().isBefore(expirationTime);
      
      if (!isValid) {
        _logger.info('Tokens expired, clearing from storage');
        await clearTokens();
      }
      
      return isValid;
    } catch (e) {
      _logger.error('Failed to validate tokens', error: e);
      return false;
    }
  }
}
