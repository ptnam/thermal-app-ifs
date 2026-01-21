/// =============================================================================
/// File: vision_notification_dto.dart
/// Description: Vision Notification data transfer objects
///
/// Purpose:
/// - Maps to backend's VisionNotification DTOs
/// - Used for vision notification list operations
/// =============================================================================

/// Helper to parse int from dynamic (can be String or int)
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// Helper to parse bool from dynamic
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is int) return value != 0;
  return false;
}

/// Helper to parse DateTime from dynamic
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Vision Notification Item DTO
/// Maps to backend's VisionNotification item
class VisionNotificationItemDto {
  final String? id;
  final DateTime? alertTime;
  final String? imagePath;
  final String? videoPath;
  final bool? inArea;
  final String? areaName;
  final String? cameraName;
  final String? warningEventName;
  final String? formattedDate;
  final String? dateData;
  final String? timeData;

  const VisionNotificationItemDto({
    this.id,
    this.alertTime,
    this.imagePath,
    this.videoPath,
    this.inArea,
    this.areaName,
    this.cameraName,
    this.warningEventName,
    this.formattedDate,
    this.dateData,
    this.timeData,
  });

  factory VisionNotificationItemDto.fromJson(Map<String, dynamic> json) {
    return VisionNotificationItemDto(
      id: json['id'] as String?,
      alertTime: _parseDateTime(json['alertTime']),
      imagePath: json['imagePath'] as String?,
      videoPath: json['videoPath'] as String?,
      inArea: _parseBool(json['inArea']),
      areaName: json['areaName'] as String?,
      cameraName: json['cameraName'] as String?,
      warningEventName: json['warningEventName'] as String?,
      formattedDate: json['formattedDate'] as String?,
      dateData: json['dateData'] as String?,
      timeData: json['timeData'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alertTime': alertTime?.toIso8601String(),
      'imagePath': imagePath,
      'videoPath': videoPath,
      'inArea': inArea,
      'areaName': areaName,
      'cameraName': cameraName,
      'warningEventName': warningEventName,
      'formattedDate': formattedDate,
      'dateData': dateData,
      'timeData': timeData,
    };
  }
}

/// Vision Notification List Response DTO
/// Maps to backend's paginated response structure
class VisionNotificationListResponseDto {
  final int? totalRow;
  final int? pageSize;
  final int? pageIndex;
  final int? rowIndex;
  final int? lastRowIndex;
  final int? totalPages;
  final List<VisionNotificationItemDto>? items;

  const VisionNotificationListResponseDto({
    this.totalRow,
    this.pageSize,
    this.pageIndex,
    this.rowIndex,
    this.lastRowIndex,
    this.totalPages,
    this.items,
  });

  factory VisionNotificationListResponseDto.fromJson(
      Map<String, dynamic> json) {
    return VisionNotificationListResponseDto(
      totalRow: _parseInt(json['totalRow']),
      pageSize: _parseInt(json['pageSize']),
      pageIndex: _parseInt(json['pageIndex']),
      rowIndex: _parseInt(json['rowIndex']),
      lastRowIndex: _parseInt(json['lastRowIndex']),
      totalPages: _parseInt(json['totalPages']),
      items: (json['items'] as List?)
          ?.map((e) => VisionNotificationItemDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRow': totalRow,
      'pageSize': pageSize,
      'pageIndex': pageIndex,
      'rowIndex': rowIndex,
      'lastRowIndex': lastRowIndex,
      'totalPages': totalPages,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}
