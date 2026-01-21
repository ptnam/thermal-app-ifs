/// =============================================================================
/// File: role_repository_impl.dart
/// Description: Implementation of IRoleRepository interface
///
/// Purpose:
/// - Implements domain repository interface for roles
/// - Converts API responses to domain entities
/// - Handles errors and maps to ApiError
/// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/api_error.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/domain/models/role_entity.dart';
import '../../domain/repositories/role_repository.dart';
import '../network/role/role_api_service.dart';
import '../mappers/dto_mappers.dart';

/// Implementation of [IRoleRepository] that uses [RoleApiService].
class RoleRepositoryImpl implements IRoleRepository {
  final RoleApiService _roleApiService;
  final Future<String> Function() _getAccessToken;

  RoleRepositoryImpl({
    required RoleApiService roleApiService,
    required Future<String> Function() getAccessToken,
  }) : _roleApiService = roleApiService,
       _getAccessToken = getAccessToken;

  // ─────────────────────────────────────────────────────────────────────────────
  // Role Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiError, List<RoleEntity>>> getAllRoles({int? status}) async {
    try {
      final token = await _getAccessToken();
      final result = await _roleApiService.getAll(accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response?.map((dto) => _shortenToRoleEntity(dto)).toList() ?? [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get all roles: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, PagingResponse<RoleEntity>>> getRoleList({
    int page = 1,
    int pageSize = 10,
    String? name,
    int? status,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _roleApiService.getList(
        accessToken: token,
        page: page,
        pageSize: pageSize,
        status: status != null ? _mapIntToCommonStatus(status) : null,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Right(
              PagingResponse<RoleEntity>(
                data: [],
                currentPage: page,
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
          message: 'Failed to get role list: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, RoleEntity>> getRoleById(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _roleApiService.getById(id: id, accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              const ApiError(message: 'Role not found', statusCode: 404),
            );
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get role by id: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, RoleEntity>> createRole(RoleEntity role) async {
    try {
      final token = await _getAccessToken();
      final dto = role.toDto();
      final result = await _roleApiService.create(
        role: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Failed to create role'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to create role: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, RoleEntity>> updateRole(
    int id,
    RoleEntity role,
  ) async {
    try {
      final token = await _getAccessToken();
      final dto = role.toDto();
      final result = await _roleApiService.update(
        id: id,
        role: dto,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          if (response == null) {
            return Left(const ApiError(message: 'Failed to update role'));
          }
          return Right(response.toEntity());
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to update role: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, void>> deleteRole(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _roleApiService.delete(id: id, accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (_) => const Right(null),
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to delete role: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, List<FeatureEntity>>> getAllFeatures() async {
    try {
      final token = await _getAccessToken();
      final result = await _roleApiService.getAllFeatures(accessToken: token);

      return result.fold(
        onFailure: (error) => Left(error),
        onSuccess: (response) {
          final entities =
              response?.map((dto) => dto.toEntity()).toList() ?? [];
          return Right(entities);
        },
      );
    } catch (e, st) {
      return Left(
        ApiError(
          message: 'Failed to get all features: $e',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────────

  CommonStatus? _mapIntToCommonStatus(int status) {
    switch (status) {
      case 0:
        return CommonStatus.inactive;
      case 1:
        return CommonStatus.active;
      default:
        return null;
    }
  }

  RoleEntity _shortenToRoleEntity(ShortenBaseDto dto) {
    return RoleEntity(id: dto.id, name: dto.name);
  }
}
