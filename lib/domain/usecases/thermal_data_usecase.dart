/// =============================================================================
/// File: thermal_data_usecase.dart
/// Description: Thermal data use cases
///
/// Purpose:
/// - Business logic for thermal data operations
/// - Orchestrates thermal data repository calls
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/domain/models/thermal_data_entity.dart';
import 'package:thermal_mobile/domain/repositories/thermal_data_repository.dart';

/// Use case for getting multi-component thermal data details
class GetDetailThermalDataMultiUseCase {
  final IThermalDataRepository _thermalDataRepository;

  GetDetailThermalDataMultiUseCase(this._thermalDataRepository);

  Future<Either<ApiError, ThermalDataMultiEntity>> call({
    required int areaId,
    required List<int> machineIds,
    required List<int> machineComponentIds,
    required String reportDate,
    required String startDate,
    required String endDate,
    required int userId,
    int id = 0,
  }) {
    return _thermalDataRepository.getDetailThermalDataMulti(
      areaId: areaId,
      machineIds: machineIds,
      machineComponentIds: machineComponentIds,
      reportDate: reportDate,
      startDate: startDate,
      endDate: endDate,
      userId: userId,
      id: id,
    );
  }
}

/// Use case for getting environment thermal data
class GetEnvironmentThermalUseCase {
  final IThermalDataRepository _thermalDataRepository;

  GetEnvironmentThermalUseCase(this._thermalDataRepository);

  Future<Either<ApiError, EnvironmentThermalEntity>> call({
    required int areaId,
  }) {
    return _thermalDataRepository.getEnvironmentThermal(areaId: areaId);
  }
}
