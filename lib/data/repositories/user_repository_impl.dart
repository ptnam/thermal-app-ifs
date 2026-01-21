/// =============================================================================
/// File: user_repository_impl.dart
/// Description: Implementation of IUserRepository interface
///
/// Purpose:
/// - Implements domain repository interface
/// - Converts API responses to domain entities
/// - Handles errors and maps to ApiError
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/domain/models/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../network/user/user_api_service.dart';
import '../network/user/dto/user_dto.dart';
import '../mappers/dto_mappers.dart';

/// Implementation of [IUserRepository] that uses [UserApiService] for data operations.
class UserRepositoryImpl implements IUserRepository {
  final UserApiService _userApiService;
  final Future<String> Function() _getAccessToken;

  UserRepositoryImpl({
    required UserApiService userApiService,
    required Future<String> Function() getAccessToken,
  }) : _userApiService = userApiService,
       _getAccessToken = getAccessToken;

  // ─────────────────────────────────────────────────────────────────────────────
  // Current User Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, UserEntity>> getCurrentUser() async {
    try {
      final token = await _getAccessToken();
      final result = await _userApiService.getMyProfile(accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'User not found', statusCode: 404),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get current user: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, List<UserEntity>>> getAllUsers({int? status}) async {
    try {
      final token = await _getAccessToken();
      final result = await _userApiService.getAll(accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response?.map((dto) => _baseUserToEntity(dto)).toList() ?? [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get all users: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, PagingResponse<UserEntity>>> getUserList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? status,
    int? roleId,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _userApiService.getList(
        accessToken: token,
        page: page,
        pageSize: pageSize,
        name: name,
        roleId: roleId,
        userStatus: status != null ? _mapIntToUserStatus(status) : null,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Right(
              PagingResponse<UserEntity>(
                data: [],
                currentPage: 1,
                pageSize: pageSize,
                totalRecords: 0,
                totalPages: 0,
              ),
            );
          }
          final entities = response.data.map((dto) => dto.toEntity()).toList();
          return Right(
            PagingResponse(
              data: entities,
              currentPage: response.currentPage,
              pageSize: response.pageSize,
              totalRecords: response.totalRecords,
              totalPages: response.totalPages,
            ),
          );
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get user list: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, UserEntity>> getUserById(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _userApiService.getById(id: id, accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'User not found', statusCode: 404),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get user by id: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, UserEntity>> createUser(
    UserEntity user,
    String password,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = user.toDto();
      final result = await _userApiService.create(
        user: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Failed to create user'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to create user: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, UserEntity>> updateUser(
    int id,
    UserEntity user,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = user.toDto();
      final result = await _userApiService.update(
        id: id,
        user: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Failed to update user'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to update user: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, void>> deleteUser(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _userApiService.delete(id: id, accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (_) => const Right(null),
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to delete user: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, UserEntity>> updateProfile(UserEntity user) async {
    try {
      final token = await _getAccessToken();
      final dto = user.toDto();
      final result = await _userApiService.update(
        id: user.id,
        user: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Failed to update profile'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to update profile: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _getAccessToken();
      final request = ChangePasswordRequestDto(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final result = await _userApiService.changePassword(
        request: request,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (_) => const Right(null),
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to change password: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────────

  UserStatus? _mapIntToUserStatus(int status) {
    switch (status) {
      case 0:
        return UserStatus.inactive;
      case 1:
        return UserStatus.active;
      case 2:
        return UserStatus.deleted;
      default:
        return null;
    }
  }

  UserEntity _baseUserToEntity(BaseUserDto dto) {
    return UserEntity(
      id: dto.id,
      userName: dto.fullName ?? '',
      email: dto.email ?? '',
      fullName: dto.fullName,
    );
  }
}
