import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:thermal_mobile/core/error/failure.dart';
import 'package:thermal_mobile/core/usecase/usecase.dart';
import 'package:thermal_mobile/domain/models/vision_notification_entity.dart';
import 'package:thermal_mobile/domain/repositories/vision_notification_repository.dart';

/// Use case for getting vision notifications list
@injectable
class GetVisionNotificationsUseCase
    extends UseCase<VisionNotificationListEntity, GetVisionNotificationsParams> {
  final VisionNotificationRepository repository;

  GetVisionNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, VisionNotificationListEntity>> call(
    GetVisionNotificationsParams params,
  ) async {
    return await repository.getVisionNotifications(
      fromTime: params.fromTime,
      toTime: params.toTime,
      areaId: params.areaId,
      cameraId: params.cameraId,
      warningEventId: params.warningEventId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// Parameters for GetVisionNotificationsUseCase
class GetVisionNotificationsParams {
  final String fromTime;
  final String? toTime;
  final int? areaId;
  final int? cameraId;
  final int? warningEventId;
  final int page;
  final int pageSize;

  GetVisionNotificationsParams({
    required this.fromTime,
    this.toTime,
    this.areaId,
    this.cameraId,
    this.warningEventId,
    this.page = 1,
    this.pageSize = 50,
  });

  /// Create params with default date range (last 7 days)
  factory GetVisionNotificationsParams.defaultRange({
    int? areaId,
    int? cameraId,
    int? warningEventId,
    int page = 1,
    int pageSize = 50,
  }) {
    final now = DateTime.now();
    final fromTime = now.subtract(const Duration(days: 7));
    
    return GetVisionNotificationsParams(
      fromTime: _formatDateTime(fromTime),
      toTime: _formatDateTime(now),
      areaId: areaId,
      cameraId: cameraId,
      warningEventId: warningEventId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Format DateTime to 'yyyy-MM-dd HH:mm:ss'
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  GetVisionNotificationsParams copyWith({
    String? fromTime,
    String? toTime,
    int? areaId,
    int? cameraId,
    int? warningEventId,
    int? page,
    int? pageSize,
  }) {
    return GetVisionNotificationsParams(
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      areaId: areaId ?? this.areaId,
      cameraId: cameraId ?? this.cameraId,
      warningEventId: warningEventId ?? this.warningEventId,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
