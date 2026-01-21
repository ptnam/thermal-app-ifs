/// =============================================================================
/// File: area_api_integration_test.dart
/// Description: Integration tests for Area API
/// 
/// Test area tree và camera data với server thật
/// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:thermal_mobile/data/network/area/area_api_service.dart';
import '../config/test_client_factory.dart';
import '../config/test_config.dart';
import '../helpers/auth_helper.dart';
import '../helpers/report_helper.dart';

void main() {
  late AreaApiService service;
  late String accessToken;
  final List<TestResult> testResults = [];

  setUpAll(() async {
    print('\n${'=' * 80}');
    print('🏢 AREA API INTEGRATION TESTS');
    print('Base URL: ${IntegrationTestConfig.baseUrl}');
    print('=' * 80 + '\n');
    
    service = AreaApiService(
      TestClientFactory.createApiClient(),
      TestClientFactory.createBaseUrlProvider(),
    );
    
    // Get access token (login tự động)
    accessToken = await AuthHelper.getAccessToken();
  });

  tearDownAll(() async {
    // Tạo báo cáo tổng hợp sau khi chạy xong tất cả test
    await ReportHelper.createSummaryReport(
      groupName: 'area_api',
      groupDescription: '''
# API Quản Lý Khu Vực (Area API)

## Mục đích
Nhóm API này phục vụ cho việc quản lý cấu trúc phân cấp các khu vực trong hệ thống giám sát nhiệt độ.

## Chức năng chính
- Lấy cây phân cấp khu vực (Area Tree) kèm camera
- Lấy danh sách tất cả khu vực
- Lấy danh sách khu vực có phân trang
- Lấy thông tin chi tiết một khu vực theo ID

## Ứng dụng
- Hiển thị cấu trúc tổ chức nhà máy/khu vực
- Điều hướng giữa các khu vực
- Quản lý camera theo khu vực
      ''',
      results: testResults,
    );
  });

  group('Area API - Real Server Tests', () {
    
    test('getAreaTreeWithCameras - should fetch area tree structure', () async {
      final stopwatch = Stopwatch()..start();
      
      print('\n${'─' * 60}');
      print('🌳 TEST: getAreaTreeWithCameras');
      print('─' * 60);
      
      final result = await service.getAreaAllTree(
        accessToken: accessToken,
      );
      
      stopwatch.stop();
      
      print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');
      
      // Chuẩn bị dữ liệu cho báo cáo
      Map<String, dynamic> reportData = {};
      
      if (result.isSuccess && result.data != null) {
        print('Root areas: ${result.data!.length}');
        
        int totalCameras = 0;
        int totalChildren = 0;
        
        for (var area in result.data!) {
          print('\n📍 Area: ${area.name} (ID: ${area.id})');
          print('   Map Type: ${area.mapType}');
          print('   Status: ${area.status}');
          print('   Cameras: ${area.cameras.length}');
          print('   Children: ${area.children.length}');
          
          totalCameras += area.cameras.length;
          totalChildren += area.children.length;
          
          // Log cameras
          if (area.cameras.isNotEmpty) {
            print('   └─ Camera details:');
            for (var camera in area.cameras.take(2)) {
              print('      • ${camera.name} (${camera.cameraType})');
            }
            if (area.cameras.length > 2) {
              print('      ... and ${area.cameras.length - 2} more');
            }
          }
          
          // Log first level children
          if (area.children.isNotEmpty) {
            print('   └─ Child areas:');
            for (var child in area.children.take(2)) {
              print('      • ${child.name} (ID: ${child.id})');
            }
            if (area.children.length > 2) {
              print('      ... and ${area.children.length - 2} more');
            }
          }
        }
        
        print('\n📊 Summary:');
        print('  Total root areas: ${result.data!.length}');
        print('  Total cameras: $totalCameras');
        print('  Total children: $totalChildren');
        
        // Lưu toàn bộ response vào báo cáo
        reportData = {
          'total_areas': result.data!.length,
          'total_cameras': totalCameras,
          'total_children': totalChildren,
          'response': result.data,
        };
        
      } else {
        print('❌ Error: ${result.error?.message}');
        print('Status Code: ${result.error?.statusCode}');
      }
      
      print('─' * 60 + '\n');
      
      // Tạo báo cáo
      await ReportHelper.createReport(
        groupName: 'area_api',
        testName: 'getAreaTreeWithCameras',
        description: '''
## Chức năng: Lấy Cây Phân Cấp Khu Vực

**Mô tả:** API này trả về cấu trúc cây phân cấp đầy đủ của tất cả các khu vực trong hệ thống, bao gồm cả thông tin camera được gắn với từng khu vực.

**Đầu vào:**
- Access Token (authentication)

**Đầu ra:**
- Danh sách các khu vực gốc (root areas)
- Mỗi khu vực bao gồm:
  - Thông tin cơ bản (ID, tên, loại bản đồ, trạng thái)
  - Danh sách camera
  - Danh sách khu vực con (children - đệ quy)

**Ứng dụng:**
- Hiển thị sơ đồ tổ chức nhà máy
- Navigation menu phân cấp
- Quản lý camera theo khu vực
        ''',
        isSuccess: result.isSuccess,
        requestInfo: {
          'endpoint': 'getAreaAllTree',
          'method': 'GET',
          'authentication': 'Bearer Token',
        },
        responseData: reportData,
        errorMessage: result.error?.message,
        duration: stopwatch.elapsed,
      );
      
      // Lưu kết quả test
      testResults.add(TestResult(
        testName: 'getAreaTreeWithCameras',
        isSuccess: result.isSuccess,
        duration: stopwatch.elapsed,
        errorMessage: result.error?.message,
      ));
      
      expect(result.isSuccess, true,
        reason: 'API call should succeed');
      expect(result.data, isNotNull,
        reason: 'Area tree data should not be null');
      
    }, timeout: Timeout(IntegrationTestConfig.testTimeout));

    test('getAllAreas - should fetch all areas (simplified)', () async {
      final stopwatch = Stopwatch()..start();
      
      print('\n${'─' * 60}');
      print('📋 TEST: getAllAreas');
      print('─' * 60);
      
      final result = await service.getAllAreas(
        accessToken: accessToken,
      );
      
      stopwatch.stop();
      
      print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');
      
      Map<String, dynamic> reportData = {};
      
      if (result.isSuccess && result.data != null) {
        print('Total areas: ${result.data!.length}');
        
        if (result.data!.isNotEmpty) {
          print('\n📦 Sample Areas:');
          for (var area in result.data!.take(5)) {
            print('  • ${area.name} (ID: ${area.id})');
          }
          if (result.data!.length > 5) {
            print('  ... and ${result.data!.length - 5} more');
          }
        }
        
        reportData = {
          'total_areas': result.data!.length,
          'sample_areas': result.data!.take(3).map((a) => {
            'id': a.id,
            'name': a.name,
          }).toList(),
        };
      } else {
        print('❌ Error: ${result.error?.message}');
      }
      
      print('─' * 60 + '\n');
      
      await ReportHelper.createReport(
        groupName: 'area_api',
        testName: 'getAllAreas',
        description: '''
## Chức năng: Lấy Tất Cả Khu Vực (Đơn giản)

**Mô tả:** API trả về danh sách phẳng (flat list) của tất cả các khu vực, không bao gồm cấu trúc phân cấp hay camera.

**Đầu vào:**
- Access Token

**Đầu ra:**
- Danh sách tất cả khu vực với thông tin cơ bản
- Không có cấu trúc cây, không có camera

**Ứng dụng:**
- Dropdown/Select box chọn khu vực
- Tìm kiếm nhanh khu vực
- Export danh sách khu vực
        ''',
        isSuccess: result.isSuccess,
        requestInfo: {
          'endpoint': 'getAllAreas',
          'method': 'GET',
        },
        responseData: reportData,
        errorMessage: result.error?.message,
        duration: stopwatch.elapsed,
      );
      
      testResults.add(TestResult(
        testName: 'getAllAreas',
        isSuccess: result.isSuccess,
        duration: stopwatch.elapsed,
        errorMessage: result.error?.message,
      ));
      
      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      
    }, timeout: Timeout(IntegrationTestConfig.testTimeout));

    test('getAreaList - should fetch paginated areas', () async {
      print('\n${'─' * 60}');
      print('📄 TEST: getAreaList (Paginated)');
      print('─' * 60);
      
      final result = await service.getAreaList(
        accessToken: accessToken,
        page: 1,
        pageSize: 10,
      );
      
      print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');
      
      if (result.isSuccess && result.data != null) {
        final paging = result.data!;
        print('Total records: ${paging.totalRecords}');
        print('Total pages: ${paging.totalPages}');
        print('Current page: ${paging.currentPage}');
        print('Items in page: ${paging.data.length}');
        
        if (paging.data.isNotEmpty) {
          print('\n📦 First Area:');
          final first = paging.data.first;
          print('  Name: ${first.name}');
          print('  Status: ${first.status.name}');
          print('  Level: ${first.level}');
          print('  Created: ${first.createdAt}');
        }
      } else {
        print('❌ Error: ${result.error?.message}');
      }
      
      print('─' * 60 + '\n');
      
      expect(result.isSuccess, true);
      
    }, timeout: Timeout(IntegrationTestConfig.testTimeout));

    test('getAreaById - should fetch single area', () async {
      print('\n${'─' * 60}');
      print('🔍 TEST: getAreaById');
      print('─' * 60);
      print('Area ID: ${IntegrationTestConfig.testAreaId}');
      
      final result = await service.getAreaById(
        id: IntegrationTestConfig.testAreaId,
        accessToken: accessToken,
      );
      
      print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');
      
      if (result.isSuccess && result.data != null) {
        final area = result.data!;
        print('\n📦 Area Details:');
        print('  ID: ${area.id}');
        print('  Name: ${area.name}');
        print('  Map Type: ${area.mapType}');
        print('  Status: ${area.status}');
        print('  Parent ID: ${area.parentId}');
        print('  Created At: ${area.createdAt}');
        print('  Updated At: ${area.updatedAt}');
      } else {
        print('❌ Error: ${result.error?.message}');
        print('⚠️  Cần update testAreaId trong test_config.dart');
      }
      
      print('─' * 60 + '\n');
      
      expect(result.isSuccess, true);
      
    }, timeout: Timeout(IntegrationTestConfig.testTimeout));
  });
}
