/// =============================================================================
/// File: vision_notification_repository_impl.dart
/// Description: Implementation of VisionNotificationRepository interface
///
/// Purpose:
/// - Implements domain repository interface for vision notifications
/// - Converts API responses to domain entities
/// - Handles error mapping to domain layer
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:thermal_mobile/core/error/failure.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:thermal_mobile/data/network/vision_notification/mapper/vision_notification_mapper.dart';
import 'package:thermal_mobile/data/network/vision_notification/vision_notification_api_service.dart';
import 'package:thermal_mobile/domain/models/vision_notification_entity.dart';
import 'package:thermal_mobile/domain/repositories/vision_notification_repository.dart';

/// Implementation of [VisionNotificationRepository]
@LazySingleton(as: VisionNotificationRepository)
class VisionNotificationRepositoryImpl
    implements VisionNotificationRepository {
  final VisionNotificationApiService _apiService;
  final GetAccessToken _getAccessToken;
  final AppLogger _logger = AppLogger(tag: 'VisionNotificationRepositoryImpl');

  VisionNotificationRepositoryImpl(
    this._apiService, {
    required GetAccessToken getAccessToken,
  }) : _getAccessToken = getAccessToken;

  @override
  Future<Either<Failure, VisionNotificationListEntity>> getVisionNotifications({
    required String fromTime,
    String? toTime,
    int? areaId,
    int? cameraId,
    int? warningEventId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      _logger.info(
        'Fetching vision notifications: fromTime=$fromTime, toTime=$toTime, '
        'areaId=$areaId, cameraId=$cameraId, warningEventId=$warningEventId, '
        'page=$page, pageSize=$pageSize',
      );

      final accessToken = await _getAccessToken();
      final response = await _apiService.getVisionNotifications(
        accessToken: accessToken,
        fromTime: fromTime,
        toTime: toTime,
        areaId: areaId,
        cameraId: cameraId,
        warningEventId: warningEventId,
        page: page,
        pageSize: pageSize,
      );

      final entity = VisionNotificationMapper.toListEntity(response);

      _logger.info(
        'Successfully fetched vision notifications: '
        'totalRow=${entity.totalRow}, items=${entity.items.length}',
      );

      return Right(entity);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch vision notifications',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(
        ServerFailure(
          message: e.toString(),
          statusCode: null,
        ),
      );
    }
  }
}
