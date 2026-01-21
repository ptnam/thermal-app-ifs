/// =============================================================================
/// File: thermal_data_api_integration_test.dart
/// Description: Integration tests for ThermalData API
///
/// Tests thực tế với server - call API thật để verify hoạt động
///
/// ⚠️ QUAN TRỌNG:
/// - Cần update username/password trong test/integration/config/test_config.dart
/// - Cần update test data IDs (areaId, machineId, etc.) theo dữ liệu thật
/// - Cần có network connection đến server
/// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/thermal_data/thermal_data_api_service.dart';
import '../config/test_client_factory.dart';
import '../config/test_config.dart';
import '../helpers/auth_helper.dart';

void main() {
  late ThermalDataApiService service;
  late String accessToken;

  setUpAll(() async {
    print('\n${'=' * 80}');
    print('🧪 THERMAL DATA API INTEGRATION TESTS');
    print('Base URL: ${IntegrationTestConfig.baseUrl}');
    print('=' * 80 + '\n');

    // Setup service
    service = ThermalDataApiService(
      TestClientFactory.createApiClient(),
      TestClientFactory.createBaseUrlProvider(),
    );

    // Get access token (login tự động)
    try {
      accessToken = await AuthHelper.getAccessToken();
    } catch (e) {
      print('❌ Failed to get access token: $e');
      rethrow;
    }
  });

  group('ThermalData API - Real Server Tests', () {
    test(
      'getMachineComponentPositionByArea - should fetch real data',
      () async {
        print('\n${'─' * 60}');
        print('📍 TEST: getMachineComponentPositionByArea');
        print('─' * 60);
        print('Area ID: ${IntegrationTestConfig.testAreaId}');

        final result = await service.getMachineComponentPositionByArea(
          areaId: IntegrationTestConfig.testAreaId,
          accessToken: accessToken,
        );

        // Log results
        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess) {
          print('Data count: ${result.data?.length ?? 0}');

          if (result.data != null && result.data!.isNotEmpty) {
            print('\n📦 Sample Data (First Component):');
            final first = result.data!.first;
            print('  ID: ${first.id}');
            print('  Name: ${first.name}');
            print('  Machine ID: ${first.machineId}');
            print('  Machine Name: ${first.machineName}');
            print('  Position: (${first.positionX}, ${first.positionY})');
            print('  Temperature Level: ${first.temperatureLevel?.name}');

            if (result.data!.length > 1) {
              print('\n... and ${result.data!.length - 1} more components');
            }
          } else {
            print('⚠️  No components found for this area');
          }
        } else {
          print('❌ Error: ${result.error?.message}');
          print('Status Code: ${result.error?.statusCode}');
        }

        print('─' * 60 + '\n');

        // Assertions
        expect(result.isSuccess, true, reason: 'API call should succeed');
        expect(result.data, isNotNull, reason: 'Data should not be null');
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getMachineAndLatestDataByArea - should fetch machines with thermal data',
      () async {
        print('\n${'─' * 60}');
        print('🏭 TEST: getMachineAndLatestDataByArea');
        print('─' * 60);
        print('Area ID: ${IntegrationTestConfig.testAreaId}');

        final result = await service.getMachineAndLatestDataByArea(
          areaId: IntegrationTestConfig.testAreaId,
          accessToken: accessToken,
        );

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final data = result.data!;
          print('Components count: ${data.components?.length ?? 0}');
          print('Thermal data keys: ${data.thermalDatas?.keys.length ?? 0}');

          if (data.components != null && data.components!.isNotEmpty) {
            print('\n📦 First Component:');
            final first = data.components!.first;
            print('  ID: ${first.id}');
            print('  Name: ${first.name}');
            print('  Machine: ${first.machineName}');
            print('  Position: (${first.positionX}, ${first.positionY})');
          }

          if (data.thermalDatas != null && data.thermalDatas!.isNotEmpty) {
            print('\n🌡️  Thermal Data:');
            data.thermalDatas!.forEach((key, thermalList) {
              print('  "$key": ${thermalList.length} readings');
              if (thermalList.isNotEmpty) {
                final first = thermalList.first;
                print(
                  '    Latest: ${first.temperature}°C at ${first.dataTime}',
                );
              }
            });
          }
        } else {
          print('❌ Error: ${result.error?.message}');
        }

        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getList - should fetch paginated thermal data',
      () async {
        print('\n${'─' * 60}');
        print('📋 TEST: getList (Paginated Data)');
        print('─' * 60);

        final fromTime = DateTime.now().subtract(const Duration(days: 7));
        final toTime = DateTime.now();

        print('From: ${fromTime.toIso8601String()}');
        print('To: ${toTime.toIso8601String()}');
        print('Page: 1, PageSize: 10');

        final result = await service.getList(
          fromTime: fromTime,
          toTime: toTime,
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
          print('Items in this page: ${paging.data.length}');

          if (paging.data.isNotEmpty) {
            print('\n🌡️  First Thermal Data:');
            final first = paging.data.first;
            print('  Machine: ${first.machineName}');
            print('  Component: ${first.machineComponentName}');
            print('  Monitor Point: ${first.monitorPointName}');
            print('  Temperature: ${first.temperature}°C');
            print('  Ambient: ${first.ambientTemperature}°C');
            print('  Delta: ${first.delta}°C');
            print('  Level: ${first.temperatureLevel?.name}');
            print('  Time: ${first.dataTime}');
          } else {
            print('⚠️  No thermal data found for this period');
          }
        } else {
          print('❌ Error: ${result.error?.message}');
        }

        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getListGrouped - should fetch grouped thermal data',
      () async {
        print('\n${'─' * 60}');
        print('📊 TEST: getListGrouped');
        print('─' * 60);

        final fromTime = DateTime.now().subtract(const Duration(days: 7));
        final toTime = DateTime.now();

        final result = await service.getListGrouped(
          fromTime: fromTime,
          toTime: toTime,
          accessToken: accessToken,
          page: 1,
          pageSize: 10,
        );

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final paging = result.data!;
          print('Total groups: ${paging.totalRecords}');
          print('Items in page: ${paging.data.length}');

          if (paging.data.isNotEmpty) {
            print('\n📦 First Group:');
            final first = paging.data.first;
            print('  Machine: ${first.machineName}');
            print('  Component: ${first.machineComponentName}');
            print('  Details count: ${first.details?.length ?? 0}');
          }
        } else {
          print('❌ Error: ${result.error?.message}');
        }

        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getEnvironmentThermal - should fetch environment data',
      () async {
        print('\n${'─' * 60}');
        print('🌤️  TEST: getEnvironmentThermal');
        print('─' * 60);
        print('Area ID: ${IntegrationTestConfig.testAreaId}');

        final result = await service.getEnvironmentThermal(
          areaId: IntegrationTestConfig.testAreaId,
          accessToken: accessToken,
        );

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final env = result.data!;
          print('Temperature: ${env.temperature}°C');
          print('Frequency: ${env.frequency}');
        } else {
          print('❌ Error: ${result.error?.message}');
        }

        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getLatestThermalByComponent - should fetch component thermal data',
      () async {
        print('\n${'─' * 60}');
        print('🔧 TEST: getLatestThermalByComponent');
        print('─' * 60);
        print('Machine ID: ${IntegrationTestConfig.testMachineId}');
        print('Component ID: ${IntegrationTestConfig.testComponentId}');
        print('Device Type: component');

        final result = await service.getLatestThermalByComponent(
          machineId: IntegrationTestConfig.testMachineId,
          id: IntegrationTestConfig.testComponentId,
          deviceType: DeviceType.component,
          accessToken: accessToken,
        );

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          print('Thermal data groups: ${result.data!.keys.length}');

          result.data!.forEach((key, thermalList) {
            print('\n📦 Group "$key": ${thermalList.length} readings');
            if (thermalList.isNotEmpty) {
              final first = thermalList.first;
              print(
                '  Latest: ${first.temperature}°C (${first.temperatureLevel?.name})',
              );
            }
          });
        } else {
          print('❌ Error: ${result.error?.message}');
          print(
            '⚠️  Note: Cần update testMachineId và testComponentId trong test_config.dart',
          );
        }

        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getDetailThermalData - should fetch chart data',
      () async {
        print('\n${'─' * 60}');
        print('📊 TEST: getDetailThermalData (Chart Data)');
        print('─' * 60);

        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        print('Machine ID: ${IntegrationTestConfig.testMachineId}');
        print('Component ID: ${IntegrationTestConfig.testComponentId}');
        print('Monitor Point ID: ${IntegrationTestConfig.testMonitorPointId}');
        print(
          'Period: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
        );

        final result = await service.getDetailThermalData(
          machineId: IntegrationTestConfig.testMachineId,
          machineComponentId: IntegrationTestConfig.testComponentId,
          monitorPointId: IntegrationTestConfig.testMonitorPointId,
          monitorPointType: MonitorPointType.sensor,
          startDate: startDate,
          endDate: endDate,
          accessToken: accessToken,
        );

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final chart = result.data!;
          print('Data points: ${chart.dataPoints?.length ?? 0}');
          print('Min value: ${chart.minValue}°C');
          print('Max value: ${chart.maxValue}°C');
          print('Avg value: ${chart.avgValue}°C');

          if (chart.dataPoints != null && chart.dataPoints!.isNotEmpty) {
            print('\n📈 First data point:');
            final first = chart.dataPoints!.first;
            print('  Time: ${first.time}');
            print('  Value: ${first.value}');
          }
        } else {
          print('❌ Error: ${result.error?.message}');
        }

        print('─' * 60 + '\n');

        expect(result.isSuccess, true);
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );

    test(
      'getDetailThermalDataMulti - should fetch multi-component chart data',
      () async {
        print('\n${'─' * 60}');
        print('📊 TEST: getDetailThermalDataMulti (Multi-Component Chart)');
        print('─' * 60);

        // Test data - adjust based on real data
        final areaId = 5;
        final machineIds = [3];
        final componentIds = [14, 15, 16];
        final reportDate = '2026-01-10';
        final startDate = '2026-01-08 00:00:00';
        final endDate = '2026-01-10 23:59:59';
        final userId = 1;

        print('Area ID: $areaId');
        print('Machine IDs: $machineIds');
        print('Component IDs: $componentIds');
        print('Report Date: $reportDate');
        print('Period: $startDate to $endDate');

        final result = await service.getDetailThermalDataMulti(
          areaId: areaId,
          machineIds: machineIds,
          machineComponentIds: componentIds,
          reportDate: reportDate,
          startDate: startDate,
          endDate: endDate,
          userId: userId,
          accessToken: accessToken,
        );

        print('\n📊 RESULT: ${result.isSuccess ? '✅ SUCCESS' : '❌ FAILED'}');

        if (result.isSuccess && result.data != null) {
          final data = result.data!;
          print('Categories (timestamps): ${data.categories.length}');
          print('Chart series: ${data.chartData.length}');

          if (data.categories.isNotEmpty) {
            print('\n⏰ Time Range:');
            print('  First: ${data.categories.first}');
            print('  Last: ${data.categories.last}');
          }

          if (data.chartData.isNotEmpty) {
            print('\n📈 Chart Series:');
            for (final series in data.chartData) {
              print('  ${series.name}: ${series.data.length} data points');
              if (series.data.isNotEmpty) {
                final min = series.data.reduce((a, b) => a < b ? a : b);
                final max = series.data.reduce((a, b) => a > b ? a : b);
                final avg =
                    series.data.reduce((a, b) => a + b) / series.data.length;
                print('    Min: ${min.toStringAsFixed(1)}°C');
                print('    Max: ${max.toStringAsFixed(1)}°C');
                print('    Avg: ${avg.toStringAsFixed(1)}°C');
              }
            }
          } else {
            print('⚠️  No chart data found');
          }
        } else {
          print('❌ Error: ${result.error?.message}');
          print(
            '⚠️  Note: Adjust areaId, machineIds, and componentIds for real data',
          );
        }

        print('─' * 60 + '\n');

        // Assertions
        expect(result.isSuccess, true, reason: 'API call should succeed');
        expect(
          result.data,
          isNotNull,
          reason: 'Response data should not be null',
        );

        // Note: Empty data is valid if there are no thermal readings for the period
        // Adjust test parameters (dates, IDs) if you need to test with actual data
        if (result.data != null) {
          print('✅ API response structure is valid');
          print('💡 TIP: If data is empty, check:');
          print('   - Are the machine/component IDs correct?');
          print('   - Is there data for the specified date range?');
          print('   - Try using data from a recent date with known readings');
        }
      },
      timeout: Timeout(IntegrationTestConfig.testTimeout),
    );
  });
}
