import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/core/error/failure.dart';
import 'package:thermal_mobile/domain/models/warning_event_entity.dart';

/// Repository interface for Warning Event operations
abstract class WarningEventRepository {
  /// Get all warning events by type
  /// warningType: 1 = Thermal, 2 = AI
  Future<Either<Failure, List<WarningEventEntity>>> getAllWarningEvents({
    required int warningType,
  });
}
