

import 'package:thermal_mobile/domain/models/auth_tokens.dart';

abstract class AuthRepository {
  Future<void> save(AuthTokens tokens);

  Future<AuthTokens?> read();

  Future<void> clear();

  Future<bool> hasValidSession();

  /// Perform login against remote and persist tokens locally
  Future<void> login({required String username, required String password});

  /// Perform logout (remote best-effort) and clear local cache
  Future<void> logout();
}
