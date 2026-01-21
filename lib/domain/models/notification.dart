class NotificationItemEntity {
  final String id;
  final String? formattedDate;
  final String? areaName;
  final String? machineName;
  final double? componentValue;
  final String? warningEventName;
  final String? dataTime;
  final String? imagePath;
  final String? dateData;
  final String? timeData;
  final CompareTypeEntity? compareTypeObject;
  final CompareResultEntity? compareResultObject;
  final StatusEntity? statusObject;
  final double? compareValue;
  final double? deltaValue;
  final String? monitorPointCode;
  final String? machineComponentName;
  final String? resolveTime;
  final String? compareComponent;
  final String? compareMonitorPoint;
  final String? compareDataTime;
  final double? compareMinTemperature;
  final double? compareMaxTemperature;
  final double? compareAveTemperature;

  NotificationItemEntity({
    required this.id,
    this.formattedDate,
    this.areaName,
    this.machineName,
    this.componentValue,
    this.warningEventName,
    this.dataTime,
    this.imagePath,
    this.dateData,
    this.timeData,
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
  });
}

class CompareTypeEntity {
  final int? id;
  final String? code;
  final String? name;

  CompareTypeEntity({this.id, this.code, this.name});
}

class CompareResultEntity {
  final int? id;
  final String? code;
  final String? name;

  CompareResultEntity({this.id, this.code, this.name});
}

class StatusEntity {
  final int? id;
  final String? code;
  final String? name;

  StatusEntity({this.id, this.code, this.name});
}

class NotificationListEntity {
  final int? totalRow;
  final int? pageSize;
  final int? pageIndex;
  final int? totalPages;
  final List<NotificationItemEntity> items;

  NotificationListEntity({
    this.totalRow,
    this.pageSize,
    this.pageIndex,
    this.totalPages,
    required this.items,
  });

  bool get hasNextPage => (pageIndex ?? 1) < (totalPages ?? 1);
}

/// Entity for notification count statistics by date
class NotificationCountEntity {
  final String dataDate;
  final int numberOfNotifications;

  const NotificationCountEntity({
    required this.dataDate,
    required this.numberOfNotifications,
  });
}
