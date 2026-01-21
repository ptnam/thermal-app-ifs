/// =============================================================================
/// File: base_dto.dart
/// Description: Base DTO classes for common response patterns
/// 
/// Purpose:
/// - ShortenBaseDto: Minimal reference model with id/name
/// - CommonStatus: Entity status enum
/// - Maps to backend common models
/// =============================================================================

/// Minimal entity reference with just id and name
/// 
/// Maps to backend's ShortenBaseDto:
/// Used for dropdown lists, references, and quick lookups
class ShortenBaseDto {
  final int id;
  final String name;

  const ShortenBaseDto({
    required this.id,
    required this.name,
  });

  factory ShortenBaseDto.fromJson(Map<String, dynamic> json) {
    return ShortenBaseDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() => 'ShortenBaseDto(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortenBaseDto && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

/// Common entity status enum
/// Maps to backend's CommonStatus enum
enum CommonStatus {
  /// Active/enabled status
  active(1),
  
  /// Inactive/disabled status
  inactive(0),
  
  /// Deleted/archived status
  deleted(-1);

  final int value;
  const CommonStatus(this.value);

  static CommonStatus fromValue(int value) {
    switch (value) {
      case 1:
        return CommonStatus.active;
      case 0:
        return CommonStatus.inactive;
      case -1:
        return CommonStatus.deleted;
      default:
        return CommonStatus.inactive;
    }
  }

  String toQueryParam() => value.toString();
}

/// User status enum
/// Maps to backend's UserStatus enum
enum UserStatus {
  active(1),
  inactive(0),
  deleted(-1);

  final int value;
  const UserStatus(this.value);

  static UserStatus fromValue(int value) {
    switch (value) {
      case 1:
        return UserStatus.active;
      case 0:
        return UserStatus.inactive;
      case -1:
        return UserStatus.deleted;
      default:
        return UserStatus.inactive;
    }
  }

  String toQueryParam() => value.toString();
}

/// Notification status enum
/// Maps to backend's NotificationStatus enum
enum NotificationStatus {
  pending(1),     // Chưa xử lý
  processed(2);   // Đã xử lý (Resolved)

  final int value;
  const NotificationStatus(this.value);

  static NotificationStatus fromValue(int value) {
    switch (value) {
      case 1:
        return NotificationStatus.pending;
      case 2:
        return NotificationStatus.processed;
      default:
        return NotificationStatus.pending;
    }
  }

  String toQueryParam() => value.toString();
}

/// Temperature level enum for thermal data filtering
enum TemperatureLevel {
  normal(0),
  warning(1),
  critical(2);

  final int value;
  const TemperatureLevel(this.value);

  static TemperatureLevel fromValue(int value) {
    switch (value) {
      case 0:
        return TemperatureLevel.normal;
      case 1:
        return TemperatureLevel.warning;
      case 2:
        return TemperatureLevel.critical;
      default:
        return TemperatureLevel.normal;
    }
  }

  String toQueryParam() => value.toString();
}

/// Camera type enum
enum CameraType {
  thermal(1),
  vision(2);

  final int value;
  const CameraType(this.value);

  static CameraType fromValue(int value) {
    switch (value) {
      case 1:
        return CameraType.thermal;
      case 2:
        return CameraType.vision;
      default:
        return CameraType.thermal;
    }
  }

  String toQueryParam() => value.toString();
}

/// Monitor type enum
enum MonitorType {
  temperature(1),
  humidity(2),
  vibration(3);

  final int value;
  const MonitorType(this.value);

  static MonitorType fromValue(int value) {
    switch (value) {
      case 1:
        return MonitorType.temperature;
      case 2:
        return MonitorType.humidity;
      case 3:
        return MonitorType.vibration;
      default:
        return MonitorType.temperature;
    }
  }

  String toQueryParam() => value.toString();
}

/// Notification channel type enum
enum NotificationChannelType {
  email(1),
  sms(2),
  push(3),
  webhook(4);

  final int value;
  const NotificationChannelType(this.value);

  static NotificationChannelType fromValue(int value) {
    switch (value) {
      case 1:
        return NotificationChannelType.email;
      case 2:
        return NotificationChannelType.sms;
      case 3:
        return NotificationChannelType.push;
      case 4:
        return NotificationChannelType.webhook;
      default:
        return NotificationChannelType.email;
    }
  }

  String toQueryParam() => value.toString();
}

/// Notification channel status enum
enum NotificationChannelStatus {
  active(1),
  inactive(0);

  final int value;
  const NotificationChannelStatus(this.value);

  static NotificationChannelStatus fromValue(int value) {
    switch (value) {
      case 1:
        return NotificationChannelStatus.active;
      case 0:
        return NotificationChannelStatus.inactive;
      default:
        return NotificationChannelStatus.inactive;
    }
  }

  String toQueryParam() => value.toString();
}

/// Warning type enum
enum WarningType {
  temperature(1),
  humidity(2),
  vibration(3);

  final int value;
  const WarningType(this.value);

  static WarningType fromValue(int value) {
    switch (value) {
      case 1:
        return WarningType.temperature;
      case 2:
        return WarningType.humidity;
      case 3:
        return WarningType.vibration;
      default:
        return WarningType.temperature;
    }
  }

  String toQueryParam() => value.toString();
}

/// Threshold type enum
enum ThresholdType {
  absolute(1),
  relative(2);

  final int value;
  const ThresholdType(this.value);

  static ThresholdType fromValue(int value) {
    switch (value) {
      case 1:
        return ThresholdType.absolute;
      case 2:
        return ThresholdType.relative;
      default:
        return ThresholdType.absolute;
    }
  }

  String toQueryParam() => value.toString();
}

/// Device type enum
enum DeviceType {
  component(1),
  sensor(2);

  final int value;
  const DeviceType(this.value);

  static DeviceType fromValue(int value) {
    switch (value) {
      case 1:
        return DeviceType.component;
      case 2:
        return DeviceType.sensor;
      default:
        return DeviceType.component;
    }
  }

  String toQueryParam() => value.toString();
}

/// Monitor point type enum
enum MonitorPointType {
  camera(1),
  sensor(2);

  final int value;
  const MonitorPointType(this.value);

  static MonitorPointType fromValue(int value) {
    switch (value) {
      case 1:
        return MonitorPointType.camera;
      case 2:
        return MonitorPointType.sensor;
      default:
        return MonitorPointType.camera;
    }
  }

  String toQueryParam() => value.toString();
}
