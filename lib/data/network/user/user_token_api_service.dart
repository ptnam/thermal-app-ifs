/// =============================================================================
/// File: user_token_api_service.dart
/// Description: API service for FCM token registration
///
/// Purpose:
/// - Send FCM device token to server for push notifications
/// - Register device for specific user to receive notifications
/// =============================================================================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';

/// Service for FCM user token API calls
///
/// Provides methods for:
/// - Registering FCM token with server
/// - Sending user device information for push notifications
class UserTokenApiService {
  UserTokenApiService(this._dio, this._baseUrlProvider, {AppLogger? logger})
    : _logger = logger ?? AppLogger(tag: 'UserTokenApiService');

  final Dio _dio;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  String get _baseUrl => _baseUrlProvider.apiBaseUrl;

  /// Post FCM token to server for user registration
  ///
  /// [userId] - The user ID to register token for
  /// [deviceType] - Device type: "android" or "ios"
  /// [token] - FCM device token
  /// [areaIds] - List of area IDs for notification subscription
  /// [isAdmin] - Whether user is admin
  /// [accessToken] - Auth access token
  ///
  /// Returns: true if registration successful, false otherwise
  Future<bool> postUserToken({
    required String userId,
    required String deviceType,
    required String token,
    List<String>? areaIds,
    required bool isAdmin,
    required String accessToken,
  }) async {
    try {
      _logger.info('🚀 UserToken API: Posting token to server...');
      _logger.info('👤 User ID: $userId');
      _logger.info('📱 Device Type: $deviceType');
      _logger.info(
        '🔑 FCM Token: ${token.isNotEmpty ? "Present (${token.length} chars)" : "Missing"}',
      );
      _logger.info('📍 Area IDs: ${areaIds ?? ["0"]}');
      _logger.info('👑 Is Admin: $isAdmin');

      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final response = await _dio.post(
        '$_baseUrl/api/Users/userToken',
        data: {
          'userId': userId,
          'deviceType': deviceType,
          'token': token,
          'areaIds': areaIds ?? ["0"],
          'isAdmin': isAdmin,
        },
        options: Options(headers: headers),
      );

      _logger.info('✅ UserToken API: Response received');
      _logger.info('📊 Status: ${response.statusCode}');
      _logger.info('📦 Data: ${response.data}');
      _logger.info('✅ body: ${response.data.toString()}');

      return response.statusCode == 200;
    } catch (e) {
      _logger.error('❌ UserToken API Error: $e');
      if (e is DioException) {
        _logger.error('🌐 Dio Error Details:');
        _logger.error('   - Type: ${e.type}');
        _logger.error('   - Message: ${e.message}');
        _logger.error('   - Response: ${e.response?.data}');
        _logger.error('   - Status Code: ${e.response?.statusCode}');
      }
      return false;
    }
  }

  // NOTE: Server không có DELETE API cho userToken
  // Server tự động clean up tokens không còn hoạt động

  /// Get device type string based on platform
  static String get currentDeviceType {
    return Platform.isAndroid ? 'android' : 'ios';
  }
}
