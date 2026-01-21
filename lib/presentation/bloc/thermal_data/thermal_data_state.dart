/// =============================================================================
/// File: thermal_data_state.dart
/// Description: Thermal Data BLoC states
///
/// Purpose:
/// - Define all possible states for ThermalDataBloc
/// =============================================================================

import 'package:equatable/equatable.dart';
import 'package:thermal_mobile/domain/models/thermal_data_entity.dart';

/// Status of async operations
enum ThermalDataStatus { initial, loading, success, failure }

/// State class for Thermal Data BLoC
class ThermalDataState extends Equatable {
  // ─────────────────────────────────────────────────────────────────────────
  // Status Flags
  // ─────────────────────────────────────────────────────────────────────────

  /// Dashboard loading status
  final ThermalDataStatus dashboardStatus;

  /// List loading status
  final ThermalDataStatus listStatus;

  /// Chart loading status
  final ThermalDataStatus chartStatus;

  /// Latest data loading status
  final ThermalDataStatus latestStatus;

  /// Multi thermal data loading status
  final ThermalDataStatus multiDataStatus;

  /// Environment thermal data loading status
  final ThermalDataStatus environmentStatus;

  // ─────────────────────────────────────────────────────────────────────────
  // Data
  // ─────────────────────────────────────────────────────────────────────────

  /// Dashboard summary
  final ThermalDashboardEntity? dashboard;

  /// List of thermal data
  final List<ThermalDataEntity> thermalDataList;

  /// Chart data for visualization
  final List<ThermalChartEntity> chartData;

  /// Latest thermal data by component
  final ThermalDataEntity? latestData;

  /// Multi-component thermal data
  final ThermalDataMultiEntity? multiThermalData;

  /// Environment thermal data
  final EnvironmentThermalEntity? environmentData;

  // ─────────────────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────────────────

  final int currentPage;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final bool hasMore;

  // ─────────────────────────────────────────────────────────────────────────
  // Filters
  // ─────────────────────────────────────────────────────────────────────────

  final int? filterMachineComponentId;
  final int? filterMachineId;
  final int? filterLevel;
  final DateTime? filterFromDate;
  final DateTime? filterToDate;

  // ─────────────────────────────────────────────────────────────────────────
  // Messages
  // ─────────────────────────────────────────────────────────────────────────

  final String? errorMessage;

  const ThermalDataState({
    this.dashboardStatus = ThermalDataStatus.initial,
    this.listStatus = ThermalDataStatus.initial,
    this.chartStatus = ThermalDataStatus.initial,
    this.latestStatus = ThermalDataStatus.initial,
    this.multiDataStatus = ThermalDataStatus.initial,
    this.environmentStatus = ThermalDataStatus.initial,
    this.dashboard,
    this.thermalDataList = const [],
    this.chartData = const [],
    this.latestData,
    this.multiThermalData,
    this.environmentData,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalRecords = 0,
    this.totalPages = 0,
    this.hasMore = false,
    this.filterMachineComponentId,
    this.filterMachineId,
    this.filterLevel,
    this.filterFromDate,
    this.filterToDate,
    this.errorMessage,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  bool get isLoading =>
      dashboardStatus == ThermalDataStatus.loading ||
      listStatus == ThermalDataStatus.loading ||
      chartStatus == ThermalDataStatus.loading;

  bool get hasDashboard =>
      dashboardStatus == ThermalDataStatus.success && dashboard != null;

  bool get hasChartData =>
      chartStatus == ThermalDataStatus.success && chartData.isNotEmpty;

  bool get isEmpty =>
      thermalDataList.isEmpty && listStatus == ThermalDataStatus.success;

  bool get hasError => errorMessage != null;

  ThermalDataState copyWith({
    ThermalDataStatus? dashboardStatus,
    ThermalDataStatus? listStatus,
    ThermalDataStatus? chartStatus,
    ThermalDataStatus? latestStatus,
    ThermalDataStatus? multiDataStatus,
    ThermalDataStatus? environmentStatus,
    ThermalDashboardEntity? dashboard,
    List<ThermalDataEntity>? thermalDataList,
    List<ThermalChartEntity>? chartData,
    ThermalDataEntity? latestData,
    ThermalDataMultiEntity? multiThermalData,
    EnvironmentThermalEntity? environmentData,
    int? currentPage,
    int? pageSize,
    int? totalRecords,
    int? totalPages,
    bool? hasMore,
    int? filterMachineComponentId,
    int? filterMachineId,
    int? filterLevel,
    DateTime? filterFromDate,
    DateTime? filterToDate,
    String? errorMessage,
    bool clearError = false,
    bool clearChartData = false,
  }) {
    return ThermalDataState(
      dashboardStatus: dashboardStatus ?? this.dashboardStatus,
      listStatus: listStatus ?? this.listStatus,
      chartStatus: chartStatus ?? this.chartStatus,
      latestStatus: latestStatus ?? this.latestStatus,
      multiDataStatus: multiDataStatus ?? this.multiDataStatus,
      environmentStatus: environmentStatus ?? this.environmentStatus,
      dashboard: dashboard ?? this.dashboard,
      thermalDataList: thermalDataList ?? this.thermalDataList,
      chartData: clearChartData ? const [] : (chartData ?? this.chartData),
      latestData: latestData ?? this.latestData,
      multiThermalData: multiThermalData ?? this.multiThermalData,
      environmentData: environmentData ?? this.environmentData,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      filterMachineComponentId:
          filterMachineComponentId ?? this.filterMachineComponentId,
      filterMachineId: filterMachineId ?? this.filterMachineId,
      filterLevel: filterLevel ?? this.filterLevel,
      filterFromDate: filterFromDate ?? this.filterFromDate,
      filterToDate: filterToDate ?? this.filterToDate,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    dashboardStatus,
    listStatus,
    chartStatus,
    latestStatus,
    multiDataStatus,
    environmentStatus,
    dashboard,
    thermalDataList,
    chartData,
    latestData,
    multiThermalData,
    environmentData,
    currentPage,
    pageSize,
    totalRecords,
    totalPages,
    hasMore,
    filterMachineComponentId,
    filterMachineId,
    filterLevel,
    filterFromDate,
    filterToDate,
    errorMessage,
  ];
}
