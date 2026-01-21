 import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/domain/models/machine_thermal_entity.dart';
import 'package:thermal_mobile/domain/repositories/machine_thermal_repository.dart';

@injectable
class GetAreaThermalOverviewUseCase {
  final IMachineThermalRepository _repository;

  GetAreaThermalOverviewUseCase(this._repository);

  Future<Either<ApiError, AreaThermalOverviewEntity>> call(int areaId) {
    return _repository.getAreaThermalOverview(areaId);
  }
}
