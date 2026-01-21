import 'package:json_annotation/json_annotation.dart';

part 'machine_result_dto.g.dart';

/// Response wrapper for machines and result API
@JsonSerializable()
class MachinesAndResultResponse {
  final List<MachineResultDto> item1;
  final List<dynamic> item2;

  MachinesAndResultResponse({
    required this.item1,
    required this.item2,
  });

  factory MachinesAndResultResponse.fromJson(Map<String, dynamic> json) =>
      _$MachinesAndResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MachinesAndResultResponseToJson(this);
}

/// DTO for machine position and result data
@JsonSerializable()
class MachineResultDto {
  final String key;
  final int machineId;
  final String deviceType;
  final String deviceTypeName;
  final String monitorPointIcon;
  final double longitude;
  final double latitude;
  final String level;
  final String code;
  final String name;
  final int id;

  MachineResultDto({
    required this.key,
    required this.machineId,
    required this.deviceType,
    required this.deviceTypeName,
    required this.monitorPointIcon,
    required this.longitude,
    required this.latitude,
    required this.level,
    required this.code,
    required this.name,
    required this.id,
  });

  factory MachineResultDto.fromJson(Map<String, dynamic> json) =>
      _$MachineResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MachineResultDtoToJson(this);
}

/// DTO for thermal component data
@JsonSerializable()
class ThermalComponentDto {
  final String dateData;
  final String timeData;
  final String? areaName;
  final String? machineName;
  final double temperature;
  final Map<String, ThermalResultDto> dicThermalDataResults;
  final String dataSourceType;
  final double minTemperature;
  final double maxTemperature;
  final double aveTemperature;
  final String machineComponentName;
  final String monitorPointCode;
  final int orderNumber;
  final String? imageData;

  ThermalComponentDto({
    required this.dateData,
    required this.timeData,
    this.areaName,
    this.machineName,
    required this.temperature,
    required this.dicThermalDataResults,
    required this.dataSourceType,
    required this.minTemperature,
    required this.maxTemperature,
    required this.aveTemperature,
    required this.machineComponentName,
    required this.monitorPointCode,
    required this.orderNumber,
    this.imageData,
  });

  factory ThermalComponentDto.fromJson(Map<String, dynamic> json) =>
      _$ThermalComponentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ThermalComponentDtoToJson(this);
}

/// DTO for thermal result data
@JsonSerializable()
class ThermalResultDto {
  final double? compareValue;
  final double? deltaValue;
  final String? compareComponent;
  final String? compareMonitorPoint;
  final String? compareDataTime;
  final double? compareMinTemperature;
  final double? compareMaxTemperature;
  final double? compareAveTemperature;
  final CompareTypeDto? compareTypeObject;
  final CompareResultDto? compareResultObject;
  final ComparationThermalDataDto? comparationThermalData;

  ThermalResultDto({
    this.compareValue,
    this.deltaValue,
    this.compareComponent,
    this.compareMonitorPoint,
    this.compareDataTime,
    this.compareMinTemperature,
    this.compareMaxTemperature,
    this.compareAveTemperature,
    this.compareTypeObject,
    this.compareResultObject,
    this.comparationThermalData,
  });

  factory ThermalResultDto.fromJson(Map<String, dynamic> json) =>
      _$ThermalResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ThermalResultDtoToJson(this);
}

@JsonSerializable()
class CompareTypeDto {
  final int id;
  final String code;
  final String name;

  CompareTypeDto({
    required this.id,
    required this.code,
    required this.name,
  });

  factory CompareTypeDto.fromJson(Map<String, dynamic> json) =>
      _$CompareTypeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CompareTypeDtoToJson(this);
}

@JsonSerializable()
class CompareResultDto {
  final int id;
  final String code;
  final String name;

  CompareResultDto({
    required this.id,
    required this.code,
    required this.name,
  });

  factory CompareResultDto.fromJson(Map<String, dynamic> json) =>
      _$CompareResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CompareResultDtoToJson(this);
}

@JsonSerializable()
class ComparationThermalDataDto {
  final String comparationType;
  final String comparationComponentName;
  final double minTemperature;
  final double maxTemperature;
  final double aveTemperature;
  final String comparationDataTime;

  ComparationThermalDataDto({
    required this.comparationType,
    required this.comparationComponentName,
    required this.minTemperature,
    required this.maxTemperature,
    required this.aveTemperature,
    required this.comparationDataTime,
  });

  factory ComparationThermalDataDto.fromJson(Map<String, dynamic> json) =>
      _$ComparationThermalDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ComparationThermalDataDtoToJson(this);
}
