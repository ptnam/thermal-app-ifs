/// =============================================================================
/// File: machine_repository.dart
/// Description: Machine repository interface
///
/// Purpose:
/// - Define contract for machine, machine type, machine part operations
/// - Support machine monitoring features
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/domain/models/machine_entity.dart';

/// Repository interface for Machine operations
abstract class IMachineRepository {
  // ─────────────────────────────────────────────────────────────────────────
  // Machine Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all machines (for dropdowns)
  Future<Either<ApiError, List<MachineEntity>>> getAllMachines({
    int? areaId,
    int? machineTypeId,
    int? status,
  });

  /// Get paginated machine list
  Future<Either<ApiError, PagingResponse<MachineEntity>>> getMachineList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? areaId,
    int? machineTypeId,
    int? status,
  });

  /// Get machine by ID
  Future<Either<ApiError, MachineEntity>> getMachineById(int id);

  /// Create new machine
  Future<Either<ApiError, MachineEntity>> createMachine(MachineEntity machine);

  /// Update machine
  Future<Either<ApiError, MachineEntity>> updateMachine(
    int id,
    MachineEntity machine,
  );

  /// Delete machine
  Future<Either<ApiError, void>> deleteMachine(int id);

  /// Get machine components
  Future<Either<ApiError, List<MachineComponentEntity>>> getMachineComponents(
    int machineId,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Type Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all machine types
  Future<Either<ApiError, List<MachineTypeEntity>>> getAllMachineTypes({
    int? status,
  });

  /// Get paginated machine type list
  Future<Either<ApiError, PagingResponse<MachineTypeEntity>>>
  getMachineTypeList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? status,
  });

  /// Get machine type by ID
  Future<Either<ApiError, MachineTypeEntity>> getMachineTypeById(int id);

  /// Create machine type
  Future<Either<ApiError, MachineTypeEntity>> createMachineType(
    MachineTypeEntity machineType,
  );

  /// Update machine type
  Future<Either<ApiError, MachineTypeEntity>> updateMachineType(
    int id,
    MachineTypeEntity machineType,
  );

  /// Delete machine type
  Future<Either<ApiError, void>> deleteMachineType(int id);

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Part Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all machine parts (tree structure)
  Future<Either<ApiError, List<MachinePartEntity>>> getAllMachineParts({
    int? status,
  });

  /// Get machine part tree
  Future<Either<ApiError, List<MachinePartEntity>>> getMachinePartTree();

  /// Get machine part by ID
  Future<Either<ApiError, MachinePartEntity>> getMachinePartById(int id);

  /// Create machine part
  Future<Either<ApiError, MachinePartEntity>> createMachinePart(
    MachinePartEntity machinePart,
  );

  /// Update machine part
  Future<Either<ApiError, MachinePartEntity>> updateMachinePart(
    int id,
    MachinePartEntity machinePart,
  );

  /// Delete machine part
  Future<Either<ApiError, void>> deleteMachinePart(int id);

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Settings Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get machine settings for current user
  Future<Either<ApiError, MachineSettingEntity>> getMachineSetting();
}
