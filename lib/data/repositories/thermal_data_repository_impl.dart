/// =============================================================================
/// File: thermal_data_repository_impl.dart
/// Description: Implementation of IThermalDataRepository interface
///
/// Purpose:
/// - Implements domain repository interface for thermal data
/// - Converts API responses to domain entities
/// - Handles errors and maps to ApiError
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/domain/models/thermal_data_entity.dart';
import '../../domain/repositories/thermal_data_repository.dart';
import '../network/thermal_data/thermal_data_api_service.dart';
import '../mappers/dto_mappers.dart';

/// Implementation of [IThermalDataRepository] that uses [ThermalDataApiService].
class ThermalDataRepositoryImpl implements IThermalDataRepository {
  final ThermalDataApiService _thermalDataApiService;
  final Future<String> Function() _getAccessToken;

  ThermalDataRepositoryImpl({
    required ThermalDataApiService thermalDataApiService,
    required Future<String> Function() getAccessToken,
  }) : _thermalDataApiService = thermalDataApiService,
       _getAccessToken = getAccessToken;

  // ─────────────────────────────────────────────────────────────────────────────
  // Dashboard Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, ThermalDashboardEntity>> getDashboard({
    int? areaId,
    int? machineId,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _thermalDataApiService.getMachineAndLatestDataByArea(
        areaId: areaId ?? 0,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Dashboard data not found'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get dashboard: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Thermal Data Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, PagingResponse<ThermalDataEntity>>>
  getThermalDataList({
    int page = 1,
    int pageSize = 10,
    int? machineComponentId,
    int? machineId,
    int? level,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final token = await _getAccessToken();
      final now = DateTime.now();
      final result = await _thermalDataApiService.getList(
        accessToken: token,
        page: page,
        pageSize: pageSize,
        machineId: machineId,
        machineComponentIds: machineComponentId != null
            ? [machineComponentId]
            : null,
        temperatureLevel: level != null
            ? _mapIntToTemperatureLevel(level)
            : null,
        fromTime: fromDate ?? now.subtract(const Duration(days: 7)),
        toTime: toDate ?? now,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Right(
              PagingResponse<ThermalDataEntity>(
                data: [],
                currentPage: page,
                pageSize: pageSize,
                totalRecords: 0,
                totalPages: 0,
              ),
            );
          }
          final entities = response.data.map((dto) => dto.toEntity()).toList();
          return Right(
            PagingResponse(
              data: entities,
              currentPage: response.currentPage,
              pageSize: response.pageSize,
              totalRecords: response.totalRecords,
              totalPages: response.totalPages,
            ),
          );
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get thermal data list: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, List<ThermalDataEntity>>> getThermalDataByComponent({
    required int machineComponentId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final token = await _getAccessToken();
      final now = DateTime.now();
      final result = await _thermalDataApiService.getList(
        accessToken: token,
        machineComponentIds: [machineComponentId],
        fromTime: fromDate ?? now.subtract(const Duration(days: 7)),
        toTime: toDate ?? now,
        page: 1,
        pageSize: 1000,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response?.data.map((dto) => dto.toEntity()).toList() ?? [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get thermal data by component: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, List<ThermalChartEntity>>> getChartData({
    required List<int> machineComponentIds,
    required DateTime fromDate,
    required DateTime toDate,
    String? interval,
  }) async {
    try {
      if (machineComponentIds.isEmpty) {
        return const Right([]);
      }

      final token = await _getAccessToken();
      final result = await _thermalDataApiService.getDetailThermalData(
        accessToken: token,
        machineId: 0,
        machineComponentId: machineComponentIds.first,
        monitorPointId: 0,
        monitorPointType: MonitorPointType.sensor,
        startDate: fromDate,
        endDate: toDate,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return const Right([]);
          }
          final entity = response.toEntity();
          return Right([entity]);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get chart data: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, ThermalDataEntity>> getLatestData(
    int machineComponentId,
  ) async {
    try {
      final token = await _getAccessToken();
      final now = DateTime.now();
      final result = await _thermalDataApiService.getList(
        accessToken: token,
        machineComponentIds: [machineComponentId],
        fromTime: now.subtract(const Duration(hours: 24)),
        toTime: now,
        page: 1,
        pageSize: 1,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null || response.data.isEmpty) {
            return Left(
              const ApiError(message: 'No thermal data found', statusCode: 404),
            );
          }
          return Right(response.data.first.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get latest data: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, ThermalDataMultiEntity>> getDetailThermalDataMulti({
    required int areaId,
    required List<int> machineIds,
    required List<int> machineComponentIds,
    required String reportDate,
    required String startDate,
    required String endDate,
    required int userId,
    int id = 0,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _thermalDataApiService.getDetailThermalDataMulti(
        areaId: areaId,
        machineIds: machineIds,
        machineComponentIds: machineComponentIds,
        reportDate: reportDate,
        startDate: startDate,
        endDate: endDate,
        userId: userId,
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(
                message: 'Multi thermal data not found',
                statusCode: 404,
              ),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get multi thermal data: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, EnvironmentThermalEntity>> getEnvironmentThermal({
    required int areaId,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _thermalDataApiService.getEnvironmentThermal(
        areaId: areaId,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(
                message: 'Environment thermal data not found',
                statusCode: 404,
              ),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get environment thermal data: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Map integer level to TemperatureLevel enum
  /// Values: 0=normal, 1=warning, 2=critical
  TemperatureLevel? _mapIntToTemperatureLevel(int level) {
    switch (level) {
      case 0:
        return TemperatureLevel.normal;
      case 1:
        return TemperatureLevel.warning;
      case 2:
        return TemperatureLevel.critical;
      default:
        return null;
    }
  }
}
