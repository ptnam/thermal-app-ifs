/// =============================================================================
/// File: machine_repository_impl.dart
/// Description: Implementation of IMachineRepository interface
///
/// Purpose:
/// - Implements domain repository interface for machines
/// - Converts API responses to domain entities
/// - Handles errors and maps to ApiError
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/mappers/dto_mappers.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/domain/models/machine_entity.dart';
import '../../domain/repositories/machine_repository.dart';
import '../network/machine/machine_api_service.dart';

/// Implementation of [IMachineRepository] that uses [MachineApiService].
///
/// This repository handles:
/// - Machine CRUD operations
/// - Machine Type CRUD operations
/// - Machine Part CRUD operations (tree structure)
class MachineRepositoryImpl implements IMachineRepository {
  final MachineApiService _machineApiService;
  final Future<String> Function() _getAccessToken;

  MachineRepositoryImpl({
    required MachineApiService machineApiService,
    required Future<String> Function() getAccessToken,
  }) : _machineApiService = machineApiService,
       _getAccessToken = getAccessToken;

  // ─────────────────────────────────────────────────────────────────────────────
  // Machine Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, List<MachineEntity>>> getAllMachines({
    int? areaId,
    int? machineTypeId,
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getAll(
        accessToken: token,
        areaId: areaId,
        machineTypeId: machineTypeId,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response?.map((dto) => _shortenToMachineEntity(dto)).toList() ??
              [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get all machines: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, PagingResponse<MachineEntity>>> getMachineList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? areaId,
    int? machineTypeId,
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getList(
        accessToken: token,
        page: page,
        pageSize: pageSize,
        name: name,
        areaId: areaId,
        machineTypeId: machineTypeId,
        status: status != null ? _mapIntToCommonStatus(status) : null,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Right(
              PagingResponse<MachineEntity>(
                data: [],
                currentPage: 1,
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
          message: 'Failed to get machine list: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, MachineEntity>> getMachineById(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getById(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Machine not found', statusCode: 404),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get machine by id: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, MachineEntity>> createMachine(
    MachineEntity machine,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = machine.toDto();
      final result = await _machineApiService.create(
        machine: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Failed to create machine'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to create machine: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, MachineEntity>> updateMachine(
    int id,
    MachineEntity machine,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = machine.toDto();
      final result = await _machineApiService.update(
        id: id,
        machine: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Failed to update machine'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to update machine: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, void>> deleteMachine(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.delete(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (_) => const Right(null),
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to delete machine: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, List<MachineComponentEntity>>> getMachineComponents(
    int machineId,
  ) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getComponents(
        machineId: machineId,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response?.map((dto) => _shortenToComponentEntity(dto)).toList() ??
              [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get machine components: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Machine Type Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, List<MachineTypeEntity>>> getAllMachineTypes({
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getAllTypes(accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response
                  ?.map((dto) => _shortenToMachineTypeEntity(dto))
                  .toList() ??
              [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get all machine types: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, PagingResponse<MachineTypeEntity>>>
  getMachineTypeList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getTypeList(
        accessToken: token,
        page: page,
        pageSize: pageSize,
        name: name,
        status: status != null ? _mapIntToCommonStatus(status) : null,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Right(
              PagingResponse<MachineTypeEntity>(
                data: [],
                currentPage: 1,
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
          message: 'Failed to get machine type list: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, MachineTypeEntity>> getMachineTypeById(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getTypeById(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(
                message: 'Machine type not found',
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
          message: 'Failed to get machine type by id: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, MachineTypeEntity>> createMachineType(
    MachineTypeEntity machineType,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = machineType.toDto();
      final result = await _machineApiService.createType(
        machineType: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Failed to create machine type'),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to create machine type: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, MachineTypeEntity>> updateMachineType(
    int id,
    MachineTypeEntity machineType,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = machineType.toDto();
      final result = await _machineApiService.updateType(
        id: id,
        machineType: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Failed to update machine type'),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to update machine type: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, void>> deleteMachineType(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.deleteType(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (_) => const Right(null),
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to delete machine type: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Machine Part Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, List<MachinePartEntity>>> getAllMachineParts({
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getAllParts(
        machineTypeId: 0,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response
                  ?.map((dto) => _shortenToMachinePartEntity(dto))
                  .toList() ??
              [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get all machine parts: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, List<MachinePartEntity>>> getMachinePartTree() async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getPartsTree(
        machineTypeId: 0,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response?.map((dto) => dto.toEntity()).toList() ?? [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get machine part tree: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, MachinePartEntity>> getMachinePartById(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getPartById(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(
                message: 'Machine part not found',
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
          message: 'Failed to get machine part by id: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, MachinePartEntity>> createMachinePart(
    MachinePartEntity machinePart,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = machinePart.toDto();
      final result = await _machineApiService.createPart(
        machinePart: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Failed to create machine part'),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to create machine part: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, MachinePartEntity>> updateMachinePart(
    int id,
    MachinePartEntity machinePart,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = machinePart.toDto();
      final result = await _machineApiService.updatePart(
        id: id,
        machinePart: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Failed to update machine part'),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to update machine part: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, void>> deleteMachinePart(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.deletePart(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (_) => const Right(null),
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to delete machine part: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────────

  CommonStatus? _mapIntToCommonStatus(int status) {
    switch (status) {
      case 0:
        return CommonStatus.inactive;
      case 1:
        return CommonStatus.active;
      default:
        return null;
    }
  }

  MachineEntity _shortenToMachineEntity(ShortenBaseDto dto) {
    return MachineEntity(id: dto.id, name: dto.name);
  }

  MachineTypeEntity _shortenToMachineTypeEntity(ShortenBaseDto dto) {
    return MachineTypeEntity(id: dto.id, name: dto.name);
  }

  MachinePartEntity _shortenToMachinePartEntity(ShortenBaseDto dto) {
    return MachinePartEntity(id: dto.id, name: dto.name);
  }

  /// Note: MachineComponentEntity requires machineId, but ShortenBaseDto doesn't have it
  /// Caller should use context to provide machineId
  MachineComponentEntity _shortenToComponentEntity(
    ShortenBaseDto dto, {
    int machineId = 0,
  }) {
    return MachineComponentEntity(
      id: dto.id,
      name: dto.name,
      machineId: machineId,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Machine Settings Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, MachineSettingEntity>> getMachineSetting() async {
    try {
      final token = await _getAccessToken();
      final result = await _machineApiService.getMachineSetting(
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(
                message: 'Machine setting not found',
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
          message: 'Failed to get machine setting: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }
}
