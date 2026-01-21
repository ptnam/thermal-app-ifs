/// =============================================================================
/// File: auth_api_integration_test.dart
/// Description: Integration tests for Auth API
/// 
/// Test authentication flow với server thật
/// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:thermal_mobile/data/network/auth/auth_api_service.dart';
import 'package:thermal_mobile/data/network/auth/dto/login_request_dto.dart';
import '../config/test_client_factory.dart';
import '../config/test_config.dart';

void main() {
  late AuthApiService service;

  setUpAll(() {
    print('\n${'=' * 80}');
    print('🔐 AUTH API INTEGRATION TESTS');
    print('Base URL: ${IntegrationTestConfig.baseUrl}');
    print('=' * 80 + '\n');
    
    service = AuthApiService(
      TestClientFactory.createApiClient(),
      TestClientFactory.createBaseUrlProvider(),
    );
  });

  group('Auth API - Real Server Tests', () {
    
    test('login - should authenticate and return tokens', () async {
      if (IntegrationTestConfig.skipAuthTests) {
        print('⏭️  Skipping auth test (skipAuthTests = true)');
        return;
      }
      
      print('\n${'─' * 60}');
      print('🔑 TEST: login');
      print('─' * 60);
      print('Username: ${IntegrationTestConfig.testUsername}');
      
      final result = await service.login(
        LoginRequestDto(
          username: IntegrationTestConfig.testUsername,
          password: IntegrationTestConfig.testPassword,
        ),
      );
      
      print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');
      
      if (result.isSuccess && result.data != null) {
        final tokens = result.data!;
        print('\n🎫 Token Details:');
        print('  Access Token: ${tokens.accessToken.substring(0, 30)}...');
        if (tokens.refreshToken.isNotEmpty) {
          print('  Refresh Token: ${tokens.refreshToken.substring(0, 30)}...');
        }
        print('  Token Type: ${tokens.tokenType}');
        print('  Expires In: ${tokens.expiresIn}s');
        
        // Verify token structure
        expect(tokens.accessToken, isNotEmpty);
        expect(tokens.tokenType, isNotEmpty);
        expect(tokens.expiresIn, greaterThan(0));
      } else {
        print('\n❌ Error: ${result.error?.message}');
        print('Status Code: ${result.error?.statusCode}');
        print('\n⚠️  Kiểm tra:');
        print('  1. Username/password trong test_config.dart');
        print('  2. Server đang chạy: ${IntegrationTestConfig.baseUrl}');
        print('  3. Network connection');
      }
      
      print('─' * 60 + '\n');
      
      expect(result.isSuccess, true, 
        reason: 'Login should succeed with valid credentials');
      expect(result.data?.accessToken, isNotEmpty,
        reason: 'Access token should not be empty');
      
    }, timeout: Timeout(IntegrationTestConfig.testTimeout));

    test('login with wrong password - should fail', () async {
      if (IntegrationTestConfig.skipAuthTests) {
        print('⏭️  Skipping auth test (skipAuthTests = true)');
        return;
      }
      
      print('\n${'─' * 60}');
      print('🚫 TEST: login with wrong password');
      print('─' * 60);
      
      final result = await service.login(
        LoginRequestDto(
          username: IntegrationTestConfig.testUsername,
          password: 'wrong_password_12345',
        ),
      );
      
      print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED (as expected)'}');
      
      if (!result.isSuccess) {
        print('Error (expected): ${result.error?.message}');
        print('Status Code: ${result.error?.statusCode}');
      }
      
      print('─' * 60 + '\n');
      
      expect(result.isSuccess, false,
        reason: 'Login should fail with wrong password');
      expect(result.error, isNotNull,
        reason: 'Error should be present');
      
    }, timeout: Timeout(IntegrationTestConfig.testTimeout));

    test('logout - should invalidate token', () async {
      if (IntegrationTestConfig.skipAuthTests) {
        print('⏭️  Skipping auth test (skipAuthTests = true)');
        return;
      }
      
      print('\n${'─' * 60}');
      print('🚪 TEST: logout');
      print('─' * 60);
      
      // First login to get a token
      final loginResult = await service.login(
        LoginRequestDto(
          username: IntegrationTestConfig.testUsername,
          password: IntegrationTestConfig.testPassword,
        ),
      );
      
      if (!loginResult.isSuccess) {
        print('❌ Cannot test logout: login failed');
        print('─' * 60 + '\n');
        return;
      }
      
      final token = loginResult.data!.accessToken;
      print('Got token: ${token.substring(0, 20)}...');
      
      // Now logout
      final logoutResult = await service.logout(accessToken: token);
      
      print('\n📊 RESULT: ${logoutResult.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');
      
      if (!logoutResult.isSuccess) {
        print('Error: ${logoutResult.error?.message}');
      }
      
      print('─' * 60 + '\n');
      
      expect(logoutResult.isSuccess, true,
        reason: 'Logout should succeed');
      
    }, timeout: Timeout(IntegrationTestConfig.testTimeout));
  });
}
