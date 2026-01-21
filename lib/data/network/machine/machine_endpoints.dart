import 'package:thermal_mobile/data/network/api/endpoints.dart';

/// =============================================================================
/// File: machine_endpoints.dart
/// Description: API endpoint definitions for Machine operations
///
/// Purpose:
/// - Centralized endpoint management for Machine, MachineType, MachinePart APIs
/// - Clean separation of URL construction logic
/// =============================================================================

/// Machine API endpoints
class MachineEndpoints extends Endpoints {
  MachineEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  // ─────────────────────────────────────────────────────────────────────────
  // Machine endpoints
  // ─────────────────────────────────────────────────────────────────────────

  /// GET: Get all machines (shortened list)
  /// Query params: areaId, machineTypeId
  String get all => path('/api/Machines/all');

  /// GET: Get paginated machine list
  /// Query params: page, pageSize, areaId, machineTypeId, name, status
  String get list => path('/api/Machines/list');

  /// GET: Get machine by ID
  String byId(int id) => path('/api/Machines/$id');

  /// POST: Create new machine
  String get create => path('/api/Machines');

  /// PUT: Update machine by ID
  String update(int id) => path('/api/Machines/$id');

  /// DELETE: Delete machine by ID
  String delete(int id) => path('/api/Machines/$id');

  /// GET: Get machines by area with component info
  String get machinesByArea => path('/api/Machines/machinesByArea');

  /// GET: Get machine components
  String get components => path('/api/Machines/components');

  /// GET: Get multiple machine components
  String get multiComponents => path('/api/Machines/multiComponents');

  /// GET: Get machine components by machine part
  String get componentsByMachinePart =>
      path('/api/Machines/componentsByMachinePart');

  /// POST: Get machines by areas (anonymous)
  String get machinesByAreas => path('/api/Machines/machinesByAreas');

  /// POST: Get machines and thermal details by areas
  String get thermalMachinesByAreas =>
      path('/api/Machines/thermalMachinesByAreas');

  /// GET: Get machine settings for current user
  String get machineSetting => path('/api/Machines/machineSetting');
}

/// Machine Type API endpoints
class MachineTypeEndpoints extends Endpoints {
  MachineTypeEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all machine types (shortened list)
  String get all => path('/api/MachineTypes/all');

  /// GET: Get paginated machine type list
  String get list => path('/api/MachineTypes/list');

  /// GET: Get machine type by ID
  String byId(int id) => path('/api/MachineTypes/$id');

  /// POST: Create new machine type
  String get create => path('/api/MachineTypes');

  /// PUT: Update machine type by ID
  String update(int id) => path('/api/MachineTypes/$id');

  /// DELETE: Delete machine type by ID
  String delete(int id) => path('/api/MachineTypes/$id');
}

/// Machine Part API endpoints
class MachinePartEndpoints extends Endpoints {
  MachinePartEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all machine parts for machine type
  /// Query params: machineTypeId
  String get all => path('/api/MachineParts/all');

  /// GET: Get machine parts as tree structure
  String get allTree => path('/api/MachineParts/allTree');

  /// GET: Get paginated machine part list
  String get list => path('/api/MachineParts/list');

  /// GET: Get machine part by ID
  String byId(int id) => path('/api/MachineParts/$id');

  /// POST: Create new machine part
  String get create => path('/api/MachineParts');

  /// PUT: Update machine part by ID
  String update(int id) => path('/api/MachineParts/$id');

  /// DELETE: Delete machine part by ID
  String delete(int id) => path('/api/MachineParts/$id');
}
