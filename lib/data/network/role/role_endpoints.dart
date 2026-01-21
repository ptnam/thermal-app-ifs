import 'package:thermal_mobile/data/network/api/endpoints.dart';

/// =============================================================================
/// File: role_endpoints.dart
/// Description: API endpoint definitions for Role operations
/// 
/// Purpose:
/// - Centralized endpoint management for Role API
/// - Clean separation of URL construction logic
/// =============================================================================

/// Role API endpoints
class RoleEndpoints extends Endpoints {
  RoleEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all roles (shortened list for dropdowns)
  String get all => path('/api/Roles/all');

  /// GET: Get paginated role list
  /// Query params: page, pageSize, status
  String get list => path('/api/Roles/list');

  /// GET: Get role by ID
  String byId(int id) => path('/api/Roles/$id');

  /// POST: Create new role
  String get create => path('/api/Roles');

  /// PUT: Update role by ID
  String update(int id) => path('/api/Roles/$id');

  /// DELETE: Delete role by ID
  String delete(int id) => path('/api/Roles/$id');

  /// GET: Get all available features/permissions
  String get allFeatures => path('/api/Roles/allFeatures');
}
