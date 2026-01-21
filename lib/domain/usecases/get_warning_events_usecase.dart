import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:thermal_mobile/core/error/failure.dart';
import 'package:thermal_mobile/domain/models/warning_event_entity.dart';
import 'package:thermal_mobile/domain/repositories/warning_event_repository.dart';

/// Use case for getting warning events
@lazySingleton
class GetWarningEventsUseCase {
  final WarningEventRepository _repository;

  GetWarningEventsUseCase(this._repository);

  /// Execute the use case
  /// warningType: 1 = Thermal, 2 = AI
  Future<Either<Failure, List<WarningEventEntity>>> call({
    required int warningType,
  }) async {
    return await _repository.getAllWarningEvents(warningType: warningType);
  }
}
