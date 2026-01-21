import 'package:thermal_mobile/data/network/api/endpoints.dart';

/// =============================================================================
/// File: thermal_data_endpoints.dart
/// Description: API endpoint definitions for ThermalData operations
///
/// Purpose:
/// - Centralized endpoint management for ThermalData API
/// - Clean separation of URL construction logic
/// =============================================================================

/// ThermalData API endpoints
class ThermalDataEndpoints extends Endpoints {
  ThermalDataEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get machine component positions by area
  /// Query params: areaId
  String get machineComponentPositionByArea =>
      path('/api/ThermalDatas/machineComponentPositionByArea');

  /// GET: Get machines and result by area
  /// Query params: areaId
  String get machinesAndResultByArea =>
      path('/api/ThermalDatas/machinesAndResultByArea');

  /// GET: Get machines and thermal data by area
  /// Query params: areaId
  String get machinesAndThermalDataByArea =>
      path('/api/ThermalDatas/machinesAndThermalDataByArea');

  /// GET: Get latest thermal by machine component
  /// Query params: machineId, id, deviceType
  String get thermalByComponent => path('/api/ThermalDatas/thermalByComponent');

  /// GET: Get paginated thermal data list
  /// Query params: fromTime, toTime, areaId, machineId, machineComponentIds[],
  ///               temperatureLevel, thresholdType, deltaMin, deltaMax, page, pageSize
  String get list => path('/api/ThermalDatas/list');

  /// GET: Get paginated thermal data grouped by component
  String get listGroup => path('/api/ThermalDatas/listGroup');

  /// GET: Get thermal data details by time range
  /// Query params: machineId, machineComponentId, monitorPointId,
  ///               monitorPointType, startDate, endDate
  String get detailThermalData => path('/api/ThermalDatas/detailThermalData');

  /// GET: Get thermal data details for multiple components
  /// Query params: areaId, machineIds[], machineComponentIds[], reportDate,
  ///               startDate, endDate, userId, id
  String get detailThermalDataMulti =>
      path('/api/ThermalDatas/detailThermalDataMulti');

  /// GET: Get environment thermal data by area
  /// Query params: areaId
  String get environmentThermal => path('/api/ThermalDatas/environmentThermal');
}
