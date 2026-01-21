/// =============================================================================
/// File: auth_helper.dart
/// Description: Helper for authentication in integration tests
///
/// Purpose:
/// - Quản lý access token cho integration tests
/// - Login tự động và cache token
/// - Tái sử dụng token cho nhiều tests
/// =============================================================================

import 'package:thermal_mobile/data/network/auth/auth_api_service.dart';
import 'package:thermal_mobile/data/network/auth/dto/login_request_dto.dart';
import '../config/test_client_factory.dart';
import '../config/test_config.dart';

/// Helper để xử lý authentication trong integration tests
/// 
/// Cách hoạt động:
/// 1. Lần đầu gọi getAccessToken() -> Login và cache token
/// 2. Các lần sau -> Trả về cached token (không login lại)
/// 3. Nếu token hết hạn -> Gọi clearToken() rồi getAccessToken() để login lại
class AuthHelper {
  // Singleton instances
  static AuthApiService? _authService;
  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;
  
  /// Get AuthApiService instance (singleton)
  static AuthApiService get authService {
    _authService ??= AuthApiService(
      TestClientFactory.createApiClient(),
      TestClientFactory.createBaseUrlProvider(),
    );
    return _authService!;
  }
  
  /// Lấy access token (login nếu chưa có)
  /// 
  /// Sử dụng trong setUpAll của test:
  /// ```dart
  /// setUpAll(() async {
  ///   accessToken = await AuthHelper.getAccessToken();
  /// });
  /// ```
  static Future<String> getAccessToken() async {
    // Nếu đã có token cached -> trả về luôn
    if (_cachedAccessToken != null) {
      print('ℹ️  Using cached access token');
      return _cachedAccessToken!;
    }
    
    // Chưa có token -> login
    print('\n${'=' * 60}');
    print('🔐 Logging in to get access token...');
    print('Username: ${IntegrationTestConfig.testUsername}');
    print('=' * 60);
    
    final result = await authService.login(
      LoginRequestDto(
        username: IntegrationTestConfig.testUsername,
        password: IntegrationTestConfig.testPassword,
      ),
    );
    
    if (result.isSuccess && result.data != null) {
      _cachedAccessToken = result.data!.accessToken;
      _cachedRefreshToken = result.data!.refreshToken;
      
      print('✅ Login successful!');
      print('Access Token: ${_cachedAccessToken!.substring(0, 30)}...');
      if (_cachedRefreshToken != null) {
        print('Refresh Token: ${_cachedRefreshToken!.substring(0, 30)}...');
      }
      print('Token Type: ${result.data!.tokenType}');
      print('Expires In: ${result.data!.expiresIn}s');
      print('=' * 60 + '\n');
      
      return _cachedAccessToken!;
    } else {
      final errorMsg = result.error?.message ?? 'Unknown error';
      print('\n❌ Login failed: $errorMsg');
      print('Status Code: ${result.error?.statusCode}');
      print('\n⚠️  Vui lòng kiểm tra:');
      print('  1. Username/password trong test/integration/config/test_config.dart');
      print('  2. Server có đang chạy: ${IntegrationTestConfig.baseUrl}');
      print('  3. Network connection');
      print('=' * 60 + '\n');
      
      throw Exception('Login failed: $errorMsg');
    }
  }
  
  /// Lấy refresh token (nếu có)
  static String? getRefreshToken() {
    return _cachedRefreshToken;
  }
  
  /// Clear cached token - dùng khi token hết hạn
  /// 
  /// ```dart
  /// AuthHelper.clearToken();
  /// accessToken = await AuthHelper.getAccessToken(); // Login lại
  /// ```
  static void clearToken() {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    print('🗑️  Cleared cached tokens');
  }
  
  /// Reset auth service - dùng khi cần tạo lại service
  static void reset() {
    clearToken();
    _authService = null;
    print('🔄 Reset auth service');
  }
}
