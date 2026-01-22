/// Filter parameters for Temperature Threshold notifications
class TemperatureFilterParams {
  final DateTime? fromTime;
  final DateTime? toTime;
  final int? areaId;
  final String? areaName;
  final int? machineId;
  final String? machineName;
  final int? notificationStatus; // 1 = Pending (Chưa xử lý), 2 = Processed (Đã xử lý)

  const TemperatureFilterParams({
    this.fromTime,
    this.toTime,
    this.areaId,
    this.areaName,
    this.machineId,
    this.machineName,
    this.notificationStatus,
  });

  TemperatureFilterParams copyWith({
    DateTime? fromTime,
    DateTime? toTime,
    int? areaId,
    String? areaName,
    int? machineId,
    String? machineName,
    int? notificationStatus,
  }) {
    return TemperatureFilterParams(
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      notificationStatus: notificationStatus ?? this.notificationStatus,
    );
  }

  // Factory for default filter (7 days back)
  factory TemperatureFilterParams.defaultFilter() {
    return TemperatureFilterParams(
      fromTime: DateTime.now().subtract(const Duration(days: 7)),
      toTime: DateTime.now(),
    );
  }
}

/// Filter parameters for AI Warning notifications
class AIWarningFilterParams {
  final DateTime? fromTime;
  final DateTime? toTime;
  final int? areaId;
  final String? areaName;
  final int? cameraId;
  final String? cameraName;
  final int? warningEventId;
  final String? warningEventName;

  const AIWarningFilterParams({
    this.fromTime,
    this.toTime,
    this.areaId,
    this.areaName,
    this.cameraId,
    this.cameraName,
    this.warningEventId,
    this.warningEventName,
  });

  AIWarningFilterParams copyWith({
    DateTime? fromTime,
    DateTime? toTime,
    int? areaId,
    String? areaName,
    int? cameraId,
    String? cameraName,
    int? warningEventId,
    String? warningEventName,
  }) {
    return AIWarningFilterParams(
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      cameraId: cameraId ?? this.cameraId,
      cameraName: cameraName ?? this.cameraName,
      warningEventId: warningEventId ?? this.warningEventId,
      warningEventName: warningEventName ?? this.warningEventName,
    );
  }

  // Factory for default filter (7 days back)
  factory AIWarningFilterParams.defaultFilter() {
    return AIWarningFilterParams(
      fromTime: DateTime.now().subtract(const Duration(days: 7)),
      toTime: DateTime.now(),
    );
  }
}
