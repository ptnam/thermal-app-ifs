import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/data/network/thermal_data/thermal_data_api_service.dart';
import 'package:thermal_mobile/domain/models/machine_thermal_entity.dart';
import 'package:thermal_mobile/domain/repositories/machine_thermal_repository.dart';
import 'package:thermal_mobile/data/mappers/machine_thermal_mapper.dart';

class MachineThermalRepositoryImpl implements IMachineThermalRepository {
  final ThermalDataApiService _apiService;
  final Future<String> Function() _getAccessToken;

  MachineThermalRepositoryImpl({
    required ThermalDataApiService thermalDataApiService,
    required Future<String> Function() getAccessToken,
  }) : _apiService = thermalDataApiService,
       _getAccessToken = getAccessToken;

  @override
  Future<Either<ApiError, AreaThermalOverviewEntity>> getAreaThermalOverview(
    int areaId,
  ) async {
    try {
      print(
        '🌐 MachineThermalRepo: Fetching thermal overview for areaId=$areaId',
      );
      final token = await _getAccessToken();
      if (token.isEmpty) {
        print('❌ MachineThermalRepo: No access token');
        return const Left(ApiError(message: 'No access token'));
      }

      // Step 1: Get machines list
      print('📡 MachineThermalRepo: Calling getMachinesAndResultByArea...');
      final machinesResult = await _apiService.getMachinesAndResultByArea(
        areaId: areaId,
        accessToken: token,
      );

      return machinesResult.fold(
        onFailure: (error) => Left(error),
        onSuccess: (data) async {
          print('📦 MachineThermalRepo: API response - data=$data');
          print('   item1 length: ${data?.item1.length ?? 0}');
          print('   item2 length: ${data?.item2.length ?? 0}');

          if (data == null || data.item1.isEmpty) {
            print('⚠️ MachineThermalRepo: No machines found in response');
            return const Right(AreaThermalOverviewEntity(machines: []));
          }

          print('🔍 MachineThermalRepo: Checking deviceTypes in item1:');
          for (var m in data.item1) {
            print('   - ${m.name}: deviceType="${m.deviceType}"');
          }

          final machines = data.item1
              .where((m) => m.deviceType == 'Machine')
              .toList();
          print(
            '🏭 MachineThermalRepo: Found ${machines.length} machines after filter (deviceType=="Machine")',
          );

          if (machines.isEmpty) {
            print(
              '❌ MachineThermalRepo: No machines with deviceType="Machine"',
            );
            return const Right(AreaThermalOverviewEntity(machines: []));
          }

          // Step 2: Fetch thermal data for each machine
          final List<MachineThermalSummaryEntity> summaries = [];

          for (final machine in machines) {
            try {
              print(
                '🌡️ MachineThermalRepo: Fetching thermal for machine ${machine.name} (id=${machine.machineId})',
              );
              final thermalResult = await _apiService.getThermalByComponent(
                machineId: machine.machineId,
                id: machine.id,
                deviceType: machine.deviceType,
                accessToken: token,
              );

              thermalResult.fold(
                onFailure: (error) {
                  // Skip machines with errors, log if needed
                  print(
                    'Error fetching thermal for machine ${machine.machineId}: ${error.message}',
                  );
                },
                onSuccess: (thermalData) {
                  if (thermalData != null) {
                    // Flatten all components from all keys
                    final List<ThermalComponentEntity> components = [];
                    thermalData.forEach((key, componentList) {
                      components.addAll(
                        componentList.map(
                          (dto) => MachineThermalMapper.toThermalEntity(dto),
                        ),
                      );
                    });

                    if (components.isNotEmpty) {
                      summaries.add(
                        MachineThermalSummaryEntity(
                          machine: MachineThermalMapper.toEntity(machine),
                          components: components,
                        ),
                      );
                    }
                  }
                },
              );
            } catch (e) {
              // Skip machine on error
              print(
                'Exception fetching thermal for machine ${machine.machineId}: $e',
              );
            }
          }

          return Right(AreaThermalOverviewEntity(machines: summaries));
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to fetch area thermal overview: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }
}
