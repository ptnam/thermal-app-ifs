import 'package:thermal_mobile/data/network/api/base_dto.dart';

/// =============================================================================
/// File: notification_dto.dart
/// Description: Notification data transfer objects
///
/// Purpose:
/// - Maps to backend's Notification DTOs
/// - Used for notification list and detail operations
/// =============================================================================


/// Helper to parse int from dynamic (can be String or int)
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// Helper to parse double from dynamic
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Common enum object from backend
class CommonEnumObject {
  final int? id;
  final String? code;
  final String? name;

  const CommonEnumObject({this.id, this.code, this.name});

  factory CommonEnumObject.fromJson(Map<String, dynamic> json) {
    return CommonEnumObject(
      id: _parseInt(json['id']),
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }
}

/// Notification extend DTO with full details
/// Maps to backend's NotificationExtend class
class NotificationExtendDto {
  final String? id;
  final DateTime? dataTime;
  final String? formattedDate;
  final String? dateData;
  final String? timeData;
  final String? areaName;
  final String? machineName;
  final double? componentValue;
  final String? warningEventName;
  final CommonEnumObject? compareTypeObject;
  final CommonEnumObject? compareResultObject;
  final CommonEnumObject? statusObject;
  final double? compareValue;
  final double? deltaValue;
  final String? monitorPointCode;
  final String? machineComponentName;
  final DateTime? resolveTime;
  final String? compareComponent;
  final String? compareMonitorPoint;
  final DateTime? compareDataTime;
  final double? compareMinTemperature;
  final double? compareMaxTemperature;
  final double? compareAveTemperature;
  final String? imagePath;

  const NotificationExtendDto({
    this.id,
    this.dataTime,
    this.formattedDate,
    this.dateData,
    this.timeData,
    this.areaName,
    this.machineName,
    this.componentValue,
    this.warningEventName,
    this.compareTypeObject,
    this.compareResultObject,
    this.statusObject,
    this.compareValue,
    this.deltaValue,
    this.monitorPointCode,
    this.machineComponentName,
    this.resolveTime,
    this.compareComponent,
    this.compareMonitorPoint,
    this.compareDataTime,
    this.compareMinTemperature,
    this.compareMaxTemperature,
    this.compareAveTemperature,
    this.imagePath,
  });

  factory NotificationExtendDto.fromJson(Map<String, dynamic> json) {
    return NotificationExtendDto(
      id: json['id'] as String?,
      dataTime: json['dataTime'] != null
          ? DateTime.tryParse(json['dataTime'] as String)
          : null,
      formattedDate: json['formattedDate'] as String?,
      dateData: json['dateData'] as String?,
      timeData: json['timeData'] as String?,
      areaName: json['areaName'] as String?,
      machineName: json['machineName'] as String?,
      componentValue: _parseDouble(json['componentValue']),
      warningEventName: json['warningEventName'] as String?,
      compareTypeObject: json['compareTypeObject'] != null
          ? CommonEnumObject.fromJson(
              json['compareTypeObject'] as Map<String, dynamic>,
            )
          : null,
      compareResultObject: json['compareResultObject'] != null
          ? CommonEnumObject.fromJson(
              json['compareResultObject'] as Map<String, dynamic>,
            )
          : null,
      statusObject: json['statusObject'] != null
          ? CommonEnumObject.fromJson(
              json['statusObject'] as Map<String, dynamic>,
            )
          : null,
      compareValue: _parseDouble(json['compareValue']),
      deltaValue: _parseDouble(json['deltaValue']),
      monitorPointCode: json['monitorPointCode'] as String?,
      machineComponentName: json['machineComponentName'] as String?,
      resolveTime: json['resolveTime'] != null
          ? DateTime.tryParse(json['resolveTime'] as String)
          : null,
      compareComponent: json['compareComponent'] as String?,
      compareMonitorPoint: json['compareMonitorPoint'] as String?,
      compareDataTime: json['compareDataTime'] != null
          ? DateTime.tryParse(json['compareDataTime'] as String)
          : null,
      compareMinTemperature: _parseDouble(json['compareMinTemperature']),
      compareMaxTemperature: _parseDouble(json['compareMaxTemperature']),
      compareAveTemperature: _parseDouble(json['compareAveTemperature']),
      imagePath: json['imagePath'] as String?,
    );
  }

  /// Get status from statusObject
  NotificationStatus get status {
    final statusId = statusObject?.id;
    if (statusId != null) {
      return NotificationStatus.fromValue(statusId);
    }
    return NotificationStatus.pending;
  }
}

/// Brief notification for header/list display
/// Maps to backend's NotificationBrief class
class NotificationBriefDto {
  final String? id;
  final DateTime? dataTime;
  final String? dateData;
  final String? timeData;
  final String? areaName;
  final String? machineName;
  final String? machineComponentName;
  final String? warningEventName;
  final DateTime? resolveTime;

  const NotificationBriefDto({
    this.id,
    this.dataTime,
    this.dateData,
    this.timeData,
    this.areaName,
    this.machineName,
    this.machineComponentName,
    this.warningEventName,
    this.resolveTime,
  });

  factory NotificationBriefDto.fromJson(Map<String, dynamic> json) {
    return NotificationBriefDto(
      id: json['id'] as String?,
      dataTime: json['dataTime'] != null
          ? DateTime.tryParse(json['dataTime'] as String)
          : null,
      dateData: json['dateData'] as String?,
      timeData: json['timeData'] as String?,
      areaName: json['areaName'] as String?,
      machineName: json['machineName'] as String?,
      machineComponentName: json['machineComponentName'] as String?,
      warningEventName: json['warningEventName'] as String?,
      resolveTime: json['resolveTime'] != null
          ? DateTime.tryParse(json['resolveTime'] as String)
          : null,
    );
  }

  /// Computed title from warning event and machine component
  String get title => warningEventName ?? machineComponentName ?? 'Thông báo';
}

/// Brief notifications with total count
/// Maps to backend's NotificationBriefTotal class
class NotificationBriefTotal {
  final int total;
  final List<NotificationBriefDto> notifications;

  const NotificationBriefTotal({
    required this.total,
    required this.notifications,
  });

  factory NotificationBriefTotal.fromJson(Map<String, dynamic> json) {
    return NotificationBriefTotal(
      total: _parseInt(json['total']) ?? 0,
      notifications:
          (json['notifications'] as List<dynamic>?)
              ?.map(
                (e) => NotificationBriefDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

/// Request to update notification status
class UpdateNotificationStatusRequest {
  final DateTime dataTime;
  final NotificationStatus status;

  const UpdateNotificationStatusRequest({
    required this.dataTime,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {'dataTime': dataTime.toIso8601String(), 'status': status.value};
  }
}
