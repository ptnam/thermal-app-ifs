/// =============================================================================
/// File: auth_repository_impl.dart
/// Description: Implementation of AuthRepository interface
///
/// Purpose:
/// - Implements domain repository interface for authentication
/// - Handles login, logout, token refresh operations
/// - Manages local token storage
/// =============================================================================

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thermal_mobile/core/services/session_expiration_service.dart';
import 'package:thermal_mobile/domain/models/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../network/auth/auth_api_service.dart';
import '../network/auth/dto/login_request_dto.dart';
import '../network/auth/dto/refresh_token_request_dto.dart';

/// Implementation of [AuthRepository] that uses [AuthApiService] and secure storage.
///
/// This repository handles:
/// - Login/Logout operations
/// - Token persistence (secure storage)
/// - Token refresh
/// - Session validation
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;
  final FlutterSecureStorage _secureStorage;
  Future<AuthTokens>? _refreshInFlight;

  // User-login token keys
  static const String _userAccessTokenKey = 'access_token';
  static const String _userRefreshTokenKey = 'refresh_token';
  static const String _userTokenTypeKey = 'token_type';
  static const String _userExpiresInKey = 'expires_in';

  // Legacy base token keys from the removed Firestore guest-login flow.
  static const String _baseAccessTokenKey = 'base_access_token';
  static const String _baseRefreshTokenKey = 'base_refresh_token';
  static const String _baseTokenTypeKey = 'base_token_type';
  static const String _baseExpiresInKey = 'base_expires_in';

  // Legacy active token mode key from the removed Firestore guest-login flow.
  static const String _activeTokenModeKey = 'active_token_mode';
  static const String _modeUser = 'user';

  AuthRepositoryImpl({
    required AuthApiService authApiService,
    FlutterSecureStorage? secureStorage,
  }) : _authApiService = authApiService,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ─────────────────────────────────────────────────────────────────────────────
  // Token Storage Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<void> save(AuthTokens tokens) async {
    await _clearLegacyBaseSession();
    await _writeTokens(
      accessTokenKey: _userAccessTokenKey,
      refreshTokenKey: _userRefreshTokenKey,
      tokenTypeKey: _userTokenTypeKey,
      expiresInKey: _userExpiresInKey,
      tokens: tokens,
    );
    await _secureStorage.write(key: _activeTokenModeKey, value: _modeUser);
  }

  @override
  Future<AuthTokens?> read() async {
    return _readTokens(
      accessTokenKey: _userAccessTokenKey,
      refreshTokenKey: _userRefreshTokenKey,
      tokenTypeKey: _userTokenTypeKey,
      expiresInKey: _userExpiresInKey,
    );
  }

  @override
  Future<void> clear() async {
    await _clearTokenGroup(
      accessTokenKey: _userAccessTokenKey,
      refreshTokenKey: _userRefreshTokenKey,
      tokenTypeKey: _userTokenTypeKey,
      expiresInKey: _userExpiresInKey,
    );
    await _clearTokenGroup(
      accessTokenKey: _baseAccessTokenKey,
      refreshTokenKey: _baseRefreshTokenKey,
      tokenTypeKey: _baseTokenTypeKey,
      expiresInKey: _baseExpiresInKey,
    );
    await _secureStorage.delete(key: _activeTokenModeKey);
  }

  @override
  Future<bool> hasValidSession() async {
    await _clearLegacyBaseSession();
    String accessToken;
    try {
      accessToken = await getAccessToken();
    } catch (_) {
      return false;
    }

    var result = await _authApiService.getProfile(accessToken: accessToken);

    if (result.isSuccess) {
      return true;
    }

    final statusCode = result.error?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      try {
        final refreshed = await refreshTokens();
        result = await _authApiService.getProfile(
          accessToken: refreshed.accessToken,
        );
        if (result.isSuccess) {
          return true;
        }
      } catch (_) {
        // Fall through to clear local session.
      }

      await clear();
    }

    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Authentication Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final tokens = await _loginRemote(username: username, password: password);
    await save(tokens);
  }

  @override
  Future<void> logout() async {
    try {
      final tokens = await read();
      if (tokens != null && tokens.hasValidAccessToken) {
        // Best-effort logout on remote - ignore errors
        await _authApiService.logout(accessToken: tokens.accessToken);
      }
    } catch (_) {
      // Ignore remote logout errors
    } finally {
      await _clearTokenGroup(
        accessTokenKey: _userAccessTokenKey,
        refreshTokenKey: _userRefreshTokenKey,
        tokenTypeKey: _userTokenTypeKey,
        expiresInKey: _userExpiresInKey,
      );
      await _clearLegacyBaseSession();
    }
  }

  @override
  Future<bool> isUserLoginActive() async {
    final userTokens = await _readTokens(
      accessTokenKey: _userAccessTokenKey,
      refreshTokenKey: _userRefreshTokenKey,
      tokenTypeKey: _userTokenTypeKey,
      expiresInKey: _userExpiresInKey,
    );
    return userTokens != null && userTokens.hasValidAccessToken;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Token Refresh
  // ─────────────────────────────────────────────────────────────────────────────

  /// Refresh access token using refresh token
  /// Returns new AuthTokens or throws if refresh fails
  Future<AuthTokens> refreshTokens() async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final refreshFuture = _refreshTokensInternal();
    _refreshInFlight = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<AuthTokens> _refreshTokensInternal() async {
    final currentTokens = await read();
    if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
      await _expireSession();
      throw Exception('No refresh token available');
    }

    final request = RefreshTokenRequestDto(
      accessToken: currentTokens.accessToken,
      refreshToken: currentTokens.refreshToken,
    );

    final result = await _authApiService.refreshToken(request);

    if (!result.isSuccess) {
      await _expireSession();
      throw Exception('Token refresh failed: ${result.error?.message}');
    }

    final tokensDto = result.data;
    if (tokensDto == null) {
      await _expireSession();
      throw Exception('Token refresh failed: No tokens received');
    }

    final tokens = AuthTokens(
      accessToken: tokensDto.accessToken,
      refreshToken: tokensDto.refreshToken,
      tokenType: tokensDto.tokenType,
      expiresIn: tokensDto.expiresIn,
    );

    await save(tokens);
    return tokens;
  }

  /// Get current access token, refreshing if needed
  @override
  Future<String> getAccessToken() async {
    final tokens = await read();
    if (tokens == null || !tokens.hasValidAccessToken) {
      throw Exception('Not authenticated');
    }

    if (_shouldRefreshAccessToken(tokens.accessToken)) {
      final refreshedTokens = await refreshTokens();
      return refreshedTokens.accessToken;
    }

    return tokens.accessToken;
  }

  Future<AuthTokens> _loginRemote({
    required String username,
    required String password,
  }) async {
    final request = LoginRequestDto(username: username, password: password);
    final result = await _authApiService.login(request);

    return result.fold(
      onFailure: (error) {
        throw Exception(error.message);
      },
      onSuccess: (tokensDto) {
        if (tokensDto == null) {
          throw Exception('Login failed: No tokens received');
        }
        return AuthTokens(
          accessToken: tokensDto.accessToken,
          refreshToken: tokensDto.refreshToken,
          tokenType: tokensDto.tokenType,
          expiresIn: tokensDto.expiresIn,
        );
      },
    );
  }

  Future<void> _writeTokens({
    required String accessTokenKey,
    required String refreshTokenKey,
    required String tokenTypeKey,
    required String expiresInKey,
    required AuthTokens tokens,
  }) async {
    await _secureStorage.write(key: accessTokenKey, value: tokens.accessToken);
    await _secureStorage.write(
      key: refreshTokenKey,
      value: tokens.refreshToken,
    );
    await _secureStorage.write(key: tokenTypeKey, value: tokens.tokenType);
    await _secureStorage.write(
      key: expiresInKey,
      value: tokens.expiresIn.toString(),
    );
  }

  Future<AuthTokens?> _readTokens({
    required String accessTokenKey,
    required String refreshTokenKey,
    required String tokenTypeKey,
    required String expiresInKey,
  }) async {
    final accessToken = await _secureStorage.read(key: accessTokenKey);
    final refreshToken = await _secureStorage.read(key: refreshTokenKey);
    final tokenType = await _secureStorage.read(key: tokenTypeKey);
    final expiresInStr = await _secureStorage.read(key: expiresInKey);

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
      tokenType: tokenType ?? 'Bearer',
      expiresIn: int.tryParse(expiresInStr ?? '0') ?? 0,
    );
  }

  Future<void> _clearTokenGroup({
    required String accessTokenKey,
    required String refreshTokenKey,
    required String tokenTypeKey,
    required String expiresInKey,
  }) async {
    await _secureStorage.delete(key: accessTokenKey);
    await _secureStorage.delete(key: refreshTokenKey);
    await _secureStorage.delete(key: tokenTypeKey);
    await _secureStorage.delete(key: expiresInKey);
  }

  Future<void> _clearLegacyBaseSession() async {
    await _clearTokenGroup(
      accessTokenKey: _baseAccessTokenKey,
      refreshTokenKey: _baseRefreshTokenKey,
      tokenTypeKey: _baseTokenTypeKey,
      expiresInKey: _baseExpiresInKey,
    );
    await _secureStorage.write(key: _activeTokenModeKey, value: _modeUser);
  }

  Future<void> _expireSession() async {
    await clear();
    notifySessionExpired();
  }

  bool _shouldRefreshAccessToken(String accessToken) {
    final expiresAt = _jwtExpiresAt(accessToken);
    if (expiresAt == null) {
      return false;
    }

    return DateTime.now().isAfter(
      expiresAt.subtract(const Duration(minutes: 1)),
    );
  }

  DateTime? _jwtExpiresAt(String accessToken) {
    final parts = accessToken.split('.');
    if (parts.length != 3) {
      return null;
    }

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);
      if (json is! Map<String, dynamic>) {
        return null;
      }

      final exp = json['exp'];
      final seconds = exp is int ? exp : int.tryParse(exp?.toString() ?? '');
      if (seconds == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } catch (_) {
      return null;
    }
  }
}
