// When ApiClient unwraps the envelope, it returns only the 'data' content
// So NotificationListResponseDto is actually the data structure
class NotificationListResponseDto {
  final int? totalRow;
  final int? pageSize;
  final int? pageIndex;
  final int? rowIndex;
  final int? lastRowIndex;
  final int? totalPages;
  final List<NotificationItemDto>? items;

  NotificationListResponseDto({
    this.totalRow,
    this.pageSize,
    this.pageIndex,
    this.rowIndex,
    this.lastRowIndex,
    this.totalPages,
    this.items,
  });

  factory NotificationListResponseDto.fromJson(Map<String, dynamic> json) {
    return NotificationListResponseDto(
      totalRow: json['totalRow'] as int?,
      pageSize: json['pageSize'] as int?,
      pageIndex: json['pageIndex'] as int?,
      rowIndex: json['rowIndex'] as int?,
      lastRowIndex: json['lastRowIndex'] as int?,
      totalPages: json['totalPages'] as int?,
      items: (json['items'] as List?)?.map((e) => NotificationItemDto.fromJson(e)).toList(),
    );
  }
}

// Kept for backwards compatibility with mapper
class NotificationListDataDto {
  final int? totalRow;
  final int? pageSize;
  final int? pageIndex;
  final int? rowIndex;
  final int? lastRowIndex;
  final int? totalPages;
  final List<NotificationItemDto>? items;

  NotificationListDataDto({
    this.totalRow,
    this.pageSize,
    this.pageIndex,
    this.rowIndex,
    this.lastRowIndex,
    this.totalPages,
    this.items,
  });

  factory NotificationListDataDto.fromJson(Map<String, dynamic> json) {
    return NotificationListDataDto(
      totalRow: json['totalRow'] as int?,
      pageSize: json['pageSize'] as int?,
      pageIndex: json['pageIndex'] as int?,
      rowIndex: json['rowIndex'] as int?,
      lastRowIndex: json['lastRowIndex'] as int?,
      totalPages: json['totalPages'] as int?,
      items: (json['items'] as List?)?.map((e) => NotificationItemDto.fromJson(e)).toList(),
    );
  }
}

class NotificationItemDto {
  final String? id;
  final String? formattedDate;
  final String? dateData;
  final String? timeData;
  final String? areaName;
  final String? machineName;
  final double? componentValue;
  final String? warningEventName;
  final CompareTypeObjectDto? compareTypeObject;
  final CompareResultObjectDto? compareResultObject;
  final StatusObjectDto? statusObject;
  final String? dataTime;
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
  final String? imagePath;

  NotificationItemDto({
    this.id,
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
    this.dataTime,
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

  factory NotificationItemDto.fromJson(Map<String, dynamic> json) {
    return NotificationItemDto(
      id: json['id'] as String?,
      formattedDate: json['formattedDate'] as String?,
      dateData: json['dateData'] as String?,
      timeData: json['timeData'] as String?,
      areaName: json['areaName'] as String?,
      machineName: json['machineName'] as String?,
      componentValue: (json['componentValue'] as num?)?.toDouble(),
      warningEventName: json['warningEventName'] as String?,
      compareTypeObject: json['compareTypeObject'] != null ? CompareTypeObjectDto.fromJson(json['compareTypeObject']) : null,
      compareResultObject: json['compareResultObject'] != null ? CompareResultObjectDto.fromJson(json['compareResultObject']) : null,
      statusObject: json['statusObject'] != null ? StatusObjectDto.fromJson(json['statusObject']) : null,
      dataTime: json['dataTime'] as String?,
      compareValue: (json['compareValue'] as num?)?.toDouble(),
      deltaValue: (json['deltaValue'] as num?)?.toDouble(),
      monitorPointCode: json['monitorPointCode'] as String?,
      machineComponentName: json['machineComponentName'] as String?,
      resolveTime: json['resolveTime'] as String?,
      compareComponent: json['compareComponent'] as String?,
      compareMonitorPoint: json['compareMonitorPoint'] as String?,
      compareDataTime: json['compareDataTime'] as String?,
      compareMinTemperature: (json['compareMinTemperature'] as num?)?.toDouble(),
      compareMaxTemperature: (json['compareMaxTemperature'] as num?)?.toDouble(),
      compareAveTemperature: (json['compareAveTemperature'] as num?)?.toDouble(),
      imagePath: json['imagePath'] as String?,
    );
  }
}

class CompareTypeObjectDto {
  final int? id;
  final String? code;
  final String? name;

  CompareTypeObjectDto({this.id, this.code, this.name});

  factory CompareTypeObjectDto.fromJson(Map<String, dynamic> json) {
    return CompareTypeObjectDto(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }
}

class CompareResultObjectDto {
  final int? id;
  final String? code;
  final String? name;

  CompareResultObjectDto({this.id, this.code, this.name});

  factory CompareResultObjectDto.fromJson(Map<String, dynamic> json) {
    return CompareResultObjectDto(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }
}

class StatusObjectDto {
  final int? id;
  final String? code;
  final String? name;

  StatusObjectDto({this.id, this.code, this.name});

  factory StatusObjectDto.fromJson(Map<String, dynamic> json) {
    return StatusObjectDto(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }
}
