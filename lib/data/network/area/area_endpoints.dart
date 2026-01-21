import 'package:thermal_mobile/data/network/api/endpoints.dart';

/// =============================================================================
/// File: area_endpoints.dart
/// Description: Area API endpoints configuration
/// 
/// Purpose:
/// - Define all area-related API endpoints
/// - Support area CRUD and hierarchy operations
/// =============================================================================


/// Area API endpoints configuration
class AreaEndpoints extends Endpoints {
  AreaEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all areas (flat list)
  String get all => path('/api/Areas/all');

  /// GET: Get all areas as tree structure
  /// Query params: cameras (bool) - include cameras in each area
  String get allTree => path('/api/Areas/allTree');

  /// GET: Get paginated area list
  /// Query params: page, pageSize, name, status
  String get list => path('/api/Areas/list');

  /// GET: Get single area by ID
  String byId(int id) => path('/api/Areas/$id');

  /// POST: Create new area
  String get create => path('/api/Areas');

  /// PUT: Update area by ID
  String update(int id) => path('/api/Areas/$id');

  /// DELETE: Delete area by ID
  String delete(int id) => path('/api/Areas/$id');
}
