/// =============================================================================
/// File: machine_usecase.dart
/// Description: Machine use cases
///
/// Purpose:
/// - Business logic for machine operations
/// - Orchestrates machine repository calls
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/domain/models/machine_entity.dart';
import 'package:thermal_mobile/domain/repositories/machine_repository.dart';

/// Use case for getting machine settings
class GetMachineSettingUseCase {
  final IMachineRepository _machineRepository;

  GetMachineSettingUseCase(this._machineRepository);

  Future<Either<ApiError, MachineSettingEntity>> call() {
    return _machineRepository.getMachineSetting();
  }
}
