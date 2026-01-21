/// =============================================================================
/// File: notification_entity.dart
/// Description: Notification domain entity
/// 
/// Purpose:
/// - Pure domain model for notification management
/// - Used in alerting and notification features
/// =============================================================================

import 'machine_entity.dart';

/// Notification status
enum NotificationStatusEntity {
  unread,
  read,
}

/// Warning type classification
enum WarningTypeEntity {
  temperature,
  connection,
  system,
  other,
}

/// Domain entity representing a Notification
class NotificationEntity {
  final int id;
  final String? title;
  final String? content;
  final int? machineId;
  final String? machineName;
  final int? machineComponentId;
  final String? machineComponentName;
  final int? warningEventId;
  final String? warningEventName;
  final WarningTypeEntity? warningType;
  final NotificationStatusEntity status;
  final double? temperature;
  final TemperatureLevelEntity? level;
  final DateTime? createdAt;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    this.title,
    this.content,
    this.machineId,
    this.machineName,
    this.machineComponentId,
    this.machineComponentName,
    this.warningEventId,
    this.warningEventName,
    this.warningType,
    this.status = NotificationStatusEntity.unread,
    this.temperature,
    this.level,
    this.createdAt,
    this.readAt,
  });

  bool get isRead => status == NotificationStatusEntity.read;
  bool get isUnread => status == NotificationStatusEntity.unread;
  bool get isDanger => level == TemperatureLevelEntity.danger;
  bool get isWarning => level == TemperatureLevelEntity.warning;

  NotificationEntity copyWith({
    int? id,
    String? title,
    String? content,
    int? machineId,
    String? machineName,
    int? machineComponentId,
    String? machineComponentName,
    int? warningEventId,
    String? warningEventName,
    WarningTypeEntity? warningType,
    NotificationStatusEntity? status,
    double? temperature,
    TemperatureLevelEntity? level,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      machineComponentId: machineComponentId ?? this.machineComponentId,
      machineComponentName: machineComponentName ?? this.machineComponentName,
      warningEventId: warningEventId ?? this.warningEventId,
      warningEventName: warningEventName ?? this.warningEventName,
      warningType: warningType ?? this.warningType,
      status: status ?? this.status,
      temperature: temperature ?? this.temperature,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NotificationEntity(id: $id, title: $title)';
}

/// Summary of notifications for header display
class NotificationSummaryEntity {
  final int totalUnread;
  final List<NotificationEntity> recentNotifications;

  const NotificationSummaryEntity({
    this.totalUnread = 0,
    this.recentNotifications = const [],
  });

  bool get hasUnread => totalUnread > 0;
}
