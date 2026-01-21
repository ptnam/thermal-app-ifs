/// =============================================================================
/// File: thermal_data_bloc.dart
/// Description: Thermal Data BLoC for temperature monitoring
///
/// Purpose:
/// - Handle thermal data operations
/// - Dashboard, charts, lists, real-time data
/// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/thermal_data_repository.dart';
import '../../../core/logger/app_logger.dart';
import 'thermal_data_event.dart';
import 'thermal_data_state.dart';

/// BLoC for managing Thermal Data operations
///
/// Handles:
/// - Dashboard summary with temperature statistics
/// - Temperature data list with pagination
/// - Chart data for visualization
/// - Latest temperature readings
class ThermalDataBloc extends Bloc<ThermalDataEvent, ThermalDataState> {
  ThermalDataBloc({
    required IThermalDataRepository thermalDataRepository,
    AppLogger? logger,
  }) : _thermalDataRepository = thermalDataRepository,
       _logger = logger ?? AppLogger(tag: 'ThermalDataBloc'),
       super(const ThermalDataState()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<LoadThermalDataListEvent>(_onLoadThermalDataList);
    on<LoadMoreThermalDataEvent>(_onLoadMoreThermalData);
    on<LoadChartDataEvent>(_onLoadChartData);
    on<LoadThermalDataByComponentEvent>(_onLoadThermalDataByComponent);
    on<LoadLatestDataEvent>(_onLoadLatestData);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
    on<ClearChartDataEvent>(_onClearChartData);
    on<LoadDetailThermalDataMultiEvent>(_onLoadDetailThermalDataMulti);
    on<LoadEnvironmentThermalEvent>(_onLoadEnvironmentThermal);
  }

  final IThermalDataRepository _thermalDataRepository;
  final AppLogger _logger;

  // ─────────────────────────────────────────────────────────────────────────
  // Event Handlers
  // ─────────────────────────────────────────────────────────────────────────

  /// Handle: Load dashboard summary
  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<ThermalDataState> emit,
  ) async {
    _logger.info('Loading thermal dashboard');
    emit(
      state.copyWith(
        dashboardStatus: ThermalDataStatus.loading,
        clearError: true,
      ),
    );

    final result = await _thermalDataRepository.getDashboard(
      areaId: event.areaId,
      machineId: event.machineId,
    );

    result.fold(
      (error) {
        _logger.error('Failed to load dashboard: ${error.message}');
        emit(
          state.copyWith(
            dashboardStatus: ThermalDataStatus.failure,
            errorMessage: error.message,
          ),
        );
      },
      (dashboard) {
        _logger.info(
          'Dashboard loaded: ${dashboard.totalMachines} machines, '
          '${dashboard.normalCount} normal, ${dashboard.warningCount} warning, '
          '${dashboard.dangerCount} danger',
        );
        emit(
          state.copyWith(
            dashboardStatus: ThermalDataStatus.success,
            dashboard: dashboard,
          ),
        );
      },
    );
  }

  /// Handle: Load thermal data list
  Future<void> _onLoadThermalDataList(
    LoadThermalDataListEvent event,
    Emitter<ThermalDataState> emit,
  ) async {
    _logger.info('Loading thermal data list: page=${event.page}');
    emit(
      state.copyWith(
        listStatus: ThermalDataStatus.loading,
        filterMachineComponentId: event.machineComponentId,
        filterMachineId: event.machineId,
        filterLevel: event.level,
        filterFromDate: event.fromDate,
        filterToDate: event.toDate,
        clearError: true,
      ),
    );

    final result = await _thermalDataRepository.getThermalDataList(
      page: event.page,
      pageSize: event.pageSize,
      machineComponentId: event.machineComponentId,
      machineId: event.machineId,
      level: event.level,
      fromDate: event.fromDate,
      toDate: event.toDate,
    );

    result.fold(
      (error) {
        _logger.error('Failed to load thermal data: ${error.message}');
        emit(
          state.copyWith(
            listStatus: ThermalDataStatus.failure,
            errorMessage: error.message,
          ),
        );
      },
      (response) {
        _logger.info('Loaded ${response.data.length} thermal records');
        emit(
          state.copyWith(
            listStatus: ThermalDataStatus.success,
            thermalDataList: response.data,
            currentPage: response.currentPage,
            pageSize: response.pageSize,
            totalRecords: response.totalRecords,
            totalPages: response.totalPages,
            hasMore: response.currentPage < response.totalPages,
          ),
        );
      },
    );
  }

  /// Handle: Load more thermal data
  Future<void> _onLoadMoreThermalData(
    LoadMoreThermalDataEvent event,
    Emitter<ThermalDataState> emit,
  ) async {
    if (!state.hasMore || state.listStatus == ThermalDataStatus.loading) return;

    final nextPage = state.currentPage + 1;
    _logger.info('Loading more thermal data: page=$nextPage');

    final result = await _thermalDataRepository.getThermalDataList(
      page: nextPage,
      pageSize: state.pageSize,
      machineComponentId: state.filterMachineComponentId,
      machineId: state.filterMachineId,
      level: state.filterLevel,
      fromDate: state.filterFromDate,
      toDate: state.filterToDate,
    );

    result.fold((error) => emit(state.copyWith(errorMessage: error.message)), (
      response,
    ) {
      emit(
        state.copyWith(
          thermalDataList: [...state.thermalDataList, ...response.data],
          currentPage: response.currentPage,
          hasMore: response.currentPage < response.totalPages,
        ),
      );
    });
  }

  /// Handle: Load chart data
  Future<void> _onLoadChartData(
    LoadChartDataEvent event,
    Emitter<ThermalDataState> emit,
  ) async {
    _logger.info('═══════════════════════════════════════');
    _logger.info('📊 LOADING CHART DATA');
    _logger.info('Component IDs: ${event.machineComponentIds}');
    _logger.info('From: ${event.fromDate}');
    _logger.info('To: ${event.toDate}');
    _logger.info('Interval: ${event.interval}');
    _logger.info('═══════════════════════════════════════');

    emit(
      state.copyWith(chartStatus: ThermalDataStatus.loading, clearError: true),
    );

    final result = await _thermalDataRepository.getChartData(
      machineComponentIds: event.machineComponentIds,
      fromDate: event.fromDate,
      toDate: event.toDate,
      interval: event.interval,
    );

    result.fold(
      (error) {
        _logger.error('═══════════════════════════════════════');
        _logger.error('❌ CHART DATA FAILED');
        _logger.error('Error: ${error.message}');
        _logger.error('Code: ${error.code}');
        _logger.error('═══════════════════════════════════════');
        emit(
          state.copyWith(
            chartStatus: ThermalDataStatus.failure,
            errorMessage: error.message,
          ),
        );
      },
      (charts) {
        _logger.info('═══════════════════════════════════════');
        _logger.info('✅ CHART DATA SUCCESS');
        _logger.info('Total charts: ${charts.length}');
        for (var i = 0; i < charts.length; i++) {
          final chart = charts[i];
          _logger.info('--- Chart ${i + 1} ---');
          _logger.info('  Name: ${chart.name}');
          _logger.info('  Component ID: ${chart.machineComponentId}');
          _logger.info('  Data points: ${chart.dataPoints.length}');
          if (chart.dataPoints.isNotEmpty) {
            _logger.info(
              '  First: ${chart.dataPoints.first.time} = ${chart.dataPoints.first.value}',
            );
            _logger.info(
              '  Last: ${chart.dataPoints.last.time} = ${chart.dataPoints.last.value}',
            );
          }
        }
        _logger.info('═══════════════════════════════════════');
        emit(
          state.copyWith(
            chartStatus: ThermalDataStatus.success,
            chartData: charts,
          ),
        );
      },
    );
  }

  /// Handle: Load thermal data by component
  Future<void> _onLoadThermalDataByComponent(
    LoadThermalDataByComponentEvent event,
    Emitter<ThermalDataState> emit,
  ) async {
    _logger.info(
      'Loading thermal data for component: ${event.machineComponentId}',
    );
    emit(
      state.copyWith(listStatus: ThermalDataStatus.loading, clearError: true),
    );

    final result = await _thermalDataRepository.getThermalDataByComponent(
      machineComponentId: event.machineComponentId,
      fromDate: event.fromDate,
      toDate: event.toDate,
    );

    result.fold(
      (error) {
        _logger.error('Failed to load component data: ${error.message}');
        emit(
          state.copyWith(
            listStatus: ThermalDataStatus.failure,
            errorMessage: error.message,
          ),
        );
      },
      (data) {
        _logger.info('Loaded ${data.length} records for component');
        emit(
          state.copyWith(
            listStatus: ThermalDataStatus.success,
            thermalDataList: data,
          ),
        );
      },
    );
  }

  /// Handle: Load latest data
  Future<void> _onLoadLatestData(
    LoadLatestDataEvent event,
    Emitter<ThermalDataState> emit,
  ) async {
    _logger.info(
      'Loading latest data for component: ${event.machineComponentId}',
    );
    emit(state.copyWith(latestStatus: ThermalDataStatus.loading));

    final result = await _thermalDataRepository.getLatestData(
      event.machineComponentId,
    );

    result.fold(
      (error) {
        _logger.error('Failed to load latest data: ${error.message}');
        emit(
          state.copyWith(
            latestStatus: ThermalDataStatus.failure,
            errorMessage: error.message,
          ),
        );
      },
      (data) {
        _logger.info('Latest data loaded: ${data.maxTemperature}°C');
        emit(
          state.copyWith(
            latestStatus: ThermalDataStatus.success,
            latestData: data,
          ),
        );
      },
    );
  }

  /// Handle: Refresh dashboard
  void _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<ThermalDataState> emit,
  ) {
    add(const LoadDashboardEvent());
  }

  /// Handle: Clear chart data
  void _onClearChartData(
    ClearChartDataEvent event,
    Emitter<ThermalDataState> emit,
  ) {
    emit(state.copyWith(clearChartData: true));
  }

  /// Handle: Load multi-component thermal data
  Future<void> _onLoadDetailThermalDataMulti(
    LoadDetailThermalDataMultiEvent event,
    Emitter<ThermalDataState> emit,
  ) async {
    _logger.info('═══════════════════════════════════════');
    _logger.info('📊 LOADING MULTI THERMAL DATA');
    _logger.info('Area ID: ${event.areaId}');
    _logger.info('Machine IDs: ${event.machineIds}');
    _logger.info('Component IDs: ${event.machineComponentIds}');
    _logger.info('Report Date: ${event.reportDate}');
    _logger.info('═══════════════════════════════════════');

    emit(
      state.copyWith(
        multiDataStatus: ThermalDataStatus.loading,
        clearError: true,
      ),
    );

    final result = await _thermalDataRepository.getDetailThermalDataMulti(
      areaId: event.areaId,
      machineIds: event.machineIds,
      machineComponentIds: event.machineComponentIds,
      reportDate: event.reportDate,
      startDate: event.startDate,
      endDate: event.endDate,
      userId: event.userId,
      id: event.id,
    );

    result.fold(
      (error) {
        _logger.error('═══════════════════════════════════════');
        _logger.error('❌ MULTI THERMAL DATA FAILED');
        _logger.error('Error: ${error.message}');
        _logger.error('═══════════════════════════════════════');
        emit(
          state.copyWith(
            multiDataStatus: ThermalDataStatus.failure,
            errorMessage: error.message,
          ),
        );
      },
      (data) {
        _logger.info('═══════════════════════════════════════');
        _logger.info('✅ MULTI THERMAL DATA SUCCESS');
        _logger.info('Categories: ${data.categories.length}');
        _logger.info('Chart series: ${data.chartData.length}');
        for (var i = 0; i < data.chartData.length; i++) {
          final series = data.chartData[i];
          _logger.info('--- Series ${i + 1} ---');
          _logger.info('  Name: ${series.name}');
          _logger.info('  Data points: ${series.data.length}');
        }
        _logger.info('═══════════════════════════════════════');
        emit(
          state.copyWith(
            multiDataStatus: ThermalDataStatus.success,
            multiThermalData: data,
          ),
        );
      },
    );
  }

  /// Handle: Load environment thermal data
  Future<void> _onLoadEnvironmentThermal(
    LoadEnvironmentThermalEvent event,
    Emitter<ThermalDataState> emit,
  ) async {
    _logger.info('Loading environment thermal data for area: ${event.areaId}');
    emit(
      state.copyWith(
        environmentStatus: ThermalDataStatus.loading,
        clearError: true,
      ),
    );

    final result = await _thermalDataRepository.getEnvironmentThermal(
      areaId: event.areaId,
    );

    result.fold(
      (error) {
        _logger.error('Failed to load environment data: ${error.message}');
        emit(
          state.copyWith(
            environmentStatus: ThermalDataStatus.failure,
            errorMessage: error.message,
          ),
        );
      },
      (data) {
        _logger.info(
          'Environment data loaded: ${data.temperature}°C, '
          'Frequency: ${data.frequency}',
        );
        emit(
          state.copyWith(
            environmentStatus: ThermalDataStatus.success,
            environmentData: data,
          ),
        );
      },
    );
  }
}
