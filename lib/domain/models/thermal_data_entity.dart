/// =============================================================================
/// File: thermal_data_entity.dart
/// Description: Thermal data domain entity
///
/// Purpose:
/// - Pure domain model for thermal data and temperature readings
/// - Used in dashboard and monitoring features
/// =============================================================================

import 'machine_entity.dart';

/// Domain entity representing a Thermal Data reading
class ThermalDataEntity {
  final int id;
  final int? machineComponentId;
  final String? machineComponentName;
  final int? machineId;
  final String? machineName;
  final double? maxTemperature;
  final double? minTemperature;
  final double? avgTemperature;
  final TemperatureLevelEntity level;
  final DateTime dataTime;
  final DateTime? createdAt;

  const ThermalDataEntity({
    required this.id,
    this.machineComponentId,
    this.machineComponentName,
    this.machineId,
    this.machineName,
    this.maxTemperature,
    this.minTemperature,
    this.avgTemperature,
    this.level = TemperatureLevelEntity.normal,
    required this.dataTime,
    this.createdAt,
  });

  bool get isDanger => level == TemperatureLevelEntity.danger;
  bool get isWarning => level == TemperatureLevelEntity.warning;
  bool get isNormal => level == TemperatureLevelEntity.normal;

  /// Get temperature range
  double? get temperatureRange {
    if (maxTemperature != null && minTemperature != null) {
      return maxTemperature! - minTemperature!;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThermalDataEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Chart data point for temperature graphs
class ChartDataPointEntity {
  final DateTime time;
  final double? value;
  final String? label;

  const ChartDataPointEntity({required this.time, this.value, this.label});
}

/// Chart output for temperature visualization
class ThermalChartEntity {
  final String? name;
  final int? machineComponentId;
  final List<ChartDataPointEntity> dataPoints;

  const ThermalChartEntity({
    this.name,
    this.machineComponentId,
    this.dataPoints = const [],
  });

  bool get hasData => dataPoints.isNotEmpty;

  /// Get max value in chart
  double? get maxValue {
    if (!hasData) return null;
    return dataPoints
        .where((p) => p.value != null)
        .map((p) => p.value!)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Get min value in chart
  double? get minValue {
    if (!hasData) return null;
    return dataPoints
        .where((p) => p.value != null)
        .map((p) => p.value!)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Get average value in chart
  double? get avgValue {
    if (!hasData) return null;
    final values = dataPoints
        .where((p) => p.value != null)
        .map((p) => p.value!)
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

/// Dashboard summary for thermal data
class ThermalDashboardEntity {
  final int totalMachines;
  final int normalCount;
  final int warningCount;
  final int dangerCount;
  final List<ThermalDataEntity> recentReadings;

  const ThermalDashboardEntity({
    this.totalMachines = 0,
    this.normalCount = 0,
    this.warningCount = 0,
    this.dangerCount = 0,
    this.recentReadings = const [],
  });

  /// Get percentage of normal readings
  double get normalPercentage {
    if (totalMachines == 0) return 0;
    return (normalCount / totalMachines) * 100;
  }

  /// Get percentage of warning readings
  double get warningPercentage {
    if (totalMachines == 0) return 0;
    return (warningCount / totalMachines) * 100;
  }

  /// Get percentage of danger readings
  double get dangerPercentage {
    if (totalMachines == 0) return 0;
    return (dangerCount / totalMachines) * 100;
  }

  bool get hasIssues => warningCount > 0 || dangerCount > 0;
}

/// Environment thermal data entity
/// Contains ambient temperature and measurement frequency
class EnvironmentThermalEntity {
  final double? temperature;
  final int? frequency;

  const EnvironmentThermalEntity({this.temperature, this.frequency});
}

/// Chart series entity for multi-component thermal data
class ThermalChartSeriesEntity {
  final String name;
  final List<double> data;

  const ThermalChartSeriesEntity({required this.name, required this.data});
}

/// Multi-component thermal data entity
/// Contains time categories and chart series for each component
class ThermalDataMultiEntity {
  final List<String> categories;
  final List<ThermalChartSeriesEntity> chartData;

  const ThermalDataMultiEntity({
    required this.categories,
    required this.chartData,
  });

  bool get hasData => chartData.isNotEmpty && categories.isNotEmpty;
}
