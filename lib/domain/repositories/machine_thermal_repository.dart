import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/domain/models/machine_thermal_entity.dart';

abstract class IMachineThermalRepository {
  Future<Either<ApiError, AreaThermalOverviewEntity>> getAreaThermalOverview(
    int areaId,
  );
}
