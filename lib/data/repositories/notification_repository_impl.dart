/// =============================================================================
/// File: notification_repository_impl.dart
/// Description: Implementation of NotificationRepository interface
///
/// Purpose:
/// - Implements domain repository interface for notifications
/// - Converts API responses to domain entities
/// - Maps ApiError to Failure for domain layer compatibility
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/notification/dto/notification_count_dto.dart';
import 'package:thermal_mobile/domain/models/notification.dart';

import '../../core/error/failure.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/repositories/notification_repository.dart';
import '../network/notification/notification_api_service.dart';
import '../network/notification/dto/notification_dto.dart';

/// Implementation of [NotificationRepository] that uses [NotificationApiService].
///
/// This repository handles:
/// - Fetching notification list
/// - Fetching notification details
/// - Converting DTOs to domain entities
/// - Mapping API errors to domain Failures
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApiService _notificationApiService;
  final Future<String> Function() _getAccessToken;
  final AppLogger _logger = AppLogger(tag: 'NotificationRepositoryImpl');

  NotificationRepositoryImpl({
    required NotificationApiService notificationApiService,
    required Future<String> Function() getAccessToken,
  }) : _notificationApiService = notificationApiService,
       _getAccessToken = getAccessToken;

  // ─────────────────────────────────────────────────────────────────────────────
  // Notification Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, NotificationListEntity>> getNotifications({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final token = await _getAccessToken();

      // Extract query parameters
      final page = queryParameters['page'] as int? ?? 1;
      final pageSize = queryParameters['pageSize'] as int? ?? 10;
      final machineId = queryParameters['machineId'] as int?;
      final areaId = queryParameters['areaId'] as int?;
      final fromTimeStr = queryParameters['fromTime'] as String?;

      // Default: last 7 days if not specified
      final now = DateTime.now();
      final fromTime = fromTimeStr != null
          ? DateTime.tryParse(fromTimeStr) ??
                now.subtract(const Duration(days: 7))
          : now.subtract(const Duration(days: 7));

      _logger.info(
        'Getting notifications: fromTime=$fromTime, page=$page, pageSize=$pageSize',
      );

      final notificationStatusInt = queryParameters['notificationStatus'] as int?;
      final NotificationStatus? notificationStatus = notificationStatusInt != null
          ? NotificationStatus.fromValue(notificationStatusInt)
          : null;

      _logger.info('Notification status filter: ${notificationStatus?.toQueryParam() ?? 'none'}');

      final result = await _notificationApiService.getNotificationList(
        accessToken: token,
        fromTime: fromTime,
        page: page,
        pageSize: pageSize,
        notificationStatus: notificationStatus,
        machineId: machineId,
        areaId: areaId,
      );

      return result.fold(
        onFailure: (error) {
          _logger.error(
            'API Error: ${error.message}, code=${error.code}, statusCode=${error.statusCode}',
          );
          return Left(
            ServerFailure(
              message: error.message,
              statusCode: error.statusCode,
              code: error.code,
            ),
          );
        },
        onSuccess: (response) {
          _logger.info(
            'API Success: totalRecords=${response?.totalRecords}, items=${response?.data.length}',
          );
          if (response == null) {
            return Right(
              NotificationListEntity(
                totalRow: 0,
                pageSize: pageSize,
                pageIndex: page,
                items: [],
              ),
            );
          }

          final items = response.data.map((dto) => _dtoToEntity(dto)).toList();
          return Right(
            NotificationListEntity(
              totalRow: response.totalRecords,
              pageSize: response.pageSize,
              pageIndex: response.currentPage,
              totalPages: response.totalPages,
              items: items,
            ),
          );
        },
      );
    } catch (e, st) {
      return Left(
        NetworkFailure(
          message: 'Failed to get notifications: $e',
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationItemEntity>> getNotificationDetail({
    required String id,
    required String dataTime,
  }) async {
    try {
      final token = await _getAccessToken();

      final parsedDataTime = DateTime.tryParse(dataTime);
      if (parsedDataTime == null) {
        return Left(
          ServerFailure(message: 'Invalid dataTime format', statusCode: 400),
        );
      }

      final result = await _notificationApiService.getNotificationById(
        id: id,
        dataTime: parsedDataTime,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(
          ServerFailure(
            message: error.message,
            statusCode: error.statusCode,
            code: error.code,
          ),
        ),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              ServerFailure(message: 'Notification not found', statusCode: 404),
            );
          }
          return Right(_dtoToEntity(response));
        },
      );
    } catch (e, st) {
      return Left(
        NetworkFailure(
          message: 'Failed to get notification detail: $e',
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<NotificationCountEntity>>> getNotificationCount({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final token = await _getAccessToken();

      _logger.info(
        'Getting notification count: startDate=$startDate, endDate=$endDate',
      );

      final result = await _notificationApiService.getNotificationCount(
        accessToken: token,
        startDate: startDate,
        endDate: endDate,
      );

      return result.fold(
        onFailure: (error) {
          _logger.error(
            'API Error: ${error.message}, code=${error.code}, statusCode=${error.statusCode}',
          );
          return Left(
            ServerFailure(
              message: error.message,
              statusCode: error.statusCode,
              code: error.code,
            ),
          );
        },
        onSuccess: (response) {
          _logger.info('API Success: ${response?.length ?? 0} records');
          if (response == null || response.isEmpty) {
            return const Right([]);
          }

          final entities = response
              .map(
                (dto) => NotificationCountEntity(
                  dataDate: dto.dataDate ?? '',
                  numberOfNotifications: dto.numberOfNotifications ?? 0,
                ),
              )
              .toList();

          return Right(entities);
        },
      );
    } catch (e) {
      return Left(
        NetworkFailure(
          message: 'Failed to get notification count: $e',
          originalException: e,
        ),
      );
    }
  }
  // ─────────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Convert NotificationExtendDto to NotificationItemEntity
  NotificationItemEntity _dtoToEntity(NotificationExtendDto dto) {
    return NotificationItemEntity(
      id: dto.id ?? '',
      formattedDate: dto.formattedDate,
      areaName: dto.areaName,
      machineName: dto.machineName,
      componentValue: dto.componentValue,
      warningEventName: dto.warningEventName,
      dataTime: dto.dataTime?.toIso8601String(),
      imagePath: dto.imagePath,
      dateData: dto.dateData,
      timeData: dto.timeData,
      compareTypeObject: dto.compareTypeObject != null
          ? CompareTypeEntity(
              id: dto.compareTypeObject!.id,
              code: dto.compareTypeObject!.code,
              name: dto.compareTypeObject!.name,
            )
          : null,
      compareResultObject: dto.compareResultObject != null
          ? CompareResultEntity(
              id: dto.compareResultObject!.id,
              code: dto.compareResultObject!.code,
              name: dto.compareResultObject!.name,
            )
          : null,
      statusObject: dto.statusObject != null
          ? StatusEntity(
              id: dto.statusObject!.id,
              code: dto.statusObject!.code,
              name: dto.statusObject!.name,
            )
          : null,
      compareValue: dto.compareValue,
      deltaValue: dto.deltaValue,
      monitorPointCode: dto.monitorPointCode,
      machineComponentName: dto.machineComponentName,
      resolveTime: dto.resolveTime?.toIso8601String(),
      compareComponent: dto.compareComponent,
      compareMonitorPoint: dto.compareMonitorPoint,
      compareDataTime: dto.compareDataTime?.toIso8601String(),
      compareMinTemperature: dto.compareMinTemperature,
      compareMaxTemperature: dto.compareMaxTemperature,
      compareAveTemperature: dto.compareAveTemperature,
    );
  }

  String _mapNotificationStatusName(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.pending:
        return 'Chờ xử lý';
      case NotificationStatus.processed:
        return 'Đã xử lý';
    }
  }
}
