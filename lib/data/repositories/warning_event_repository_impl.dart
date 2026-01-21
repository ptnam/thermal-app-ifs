import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:thermal_mobile/core/error/failure.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:thermal_mobile/data/network/warning_event/warning_event_api_service.dart';
import 'package:thermal_mobile/domain/models/warning_event_entity.dart';
import 'package:thermal_mobile/domain/repositories/warning_event_repository.dart';

/// Implementation of WarningEventRepository
@LazySingleton(as: WarningEventRepository)
class WarningEventRepositoryImpl implements WarningEventRepository {
  final WarningEventApiService _apiService;
  final GetAccessToken _getAccessToken;
  final AppLogger _logger = AppLogger(tag: 'WarningEventRepositoryImpl');

  WarningEventRepositoryImpl(
    this._apiService, {
    required GetAccessToken getAccessToken,
  }) : _getAccessToken = getAccessToken;

  @override
  Future<Either<Failure, List<WarningEventEntity>>> getAllWarningEvents({
    required int warningType,
  }) async {
    try {
      _logger.info('Fetching warning events: warningType=$warningType');

      final accessToken = await _getAccessToken();
        final result = await _apiService.getAllWarningEvents(
          accessToken: accessToken,
          warningType: warningType,
        );

        return result.fold(
          onFailure: (error) {
            _logger.error('Failed to fetch warning events: ${error.message}');
            return Left(ServerFailure(
              message: error.message,
              statusCode: error.statusCode,
            ));
          },
          onSuccess: (response) {
            final list = response?.data;
            if (list == null) {
              _logger.warning('Empty response from API');
              return const Right([]);
            }

            final entities = list
                .map((dto) => WarningEventEntity(
                      id: dto.id,
                      code: dto.code,
                      name: dto.name,
                    ))
                .toList();

            _logger.info('Successfully fetched ${entities.length} warning events');
            return Right(entities);
          },
        );
    } catch (e, stackTrace) {
      _logger.error(
        'Error fetching warning events',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
