/// =============================================================================
/// File: role_repository.dart
/// Description: Role repository interface
/// 
/// Purpose:
/// - Define contract for role and feature data operations
/// - Support role-based access control
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/domain/models/role_entity.dart';


/// Repository interface for Role operations
abstract class IRoleRepository {
  /// Get all roles (for dropdowns)
  Future<Either<ApiError, List<RoleEntity>>> getAllRoles({
    int? status,
  });

  /// Get paginated role list
  Future<Either<ApiError, PagingResponse<RoleEntity>>> getRoleList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? status,
  });

  /// Get role by ID
  Future<Either<ApiError, RoleEntity>> getRoleById(int id);

  /// Create new role
  Future<Either<ApiError, RoleEntity>> createRole(RoleEntity role);

  /// Update role
  Future<Either<ApiError, RoleEntity>> updateRole(int id, RoleEntity role);

  /// Delete role
  Future<Either<ApiError, void>> deleteRole(int id);

  /// Get all features
  Future<Either<ApiError, List<FeatureEntity>>> getAllFeatures();
}
