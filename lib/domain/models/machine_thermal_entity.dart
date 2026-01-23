/// Machine result entity for domain layer
class MachineResultEntity {
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

  const MachineResultEntity({
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

  bool get isMachine => deviceType == 'Machine';
  bool get isSensor => deviceType == 'Sensor';
}

/// Evaluation result entity for component status
class EvaluationResultEntity {
  final String compareType;
  final String? resultCode;
  final String? resultName;

  const EvaluationResultEntity({
    required this.compareType,
    this.resultCode,
    this.resultName,
  });
}

/// Thermal component entity
class ThermalComponentEntity {
  final String dateData;
  final String timeData;
  final String? areaName;
  final String? machineName;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final double aveTemperature;
  final String machineComponentName;
  final String monitorPointCode;
  final int orderNumber;
  final String dataSourceType;
  final List<EvaluationResultEntity> evaluationResults;

  const ThermalComponentEntity({
    required this.dateData,
    required this.timeData,
    this.areaName,
    this.machineName,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.aveTemperature,
    required this.machineComponentName,
    required this.monitorPointCode,
    required this.orderNumber,
    required this.dataSourceType,
    this.evaluationResults = const [],
  });

  /// Get the worst evaluation status code from all results
  /// Priority: Bad > Warning > Fair > Good
  String? get worstStatusCode {
    if (evaluationResults.isEmpty) return null;
    
    const priority = {'Bad': 4, 'Warning': 3, 'Fair': 2, 'Good': 1};
    String? worstCode;
    int worstPriority = 0;
    
    for (final result in evaluationResults) {
      final code = result.resultCode;
      if (code != null) {
        final p = priority[code] ?? 0;
        if (p > worstPriority) {
          worstPriority = p;
          worstCode = code;
        }
      }
    }
    return worstCode;
  }
}

/// Machine thermal summary entity
class MachineThermalSummaryEntity {
  final MachineResultEntity machine;
  final List<ThermalComponentEntity> components;

  const MachineThermalSummaryEntity({
    required this.machine,
    required this.components,
  });

  double? get maxTemperature {
    if (components.isEmpty) return null;
    return components
        .map((c) => c.maxTemperature)
        .reduce((a, b) => a > b ? a : b);
  }

  double? get minTemperature {
    if (components.isEmpty) return null;
    return components
        .map((c) => c.minTemperature)
        .reduce((a, b) => a < b ? a : b);
  }

  ThermalComponentEntity? get hottestComponent {
    if (components.isEmpty) return null;
    return components.reduce((a, b) =>
        a.maxTemperature > b.maxTemperature ? a : b);
  }

  ThermalComponentEntity? get coldestComponent {
    if (components.isEmpty) return null;
    return components.reduce((a, b) =>
        a.minTemperature < b.minTemperature ? a : b);
  }

  /// Get the worst evaluation status code from all components
  /// Priority: Bad > Warning > Fair > Good
  /// Returns null if no evaluation data
  String? get worstStatusCode {
    if (components.isEmpty) return null;
    
    const priority = {'Bad': 4, 'Warning': 3, 'Fair': 2, 'Good': 1};
    String? worstCode;
    int worstPriority = 0;
    
    for (final component in components) {
      final code = component.worstStatusCode;
      if (code != null) {
        final p = priority[code] ?? 0;
        if (p > worstPriority) {
          worstPriority = p;
          worstCode = code;
        }
      }
    }
    return worstCode;
  }
}

/// Area thermal overview entity
class AreaThermalOverviewEntity {
  final List<MachineThermalSummaryEntity> machines;

  const AreaThermalOverviewEntity({
    required this.machines,
  });

  MachineThermalSummaryEntity? get hottestMachine {
    if (machines.isEmpty) return null;
    MachineThermalSummaryEntity? hottest;
    double? maxTemp;

    for (final machine in machines) {
      final temp = machine.maxTemperature;
      if (temp != null && (maxTemp == null || temp > maxTemp)) {
        maxTemp = temp;
        hottest = machine;
      }
    }
    return hottest;
  }

  MachineThermalSummaryEntity? get coldestMachine {
    if (machines.isEmpty) return null;
    MachineThermalSummaryEntity? coldest;
    double? minTemp;

    for (final machine in machines) {
      final temp = machine.minTemperature;
      if (temp != null && (minTemp == null || temp < minTemp)) {
        minTemp = temp;
        coldest = machine;
      }
    }
    return coldest;
  }

  double? get overallMaxTemperature {
    return hottestMachine?.maxTemperature;
  }

  double? get overallMinTemperature {
    return coldestMachine?.minTemperature;
  }
}
