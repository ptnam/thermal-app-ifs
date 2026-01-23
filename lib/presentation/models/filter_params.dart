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
    bool clearAreaId = false,
    bool clearMachineId = false,
    bool clearNotificationStatus = false,
  }) {
    return TemperatureFilterParams(
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      areaId: clearAreaId ? null : (areaId ?? this.areaId),
      areaName: clearAreaId ? null : (areaName ?? this.areaName),
      machineId: clearMachineId ? null : (machineId ?? this.machineId),
      machineName: clearMachineId ? null : (machineName ?? this.machineName),
      notificationStatus: clearNotificationStatus ? null : (notificationStatus ?? this.notificationStatus),
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
    bool clearAreaId = false,
    bool clearCameraId = false,
    bool clearWarningEventId = false,
  }) {
    return AIWarningFilterParams(
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      areaId: clearAreaId ? null : (areaId ?? this.areaId),
      areaName: clearAreaId ? null : (areaName ?? this.areaName),
      cameraId: clearCameraId ? null : (cameraId ?? this.cameraId),
      cameraName: clearCameraId ? null : (cameraName ?? this.cameraName),
      warningEventId: clearWarningEventId ? null : (warningEventId ?? this.warningEventId),
      warningEventName: clearWarningEventId ? null : (warningEventName ?? this.warningEventName),
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
