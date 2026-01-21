import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/domain/models/notification.dart';

import '../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase
    extends UseCase<NotificationListEntity, GetNotificationsParams> {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationListEntity>> call(
    GetNotificationsParams params,
  ) async {
    return await repository.getNotifications(
      queryParameters: params.queryParameters,
    );
  }
}

class GetNotificationsParams {
  final Map<String, dynamic> queryParameters;

  GetNotificationsParams({required this.queryParameters});
}

class GetNotificationDetailUseCase
    extends UseCase<NotificationItemEntity, GetNotificationDetailParams> {
  final NotificationRepository repository;

  GetNotificationDetailUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationItemEntity>> call(
    GetNotificationDetailParams params,
  ) async {
    return await repository.getNotificationDetail(
      id: params.id,
      dataTime: params.dataTime,
    );
  }
}

class GetNotificationDetailParams {
  final String id;
  final String dataTime;

  GetNotificationDetailParams({required this.id, required this.dataTime});
}

class GetNotificationCountUseCase
    extends UseCase<List<NotificationCountEntity>, GetNotificationCountParams> {
  final NotificationRepository repository;

  GetNotificationCountUseCase(this.repository);

  @override
  Future<Either<Failure, List<NotificationCountEntity>>> call(
    GetNotificationCountParams params,
  ) async {
    return await repository.getNotificationCount(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetNotificationCountParams {
  final DateTime startDate;
  final DateTime endDate;

  GetNotificationCountParams({required this.startDate, required this.endDate});
}
