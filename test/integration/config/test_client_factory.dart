/// =============================================================================
/// File: test_client_factory.dart
/// Description: Factory to create API clients for integration tests
///
/// Purpose:
/// - Tạo Dio client với config phù hợp cho testing
/// - Tạo ApiClient, BaseUrlProvider
/// - Thêm logging interceptor để debug
/// =============================================================================

import 'package:dio/dio.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'test_config.dart';

class TestClientFactory {
  /// Tạo Dio instance với config test
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: IntegrationTestConfig.connectionTimeout,
        receiveTimeout: IntegrationTestConfig.receiveTimeout,
        // Không set baseUrl ở đây vì mỗi endpoint tự build full URL
      ),
    );
    
    // Add logging interceptor để xem request/response
    if (IntegrationTestConfig.printResponseData) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: IntegrationTestConfig.printHeaders,
          responseHeader: IntegrationTestConfig.printHeaders,
          error: true,
          logPrint: (obj) {
            // Format output đẹp hơn
            final str = obj.toString();
            if (str.length > 1000) {
              print('[DIO] ${str.substring(0, 1000)}...[truncated]');
            } else {
              print('[DIO] $str');
            }
          },
        ),
      );
    }
    
    return dio;
  }
  
  /// Tạo ApiClient instance
  static ApiClient createApiClient() {
    final dio = createDio();
    final logger = AppLogger(
      tag: 'IntegrationTest',
      enableLogging: true,
      enableLogBody: IntegrationTestConfig.printResponseData,
    );
    return ApiClient(dio, logger: logger);
  }
  
  /// Tạo BaseUrlProvider instance
  static BaseUrlProvider createBaseUrlProvider() {
    return StaticBaseUrlProvider(IntegrationTestConfig.baseUrl);
  }
}
