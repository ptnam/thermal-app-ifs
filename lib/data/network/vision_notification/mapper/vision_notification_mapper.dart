import 'package:thermal_mobile/data/network/vision_notification/dto/vision_notification_dto.dart';
import 'package:thermal_mobile/domain/models/vision_notification_entity.dart';

/// Mapper for Vision Notification DTOs to Entities
class VisionNotificationMapper {
  /// Map VisionNotificationItemDto to VisionNotificationItemEntity
  static VisionNotificationItemEntity toEntity(
      VisionNotificationItemDto dto) {
    return VisionNotificationItemEntity(
      id: dto.id ?? '',
      alertTime: dto.alertTime ?? DateTime.now(),
      imagePath: dto.imagePath ?? '',
      videoPath: dto.videoPath,
      inArea: dto.inArea ?? false,
      areaName: dto.areaName ?? '',
      cameraName: dto.cameraName ?? '',
      warningEventName: dto.warningEventName ?? '',
      formattedDate: dto.formattedDate ?? '',
      dateData: dto.dateData ?? '',
      timeData: dto.timeData ?? '',
    );
  }

  /// Map VisionNotificationListResponseDto to VisionNotificationListEntity
  static VisionNotificationListEntity toListEntity(
      VisionNotificationListResponseDto dto) {
    return VisionNotificationListEntity(
      totalRow: dto.totalRow ?? 0,
      pageSize: dto.pageSize ?? 0,
      pageIndex: dto.pageIndex ?? 1,
      rowIndex: dto.rowIndex ?? 1,
      lastRowIndex: dto.lastRowIndex ?? 0,
      totalPages: dto.totalPages ?? 0,
      items: dto.items?.map((item) => toEntity(item)).toList() ?? [],
    );
  }
}
