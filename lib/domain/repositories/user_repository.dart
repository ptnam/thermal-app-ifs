/// =============================================================================
/// File: user_repository.dart
/// Description: User repository interface
/// 
/// Purpose:
/// - Define contract for user data operations
/// - Abstract data source from domain layer
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/domain/models/user_entity.dart';


/// Repository interface for User operations
/// 
/// This abstraction allows the domain layer to be independent of
/// the data layer implementation (API, local database, etc.)
abstract class IUserRepository {
  /// Get current user profile
  Future<Either<ApiError, UserEntity>> getCurrentUser();

  /// Get all users (for admin)
  Future<Either<ApiError, List<UserEntity>>> getAllUsers({
    int? status,
  });

  /// Get paginated user list
  Future<Either<ApiError, PagingResponse<UserEntity>>> getUserList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? status,
    int? roleId,
  });

  /// Get user by ID
  Future<Either<ApiError, UserEntity>> getUserById(int id);

  /// Create new user (admin)
  Future<Either<ApiError, UserEntity>> createUser(UserEntity user, String password);

  /// Update user
  Future<Either<ApiError, UserEntity>> updateUser(int id, UserEntity user);

  /// Delete user
  Future<Either<ApiError, void>> deleteUser(int id);

  /// Update user profile (self)
  Future<Either<ApiError, UserEntity>> updateProfile(UserEntity user);

  /// Change password
  Future<Either<ApiError, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
