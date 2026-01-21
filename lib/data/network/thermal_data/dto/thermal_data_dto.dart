import 'package:thermal_mobile/data/network/api/base_dto.dart';

/// =============================================================================
/// File: thermal_data_dto.dart
/// Description: Thermal Data transfer objects for ThermalData API
///
/// Purpose:
/// - Maps to backend's ThermalData DTOs
/// - Used for thermal monitoring data operations
/// - Contains temperature, chart, and analysis data
/// =============================================================================

/// Thermal data detail extend DTO
/// Contains detailed thermal reading information
class ThermalDataDetailExtend {
  final String? id;
  final int? machineId;
  final String? machineName;
  final int? machineComponentId;
  final String? machineComponentName;
  final int? monitorPointId;
  final String? monitorPointName;
  final MonitorPointType? monitorPointType;
  final double? temperature;
  final double? ambientTemperature;
  final double? delta;
  final TemperatureLevel? temperatureLevel;
  final DateTime? dataTime;
  final String? thermalImage;

  const ThermalDataDetailExtend({
    this.id,
    this.machineId,
    this.machineName,
    this.machineComponentId,
    this.machineComponentName,
    this.monitorPointId,
    this.monitorPointName,
    this.monitorPointType,
    this.temperature,
    this.ambientTemperature,
    this.delta,
    this.temperatureLevel,
    this.dataTime,
    this.thermalImage,
  });

  factory ThermalDataDetailExtend.fromJson(Map<String, dynamic> json) {
    return ThermalDataDetailExtend(
      id: json['id'] as String?,
      machineId: json['machineId'] as int?,
      machineName: json['machineName'] as String?,
      machineComponentId: json['machineComponentId'] as int?,
      machineComponentName: json['machineComponentName'] as String?,
      monitorPointId: json['monitorPointId'] as int?,
      monitorPointName: json['monitorPointName'] as String?,
      monitorPointType: json['monitorPointType'] != null
          ? MonitorPointType.fromValue(json['monitorPointType'] as int)
          : null,
      temperature: (json['temperature'] as num?)?.toDouble(),
      ambientTemperature: (json['ambientTemperature'] as num?)?.toDouble(),
      delta: (json['delta'] as num?)?.toDouble(),
      temperatureLevel: json['temperatureLevel'] != null
          ? TemperatureLevel.fromValue(json['temperatureLevel'] as int)
          : null,
      dataTime: json['dataTime'] != null
          ? DateTime.tryParse(json['dataTime'] as String)
          : null,
      thermalImage: json['thermalImage'] as String?,
    );
  }
}

/// Thermal data extend DTO for grouped data
class ThermalDataExtend {
  final int? machineId;
  final String? machineName;
  final int? machineComponentId;
  final String? machineComponentName;
  final List<ThermalDataDetailExtend>? details;

  const ThermalDataExtend({
    this.machineId,
    this.machineName,
    this.machineComponentId,
    this.machineComponentName,
    this.details,
  });

  factory ThermalDataExtend.fromJson(Map<String, dynamic> json) {
    return ThermalDataExtend(
      machineId: json['machineId'] as int?,
      machineName: json['machineName'] as String?,
      machineComponentId: json['machineComponentId'] as int?,
      machineComponentName: json['machineComponentName'] as String?,
      details: (json['details'] as List<dynamic>?)
          ?.map(
            (e) => ThermalDataDetailExtend.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

/// Machine component with position info
class ShortenMachineComponentDto {
  final int id;
  final String? name;
  final int? machineId;
  final String? machineName;
  final double? positionX;
  final double? positionY;
  final TemperatureLevel? temperatureLevel;

  const ShortenMachineComponentDto({
    required this.id,
    this.name,
    this.machineId,
    this.machineName,
    this.positionX,
    this.positionY,
    this.temperatureLevel,
  });

  factory ShortenMachineComponentDto.fromJson(Map<String, dynamic> json) {
    return ShortenMachineComponentDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      machineId: json['machineId'] as int?,
      machineName: json['machineName'] as String?,
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
      temperatureLevel: json['temperatureLevel'] != null
          ? TemperatureLevel.fromValue(json['temperatureLevel'] as int)
          : null,
    );
  }
}

/// Machine component with thermal data
class MachineComponentAndThermalDatas {
  final List<ShortenMachineComponentDto>? components;
  final Map<String, List<ThermalDataDetailExtend>>? thermalDatas;

  const MachineComponentAndThermalDatas({this.components, this.thermalDatas});

  factory MachineComponentAndThermalDatas.fromJson(Map<String, dynamic> json) {
    return MachineComponentAndThermalDatas(
      components: (json['components'] as List<dynamic>?)
          ?.map(
            (e) =>
                ShortenMachineComponentDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      thermalDatas: (json['thermalDatas'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map(
                (e) =>
                    ThermalDataDetailExtend.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Chart output DTO for thermal data visualization
class ChartOutput {
  final List<ChartDataPoint>? dataPoints;
  final double? minValue;
  final double? maxValue;
  final double? avgValue;

  const ChartOutput({
    this.dataPoints,
    this.minValue,
    this.maxValue,
    this.avgValue,
  });

  factory ChartOutput.fromJson(Map<String, dynamic> json) {
    return ChartOutput(
      dataPoints: (json['dataPoints'] as List<dynamic>?)
          ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      minValue: (json['minValue'] as num?)?.toDouble(),
      maxValue: (json['maxValue'] as num?)?.toDouble(),
      avgValue: (json['avgValue'] as num?)?.toDouble(),
    );
  }
}

/// Single data point for charts
class ChartDataPoint {
  final DateTime? time;
  final double? value;
  final String? label;

  const ChartDataPoint({this.time, this.value, this.label});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      time: json['time'] != null
          ? DateTime.tryParse(json['time'] as String)
          : null,
      value: (json['value'] as num?)?.toDouble(),
      label: json['label'] as String?,
    );
  }
}

/// Environment thermal data DTO
/// Contains ambient temperature and measurement frequency
class EnvironmentThermalData {
  final double? temperature;
  final int? frequency;

  const EnvironmentThermalData({this.temperature, this.frequency});

  factory EnvironmentThermalData.fromJson(Map<String, dynamic> json) {
    return EnvironmentThermalData(
      temperature: (json['temperature'] as num?)?.toDouble(),
      frequency: json['frequency'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'temperature': temperature, 'frequency': frequency};
  }
}

/// Chart series data for multi-component thermal data
class ThermalChartSeries {
  final String name;
  final List<double> data;

  const ThermalChartSeries({required this.name, required this.data});

  factory ThermalChartSeries.fromJson(Map<String, dynamic> json) {
    return ThermalChartSeries(
      name: json['name'] as String? ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data};
  }
}

/// Multi-component thermal data response
/// Contains time categories and chart series for each component
class ThermalDataMultiResponse {
  final List<String> categories;
  final List<ThermalChartSeries> chartData;

  const ThermalDataMultiResponse({
    required this.categories,
    required this.chartData,
  });

  factory ThermalDataMultiResponse.fromJson(Map<String, dynamic> json) {
    return ThermalDataMultiResponse(
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      chartData:
          (json['chartData'] as List<dynamic>?)
              ?.map(
                (e) => ThermalChartSeries.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'chartData': chartData.map((e) => e.toJson()).toList(),
    };
  }
}
