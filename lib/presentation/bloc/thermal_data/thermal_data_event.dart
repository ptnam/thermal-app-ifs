/// =============================================================================
/// File: thermal_data_event.dart
/// Description: Thermal Data BLoC events
///
/// Purpose:
/// - Define all events for thermal data operations
/// =============================================================================

import 'package:equatable/equatable.dart';

/// Base class for all thermal data events
abstract class ThermalDataEvent extends Equatable {
  const ThermalDataEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load dashboard summary
class LoadDashboardEvent extends ThermalDataEvent {
  final int? areaId;
  final int? machineId;

  const LoadDashboardEvent({this.areaId, this.machineId});

  @override
  List<Object?> get props => [areaId, machineId];
}

/// Event: Load thermal data list
class LoadThermalDataListEvent extends ThermalDataEvent {
  final int page;
  final int pageSize;
  final int? machineComponentId;
  final int? machineId;
  final int? level;
  final DateTime? fromDate;
  final DateTime? toDate;

  const LoadThermalDataListEvent({
    this.page = 1,
    this.pageSize = 10,
    this.machineComponentId,
    this.machineId,
    this.level,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [
    page,
    pageSize,
    machineComponentId,
    machineId,
    level,
    fromDate,
    toDate,
  ];
}

/// Event: Load more thermal data
class LoadMoreThermalDataEvent extends ThermalDataEvent {
  const LoadMoreThermalDataEvent();
}

/// Event: Load chart data
class LoadChartDataEvent extends ThermalDataEvent {
  final List<int> machineComponentIds;
  final DateTime fromDate;
  final DateTime toDate;
  final String? interval;

  const LoadChartDataEvent({
    required this.machineComponentIds,
    required this.fromDate,
    required this.toDate,
    this.interval,
  });

  @override
  List<Object?> get props => [machineComponentIds, fromDate, toDate, interval];
}

/// Event: Load thermal data by component
class LoadThermalDataByComponentEvent extends ThermalDataEvent {
  final int machineComponentId;
  final DateTime? fromDate;
  final DateTime? toDate;

  const LoadThermalDataByComponentEvent({
    required this.machineComponentId,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [machineComponentId, fromDate, toDate];
}

/// Event: Load latest data for component
class LoadLatestDataEvent extends ThermalDataEvent {
  final int machineComponentId;

  const LoadLatestDataEvent(this.machineComponentId);

  @override
  List<Object?> get props => [machineComponentId];
}

/// Event: Refresh dashboard
class RefreshDashboardEvent extends ThermalDataEvent {
  const RefreshDashboardEvent();
}

/// Event: Clear chart data
class ClearChartDataEvent extends ThermalDataEvent {
  const ClearChartDataEvent();
}

/// Event: Load multi-component thermal data
class LoadDetailThermalDataMultiEvent extends ThermalDataEvent {
  final int areaId;
  final List<int> machineIds;
  final List<int> machineComponentIds;
  final String reportDate;
  final String startDate;
  final String endDate;
  final int userId;
  final int id;

  const LoadDetailThermalDataMultiEvent({
    required this.areaId,
    required this.machineIds,
    required this.machineComponentIds,
    required this.reportDate,
    required this.startDate,
    required this.endDate,
    required this.userId,
    this.id = 0,
  });

  @override
  List<Object?> get props => [
    areaId,
    machineIds,
    machineComponentIds,
    reportDate,
    startDate,
    endDate,
    userId,
    id,
  ];
}

/// Event: Load environment thermal data
class LoadEnvironmentThermalEvent extends ThermalDataEvent {
  final int areaId;

  const LoadEnvironmentThermalEvent({required this.areaId});

  @override
  List<Object?> get props => [areaId];
}
