/// =============================================================================
/// File: camera_api_integration_test.dart
/// Description: Integration tests for Camera API
///
/// Test camera CRUD operations và settings với server thật
/// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/camera/camera_api_service.dart';
import 'package:thermal_mobile/data/network/camera/dto/camera_dto.dart';
import '../config/test_client_factory.dart';
import '../config/test_config.dart';
import '../helpers/auth_helper.dart';
import '../helpers/report_helper.dart';

void main() {
  late CameraApiService service;
  late String accessToken;
  final List<TestResult> testResults = [];

  setUpAll(() async {
    print('\n${'=' * 80}');
    print('📷 CAMERA API INTEGRATION TESTS');
    print('Base URL: ${IntegrationTestConfig.baseUrl}');
    print('=' * 80 + '\n');

    service = CameraApiService(
      TestClientFactory.createApiClient(),
      TestClientFactory.createBaseUrlProvider(),
    );

    // Get access token (login tự động)
    accessToken = await AuthHelper.getAccessToken();
  });

  tearDownAll(() async {
    // Tạo báo cáo tổng hợp sau khi chạy xong tất cả test
    await ReportHelper.createSummaryReport(
      groupName: 'camera_api',
      groupDescription: '''
# API Quản Lý Camera (Camera API)

## Mục đích
Nhóm API này phục vụ cho việc quản lý camera trong hệ thống giám sát nhiệt độ.

## Chức năng chính
- CRUD operations cho camera
- Quản lý cài đặt camera
- Pin/unpin camera yêu thích
- Lọc camera theo khu vực và loại

## Ứng dụng
- Quản lý danh sách camera
- Hiển thị camera theo khu vực
- Cài đặt camera ưa thích
      ''',
      results: testResults,
    );
  });

  group('Camera API - Read Operations', () {
    test(
      'getAll - should fetch all cameras with full details',
      () async {
        final stopwatch = Stopwatch()..start();

        print('\n${'─' * 60}');
        print('📷 TEST: getAll cameras');
        print('─' * 60);

        final result = await service.getAll(
          areaId: 5,
          accessToken: accessToken,
        );

        stopwatch.stop();

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final cameras = result.data!;
          print('\n📸 Camera Statistics:');
          print('  Total Cameras: ${cameras.length}');

          if (cameras.isNotEmpty) {
            // Group by camera type
            final typeGroups = <CameraType, int>{};
            final areaGroups = <int, int>{};

            for (var camera in cameras) {
              if (camera.cameraType != null) {
                typeGroups[camera.cameraType!] =
                    (typeGroups[camera.cameraType!] ?? 0) + 1;
              }

              if (camera.areaId != null) {
                areaGroups[camera.areaId!] =
                    (areaGroups[camera.areaId!] ?? 0) + 1;
              }
            }

            print('\n  By Type:');
            typeGroups.forEach((type, count) {
              print('    ${type.name}: $count');
            });

            print('\n  By Area:');
            print('    Total Areas: ${areaGroups.length}');

            // Sample camera details
            final firstCamera = cameras.first;
            print('\n  Sample Camera:');
            print('    ID: ${firstCamera.id}');
            print('    Name: ${firstCamera.name}');
            print('    Type: ${firstCamera.cameraType?.name ?? "N/A"}');
            print('    Stream URL: ${firstCamera.streamUrl}');
            print('    Status: ${firstCamera.status.name}');
            if (firstCamera.monitorPoints != null) {
              print('    Monitor Points: ${firstCamera.monitorPoints!.length}');
            }
          }

          testResults.add(
            TestResult(
              testName: 'getAll',
              isSuccess: true,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
            ),
          );
        } else {
          print('\n❌ Error: ${result.error?.message}');
          print('Status Code: ${result.error?.statusCode}');

          testResults.add(
            TestResult(
              testName: 'getAll',
              isSuccess: false,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
              errorMessage: result.error?.message,
            ),
          );
        }

        print('⏱️  Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getAllShorten - should fetch shortened camera list',
      () async {
        final stopwatch = Stopwatch()..start();

        print('\n${'─' * 60}');
        print('📋 TEST: getAllShorten cameras');
        print('─' * 60);

        final result = await service.getAllShorten(accessToken: accessToken);

        stopwatch.stop();

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        Map<String, dynamic> reportData = {};

        if (result.isSuccess && result.data != null) {
          final cameras = result.data!;
          print('\n📸 Shortened List:');
          print('  Total Cameras: ${cameras.length}');

          if (cameras.isNotEmpty) {
            print('\n  First 5 cameras:');
            for (var i = 0; i < cameras.length && i < 5; i++) {
              final camera = cameras[i];
              print('    ${i + 1}. [${camera.id}] ${camera.name}');
            }
          }

          expect(cameras, isNotEmpty);

          testResults.add(
            TestResult(
              testName: 'getAllShorten',
              isSuccess: true,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
            ),
          );
        } else {
          print('\n❌ Error: ${result.error?.message}');

          testResults.add(
            TestResult(
              testName: 'getAllShorten',
              isSuccess: false,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
              errorMessage: result.error?.message,
            ),
          );
        }

        print('⏱️  Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getList - should fetch paginated camera list',
      () async {
        final stopwatch = Stopwatch()..start();

        print('\n${'─' * 60}');
        print('📃 TEST: getList cameras (paginated)');
        print('─' * 60);

        final result = await service.getList(
          accessToken: accessToken,
          page: 1,
          pageSize: 10,
        );

        stopwatch.stop();

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        Map<String, dynamic> reportData = {};

        if (result.isSuccess && result.data != null) {
          final paging = result.data!;
          print('\n📄 Pagination Info:');
          print('  Current Page: ${paging.currentPage}');
          print('  Page Size: ${paging.pageSize}');
          print('  Total Records: ${paging.totalRecords}');
          print('  Total Pages: ${paging.totalPages}');
          print('  Has Next: ${paging.hasNextPage}');
          print('  Has Previous: ${paging.hasPreviousPage}');

          print('\n📸 Cameras on Page 1:');
          for (var i = 0; i < paging.data.length; i++) {
            final camera = paging.data[i];
            print(
              '    ${i + 1}. [${camera.id}] ${camera.name} (${camera.cameraType?.name ?? "N/A"})',
            );
          }

          expect(paging.totalRecords, greaterThan(0));
          expect(paging.data, isNotEmpty);

          testResults.add(
            TestResult(
              testName: 'getList',
              isSuccess: true,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
            ),
          );
        } else {
          print('\n❌ Error: ${result.error?.message}');

          testResults.add(
            TestResult(
              testName: 'getList',
              isSuccess: false,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
              errorMessage: result.error?.message,
            ),
          );
        }

        print('⏱️  Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getById - should fetch camera by ID',
      () async {
        // First get a camera ID
        final allResult = await service.getAllShorten(accessToken: accessToken);

        if (!allResult.isSuccess || allResult.data?.isEmpty == true) {
          print('⏭️  Skipping getById test (no cameras available)');
          return;
        }

        final firstCameraId = allResult.data!.first.id;

        final stopwatch = Stopwatch()..start();

        print('\n${'─' * 60}');
        print('🔍 TEST: getById camera');
        print('─' * 60);
        print('Camera ID: $firstCameraId');

        final result = await service.getById(
          id: firstCameraId,
          accessToken: accessToken,
        );

        stopwatch.stop();

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        Map<String, dynamic> reportData = {};

        if (result.isSuccess && result.data != null) {
          final camera = result.data!;
          print('\n📸 Camera Details:');
          print('  ID: ${camera.id}');
          print('  Name: ${camera.name}');
          print('  Type: ${camera.cameraType?.name ?? "N/A"}');
          print('  Stream URL: ${camera.streamUrl}');
          print('  Status: ${camera.status.name}');
          print('  Area ID: ${camera.areaId}');
          print('  Created At: ${camera.createdAt}');
          print('  Updated At: ${camera.updatedAt}');

          if (camera.monitorPoints != null) {
            print('  Monitor Points: ${camera.monitorPoints!.length}');
          }

          testResults.add(
            TestResult(
              testName: 'getById',
              isSuccess: true,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
            ),
          );
        } else {
          print('\n❌ Error: ${result.error?.message}');

          testResults.add(
            TestResult(
              testName: 'getById',
              isSuccess: false,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
              errorMessage: result.error?.message,
            ),
          );
        }

        print('⏱️  Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );
  });

  group('Camera API - Settings Operations', () {
    test(
      'getSettings - should fetch camera settings',
      () async {
        final stopwatch = Stopwatch()..start();

        print('\n${'─' * 60}');
        print('⚙️  TEST: getSettings');
        print('─' * 60);

        final result = await service.getSettings(accessToken: accessToken);

        stopwatch.stop();

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final settings = result.data!;
          print('\n⚙️  Camera Settings:');
          print('  ID: ${settings.id}');
          print('  User ID: ${settings.userId}');
          print('  Pinned Camera IDs: ${settings.pinnedCameraIds}');
          print('  Total Pinned: ${settings.pinnedCameraIds?.length ?? 0}');

          testResults.add(
            TestResult(
              testName: 'getSettings',
              isSuccess: true,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
            ),
          );
        } else {
          print('\n❌ Error: ${result.error?.message}');

          testResults.add(
            TestResult(
              testName: 'getSettings',
              isSuccess: false,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
              errorMessage: result.error?.message,
            ),
          );
        }

        print('⏱️  Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getPinnedCameras - should fetch pinned cameras',
      () async {
        final stopwatch = Stopwatch()..start();

        print('\n${'─' * 60}');
        print('📌 TEST: getPinnedCameras');
        print('─' * 60);

        final result = await service.getPinnedCameras(accessToken: accessToken);

        stopwatch.stop();

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final pinnedCameras = result.data!;
          print('\n📌 Pinned Cameras:');
          print('  Total Pinned: ${pinnedCameras.length}');

          if (pinnedCameras.isNotEmpty) {
            print('\n  Cameras:');
            for (var i = 0; i < pinnedCameras.length; i++) {
              final camera = pinnedCameras[i];
              print('    ${i + 1}. [${camera.id}] ${camera.name}');
            }
          } else {
            print('  No pinned cameras');
          }

          testResults.add(
            TestResult(
              testName: 'getPinnedCameras',
              isSuccess: true,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
            ),
          );
        } else {
          print('\n❌ Error: ${result.error?.message}');

          testResults.add(
            TestResult(
              testName: 'getPinnedCameras',
              isSuccess: false,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
              errorMessage: result.error?.message,
            ),
          );
        }

        print('⏱️  Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'saveFavourite - should pin/unpin camera',
      () async {
        // First get a camera ID to pin
        final allResult = await service.getAllShorten(accessToken: accessToken);

        if (!allResult.isSuccess || allResult.data?.isEmpty == true) {
          print('⏭️  Skipping saveFavourite test (no cameras available)');
          return;
        }

        final firstCameraId = allResult.data!.first.id;

        final stopwatch = Stopwatch()..start();

        print('\n${'─' * 60}');
        print('⭐ TEST: saveFavourite (pin camera)');
        print('─' * 60);
        print('Camera ID: $firstCameraId');

        final result = await service.saveFavourite(
          request: FavouriteCameraRequest(
            cameraId: firstCameraId,
            isFavourite: true,
          ),
          accessToken: accessToken,
        );

        stopwatch.stop();

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final settings = result.data!;
          print('\n⭐ Updated Settings:');
          print('  Pinned Camera IDs: ${settings.pinnedCameraIds}');
          print(
            '  Is Pinned: ${settings.pinnedCameraIds?.contains(firstCameraId) ?? false}',
          );
          print('  Total Pinned: ${settings.pinnedCameraIds?.length ?? 0}');

          expect(settings.pinnedCameraIds?.contains(firstCameraId), true);

          testResults.add(
            TestResult(
              testName: 'saveFavourite',
              isSuccess: true,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
            ),
          );
        } else {
          print('\n❌ Error: ${result.error?.message}');

          testResults.add(
            TestResult(
              testName: 'saveFavourite',
              isSuccess: false,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
              errorMessage: result.error?.message,
            ),
          );
        }

        print('⏱️  Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );
  });

  group('Camera API - Filter Operations', () {
    test(
      'getAll with area filter - should filter by areaId',
      () async {
        // First get all cameras to find a valid areaId
        final allResult = await service.getAll(
          accessToken: accessToken,
          includeMonitorPoints: false,
        );

        if (!allResult.isSuccess || allResult.data?.isEmpty == true) {
          print('⏭️  Skipping area filter test (no cameras available)');
          return;
        }

        final cameraWithArea = allResult.data!.firstWhere(
          (c) => c.areaId != null,
          orElse: () => allResult.data!.first,
        );

        if (cameraWithArea.areaId == null) {
          print('⏭️  Skipping area filter test (no cameras with areaId)');
          return;
        }

        final testAreaId = cameraWithArea.areaId!;

        final stopwatch = Stopwatch()..start();

        print('\n${'─' * 60}');
        print('🔍 TEST: getAll with area filter');
        print('─' * 60);
        print('Area ID: $testAreaId');

        final result = await service.getAll(
          accessToken: accessToken,
          areaId: testAreaId,
        );

        stopwatch.stop();

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final cameras = result.data!;
          print('\n📸 Filtered Cameras:');
          print('  Total in Area $testAreaId: ${cameras.length}');

          // Verify all cameras belong to the specified area
          final allInArea = cameras.every((c) => c.areaId == testAreaId);
          print('  All cameras in area: ${allInArea ? '✅' : '❌'}');

          expect(
            allInArea,
            true,
            reason: 'All cameras should be in the specified area',
          );

          testResults.add(
            TestResult(
              testName: 'getAll_area_filter',
              isSuccess: true,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
            ),
          );
        } else {
          print('\n❌ Error: ${result.error?.message}');

          testResults.add(
            TestResult(
              testName: 'getAll_area_filter',
              isSuccess: false,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
              errorMessage: result.error?.message,
            ),
          );
        }

        print('⏱️  Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getList with filters - should apply multiple filters',
      () async {
        final stopwatch = Stopwatch()..start();

        print('\n${'─' * 60}');
        print('🔍 TEST: getList with multiple filters');
        print('─' * 60);

        final result = await service.getList(
          accessToken: accessToken,
          page: 1,
          pageSize: 5,
          status: CommonStatus.active,
        );

        stopwatch.stop();

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final paging = result.data!;
          print('\n📸 Filtered Results:');
          print('  Total Active Cameras: ${paging.totalRecords}');
          print('  Cameras on Page: ${paging.data.length}');

          // Verify all cameras have active status
          if (paging.data.isNotEmpty) {
            final allActive = paging.data.every(
              (c) => c.status == CommonStatus.active,
            );
            print('  All cameras active: ${allActive ? '✅' : '❌'}');

            expect(allActive, true, reason: 'All cameras should be active');
          }

          testResults.add(
            TestResult(
              testName: 'getList_filters',
              isSuccess: true,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
            ),
          );
        } else {
          print('\n❌ Error: ${result.error?.message}');

          testResults.add(
            TestResult(
              testName: 'getList_filters',
              isSuccess: false,
              duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
              errorMessage: result.error?.message,
            ),
          );
        }

        print('⏱️  Duration: ${stopwatch.elapsedMilliseconds}ms');
        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );
  });
}
