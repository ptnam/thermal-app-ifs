
import 'package:thermal_mobile/domain/models/auth_tokens.dart';

import '../../../di/injection.dart' show getIt;
import 'hive_repository.dart';

class TokenCacheHive {
  static const String _tokensKey = 'tokens';

  HiveRepository<AuthTokens> get _repo => getIt<HiveRepository<AuthTokens>>();

  Future<void> save(AuthTokens tokens) async {
    await _repo.put(_tokensKey, tokens);
  }

  Future<AuthTokens?> read() async {
    return _repo.get(_tokensKey);
  }

  Future<void> clear() async {
    await _repo.delete(_tokensKey);
  }

  Future<bool> hasValidSession() async {
    final tokens = await read();
    return tokens?.hasValidAccessToken ?? false;
  }
}
