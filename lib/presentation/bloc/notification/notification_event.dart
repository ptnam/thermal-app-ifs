part of 'notification_bloc.dart';

abstract class NotificationEvent {}

class LoadNotificationsEvent extends NotificationEvent {
  final Map<String, dynamic> queryParameters;

  LoadNotificationsEvent({required this.queryParameters});
}

class LoadNotificationDetailEvent extends NotificationEvent {
  final String id;
  final String dataTime;

  LoadNotificationDetailEvent({required this.id, required this.dataTime});
}

class LoadNotificationCountEvent extends NotificationEvent {
  final DateTime startDate;
  final DateTime endDate;

  LoadNotificationCountEvent({
    required this.startDate,
    required this.endDate,
  });
}

class LoadMoreNotifications extends NotificationEvent {}
