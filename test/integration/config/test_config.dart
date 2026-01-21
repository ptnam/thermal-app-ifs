/// =============================================================================
/// File: test_config.dart
/// Description: Test configuration for integration tests
/// 
/// Purpose:
/// - Centralized config for real API testing
/// - Credentials and base URLs
/// - Test data IDs
/// =============================================================================

class IntegrationTestConfig {
  // =========================================================================
  // BASE URL
  // =========================================================================
  static const String baseUrl = 'https://thermal.infosysvietnam.com.vn:10253';
  
  // =========================================================================
  // TEST CREDENTIALS - ⚠️ THAY ĐỔI THEO TÀI KHOẢN TEST CỦA BẠN
  // =========================================================================
  /// Username để login - thay đổi thành username thật của bạn
  static const String testUsername = 'thangdv'; // TODO: Đổi thành username test
  
  /// Password để login - thay đổi thành password thật của bạn
  static const String testPassword = '123456'; // TODO: Đổi thành password test
  
  // =========================================================================
  // TEST DATA IDs - ⚠️ THAY ĐỔI THEO DỮ LIỆU THẬT TRÊN SERVER
  // =========================================================================
  /// Area ID có dữ liệu để test
  static const int testAreaId = 1;
  
  /// Machine ID có dữ liệu để test
  static const int testMachineId = 1;
  
  /// Machine Component ID có dữ liệu để test
  static const int testComponentId = 1;
  
  /// Monitor Point ID có dữ liệu để test
  static const int testMonitorPointId = 1;
  
  // =========================================================================
  // TIMEOUTS
  // =========================================================================
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration testTimeout = Duration(seconds: 60);
  
  // =========================================================================
  // TEST FLAGS
  // =========================================================================
  /// In ra response data để debug
  static const bool printResponseData = true;
  
  /// In ra request/response headers
  static const bool printHeaders = false;
  
  /// Skip auth tests nếu đã có token
  static const bool skipAuthTests = false;
}
