/// =============================================================================
/// File: thermal_data_repository.dart
/// Description: Thermal data repository interface
///
/// Purpose:
/// - Define contract for thermal data operations
/// - Support dashboard and temperature monitoring
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/domain/models/thermal_data_entity.dart';

/// Repository interface for Thermal Data operations
abstract class IThermalDataRepository {
  /// Get dashboard summary
  Future<Either<ApiError, ThermalDashboardEntity>> getDashboard({
    int? areaId,
    int? machineId,
  });

  /// Get paginated thermal data list
  Future<Either<ApiError, PagingResponse<ThermalDataEntity>>>
  getThermalDataList({
    int page = 1,
    int pageSize = 10,
    int? machineComponentId,
    int? machineId,
    int? level,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Get thermal data by machine component
  Future<Either<ApiError, List<ThermalDataEntity>>> getThermalDataByComponent({
    required int machineComponentId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Get chart data for visualization
  Future<Either<ApiError, List<ThermalChartEntity>>> getChartData({
    required List<int> machineComponentIds,
    required DateTime fromDate,
    required DateTime toDate,
    String? interval, // 'minute', 'hour', 'day'
  });

  /// Get latest thermal data for a component
  Future<Either<ApiError, ThermalDataEntity>> getLatestData(
    int machineComponentId,
  );

  /// Get thermal data details for multiple components
  Future<Either<ApiError, ThermalDataMultiEntity>> getDetailThermalDataMulti({
    required int areaId,
    required List<int> machineIds,
    required List<int> machineComponentIds,
    required String reportDate,
    required String startDate,
    required String endDate,
    required int userId,
    int id = 0,
  });

  /// Get environment thermal data by area
  Future<Either<ApiError, EnvironmentThermalEntity>> getEnvironmentThermal({
    required int areaId,
  });
}
