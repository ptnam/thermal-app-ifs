import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/domain/models/notification.dart';
import '../../core/error/failure.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationListEntity>> getNotifications({
    required Map<String, dynamic> queryParameters,
  });

  Future<Either<Failure, NotificationItemEntity>> getNotificationDetail({
    required String id,
    required String dataTime,
  });

  Future<Either<Failure, List<NotificationCountEntity>>> getNotificationCount({
    required DateTime startDate,
    required DateTime endDate,
  });
}
