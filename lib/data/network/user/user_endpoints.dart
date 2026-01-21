import 'package:thermal_mobile/data/network/api/endpoints.dart';

/// =============================================================================
/// File: user_endpoints.dart
/// Description: API endpoint definitions for User operations
/// 
/// Purpose:
/// - Centralized endpoint management for User API
/// - Clean separation of URL construction logic
/// =============================================================================

/// User API endpoints
class UserEndpoints extends Endpoints {
  UserEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all users (shortened list for dropdowns)
  String get all => path('/api/Users/all');

  /// GET: Get paginated user list
  /// Query params: page, pageSize, roleId, userStatus, name, email
  String get list => path('/api/Users/list');

  /// GET: Get user by ID
  String byId(int id) => path('/api/Users/$id');

  /// GET: Get current user profile
  String get myProfile => path('/api/Users/myProfile');

  /// POST: Create new user
  String get create => path('/api/Users');

  /// PUT: Update user by ID
  String update(int id) => path('/api/Users/$id');

  /// DELETE: Delete user by ID
  String delete(int id) => path('/api/Users/$id');

  /// POST: Change password
  String get changePassword => path('/api/Users/changepassword');
}
