/// =============================================================================
/// File: vision_notification_entity.dart
/// Description: Vision Notification domain entity
/// 
/// Purpose:
/// - Pure domain model for vision notification management
/// - Used in vision alerting and notification features
/// =============================================================================

/// Domain entity representing a Vision Notification Item
class VisionNotificationItemEntity {
  final String id;
  final DateTime alertTime;
  final String imagePath;
  final String? videoPath;
  final bool inArea;
  final String areaName;
  final String cameraName;
  final String warningEventName;
  final String formattedDate;
  final String dateData;
  final String timeData;

  const VisionNotificationItemEntity({
    required this.id,
    required this.alertTime,
    required this.imagePath,
    this.videoPath,
    required this.inArea,
    required this.areaName,
    required this.cameraName,
    required this.warningEventName,
    required this.formattedDate,
    required this.dateData,
    required this.timeData,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisionNotificationItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Domain entity for paginated vision notification list
class VisionNotificationListEntity {
  final int totalRow;
  final int pageSize;
  final int pageIndex;
  final int rowIndex;
  final int lastRowIndex;
  final int totalPages;
  final List<VisionNotificationItemEntity> items;

  const VisionNotificationListEntity({
    required this.totalRow,
    required this.pageSize,
    required this.pageIndex,
    required this.rowIndex,
    required this.lastRowIndex,
    required this.totalPages,
    required this.items,
  });

  bool get hasNextPage => pageIndex < totalPages;
  bool get hasPreviousPage => pageIndex > 1;
}
