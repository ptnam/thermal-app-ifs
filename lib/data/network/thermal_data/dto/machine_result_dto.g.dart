// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MachinesAndResultResponse _$MachinesAndResultResponseFromJson(
  Map<String, dynamic> json,
) => MachinesAndResultResponse(
  item1: (json['item1'] as List<dynamic>)
      .map((e) => MachineResultDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  item2: json['item2'] as List<dynamic>,
);

Map<String, dynamic> _$MachinesAndResultResponseToJson(
  MachinesAndResultResponse instance,
) => <String, dynamic>{'item1': instance.item1, 'item2': instance.item2};

MachineResultDto _$MachineResultDtoFromJson(Map<String, dynamic> json) =>
    MachineResultDto(
      key: json['key'] as String,
      machineId: (json['machineId'] as num).toInt(),
      deviceType: json['deviceType'] as String,
      deviceTypeName: json['deviceTypeName'] as String,
      monitorPointIcon: json['monitorPointIcon'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      level: json['level'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$MachineResultDtoToJson(MachineResultDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'machineId': instance.machineId,
      'deviceType': instance.deviceType,
      'deviceTypeName': instance.deviceTypeName,
      'monitorPointIcon': instance.monitorPointIcon,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'level': instance.level,
      'code': instance.code,
      'name': instance.name,
      'id': instance.id,
    };

ThermalComponentDto _$ThermalComponentDtoFromJson(Map<String, dynamic> json) =>
    ThermalComponentDto(
      dateData: json['dateData'] as String,
      timeData: json['timeData'] as String,
      areaName: json['areaName'] as String?,
      machineName: json['machineName'] as String?,
      temperature: (json['temperature'] as num).toDouble(),
      dicThermalDataResults:
          (json['dicThermalDataResults'] as Map<String, dynamic>).map(
            (k, e) => MapEntry(
              k,
              ThermalResultDto.fromJson(e as Map<String, dynamic>),
            ),
          ),
      dataSourceType: json['dataSourceType'] as String,
      minTemperature: (json['minTemperature'] as num).toDouble(),
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      aveTemperature: (json['aveTemperature'] as num).toDouble(),
      machineComponentName: json['machineComponentName'] as String,
      monitorPointCode: json['monitorPointCode'] as String,
      orderNumber: (json['orderNumber'] as num).toInt(),
      imageData: json['imageData'] as String?,
    );

Map<String, dynamic> _$ThermalComponentDtoToJson(
  ThermalComponentDto instance,
) => <String, dynamic>{
  'dateData': instance.dateData,
  'timeData': instance.timeData,
  'areaName': instance.areaName,
  'machineName': instance.machineName,
  'temperature': instance.temperature,
  'dicThermalDataResults': instance.dicThermalDataResults,
  'dataSourceType': instance.dataSourceType,
  'minTemperature': instance.minTemperature,
  'maxTemperature': instance.maxTemperature,
  'aveTemperature': instance.aveTemperature,
  'machineComponentName': instance.machineComponentName,
  'monitorPointCode': instance.monitorPointCode,
  'orderNumber': instance.orderNumber,
  'imageData': instance.imageData,
};

ThermalResultDto _$ThermalResultDtoFromJson(
  Map<String, dynamic> json,
) => ThermalResultDto(
  compareValue: (json['compareValue'] as num?)?.toDouble(),
  deltaValue: (json['deltaValue'] as num?)?.toDouble(),
  compareComponent: json['compareComponent'] as String?,
  compareMonitorPoint: json['compareMonitorPoint'] as String?,
  compareDataTime: json['compareDataTime'] as String?,
  compareMinTemperature: (json['compareMinTemperature'] as num?)?.toDouble(),
  compareMaxTemperature: (json['compareMaxTemperature'] as num?)?.toDouble(),
  compareAveTemperature: (json['compareAveTemperature'] as num?)?.toDouble(),
  compareTypeObject: json['compareTypeObject'] == null
      ? null
      : CompareTypeDto.fromJson(
          json['compareTypeObject'] as Map<String, dynamic>,
        ),
  compareResultObject: json['compareResultObject'] == null
      ? null
      : CompareResultDto.fromJson(
          json['compareResultObject'] as Map<String, dynamic>,
        ),
  comparationThermalData: json['comparationThermalData'] == null
      ? null
      : ComparationThermalDataDto.fromJson(
          json['comparationThermalData'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ThermalResultDtoToJson(ThermalResultDto instance) =>
    <String, dynamic>{
      'compareValue': instance.compareValue,
      'deltaValue': instance.deltaValue,
      'compareComponent': instance.compareComponent,
      'compareMonitorPoint': instance.compareMonitorPoint,
      'compareDataTime': instance.compareDataTime,
      'compareMinTemperature': instance.compareMinTemperature,
      'compareMaxTemperature': instance.compareMaxTemperature,
      'compareAveTemperature': instance.compareAveTemperature,
      'compareTypeObject': instance.compareTypeObject,
      'compareResultObject': instance.compareResultObject,
      'comparationThermalData': instance.comparationThermalData,
    };

CompareTypeDto _$CompareTypeDtoFromJson(Map<String, dynamic> json) =>
    CompareTypeDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$CompareTypeDtoToJson(CompareTypeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
    };

CompareResultDto _$CompareResultDtoFromJson(Map<String, dynamic> json) =>
    CompareResultDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$CompareResultDtoToJson(CompareResultDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
    };

ComparationThermalDataDto _$ComparationThermalDataDtoFromJson(
  Map<String, dynamic> json,
) => ComparationThermalDataDto(
  comparationType: json['comparationType'] as String,
  comparationComponentName: json['comparationComponentName'] as String,
  minTemperature: (json['minTemperature'] as num).toDouble(),
  maxTemperature: (json['maxTemperature'] as num).toDouble(),
  aveTemperature: (json['aveTemperature'] as num).toDouble(),
  comparationDataTime: json['comparationDataTime'] as String,
);

Map<String, dynamic> _$ComparationThermalDataDtoToJson(
  ComparationThermalDataDto instance,
) => <String, dynamic>{
  'comparationType': instance.comparationType,
  'comparationComponentName': instance.comparationComponentName,
  'minTemperature': instance.minTemperature,
  'maxTemperature': instance.maxTemperature,
  'aveTemperature': instance.aveTemperature,
  'comparationDataTime': instance.comparationDataTime,
};
