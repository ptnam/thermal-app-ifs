/// =============================================================================
/// File: auth_repository_impl.dart
/// Description: Implementation of AuthRepository interface
///
/// Purpose:
/// - Implements domain repository interface for authentication
/// - Handles login, logout, token refresh operations
/// - Manages local token storage
/// =============================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';

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
    await _secureStorage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: tokens.refreshToken,
    );
    await _secureStorage.write(key: _tokenTypeKey, value: tokens.tokenType);
    await _secureStorage.write(
      key: _expiresInKey,
      value: tokens.expiresIn.toString(),
    );
  }

  @override
  Future<AuthTokens?> read() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final tokenType = await _secureStorage.read(key: _tokenTypeKey);
    final expiresInStr = await _secureStorage.read(key: _expiresInKey);

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

  @override
  Future<void> clear() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenTypeKey);
    await _secureStorage.delete(key: _expiresInKey);
  }

  @override
  Future<bool> hasValidSession() async {
    final tokens = await read();
    return tokens != null && tokens.hasValidAccessToken;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Authentication Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final request = LoginRequestDto(username: username, password: password);

    final result = await _authApiService.login(request);

    await result.fold(
      onFailure: (error) {
        throw Exception(error.message);
      },
      onSuccess: (tokensDto) async {
        if (tokensDto == null) {
          throw Exception('Login failed: No tokens received');
        }

        final tokens = AuthTokens(
          accessToken: tokensDto.accessToken,
          refreshToken: tokensDto.refreshToken,
          tokenType: tokensDto.tokenType,
          expiresIn: tokensDto.expiresIn,
        );
        await save(tokens);
      },
    );
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
      // Always clear local tokens
      await clear();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Token Refresh
  // ─────────────────────────────────────────────────────────────────────────────

  /// Refresh access token using refresh token
  /// Returns new AuthTokens or throws if refresh fails
  Future<AuthTokens> refreshTokens() async {
    final currentTokens = await read();
    if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    final request = RefreshTokenRequestDto(
      accessToken: currentTokens.accessToken,
      refreshToken: currentTokens.refreshToken,
    );

    final result = await _authApiService.refreshToken(request);

    return result.fold(
      onFailure: (error) {
        throw Exception('Token refresh failed: ${error.message}');
      },
      onSuccess: (tokensDto) {
        if (tokensDto == null) {
          throw Exception('Token refresh failed: No tokens received');
        }

        final tokens = AuthTokens(
          accessToken: tokensDto.accessToken,
          refreshToken: tokensDto.refreshToken,
          tokenType: tokensDto.tokenType,
          expiresIn: tokensDto.expiresIn,
        );

        // Save new tokens
        save(tokens);

        return tokens;
      },
    );
  }

  /// Get current access token, refreshing if needed
  Future<String> getAccessToken() async {
    final tokens = await read();
    if (tokens == null || !tokens.hasValidAccessToken) {
      throw Exception('Not authenticated');
    }

    // TODO: Check token expiration and refresh if needed
    // For now, just return the current token
    return tokens.accessToken;
  }
}
