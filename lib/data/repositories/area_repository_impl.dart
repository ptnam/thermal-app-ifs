// =============================================================================
// File: area_repository_impl.dart
// Description: Implementation of AreaRepository interface
//
// Purpose:
// - Implements domain repository interface for areas
// - Converts API responses (AreaTreeDto) to domain entities (AreaTree)
// - Maps ApiError to Failure for domain layer compatibility
// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/data/network/area/dto/area_dto.dart';
import 'package:thermal_mobile/domain/models/area_tree.dart';
import 'package:thermal_mobile/domain/models/camera_entity.dart';
import 'package:thermal_mobile/domain/models/machine_entity.dart';
import '../../core/error/failure.dart';
import '../../domain/repositories/area_repository.dart';
import '../network/area/area_api_service.dart';
import '../network/area/dto/area_tree_dto.dart';
import '../network/camera/dto/camera_dto.dart';

// Implementation of [AreaRepository] that uses [AreaApiService].
//
// This repository handles:
// - Fetching area tree with hierarchical structure
// - Converting DTOs to domain entities
// - Mapping API errors to domain Failures
class AreaRepositoryImpl implements AreaRepository {
  final AreaApiService _areaApiService;
  final Future<String> Function() _getAccessToken;

  AreaRepositoryImpl({
    required AreaApiService areaApiService,
    required Future<String> Function() getAccessToken,
  }) : _areaApiService = areaApiService,
       _getAccessToken = getAccessToken;

  // ─────────────────────────────────────────────────────────────────────────────
  // Area Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<AreaTree>>> getAreaAllTree() async {
    try {
      final token = await _getAccessToken();
      final result = await _areaApiService.getAreaAllTree(
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(
          ServerFailure(
            message: error.message,
            statusCode: error.statusCode,
            code: error.code,
          ),
        ),
        onSuccess: (response) {
          if (response == null) {
            return const Right([]);
          }
          final entities = response.map((dto) => _dtoToEntity(dto)).toList();
          return Right(entities);
        },
      );
    } catch (e) {
      return Left(
        NetworkFailure(
          message: 'Failed to get area tree: $e',
          originalException: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AreaTree>> getAreaById(int id) async {
    try {
      final token = await _getAccessToken();
      final result = await _areaApiService.getAreaById(
        id: id,
        accessToken: token,
      );

      return result.fold(
        onFailure: (error) => Left(
          ServerFailure(
            message: error.message,
            statusCode: error.statusCode,
            code: error.code,
          ),
        ),
        onSuccess: (response) {
          if (response == null) {
            return Left(
              ServerFailure(message: 'Area not found', statusCode: 404),
            );
          }
          return Right(_dtoToEntity(response));
        },
      );
    } catch (e) {
      return Left(
        NetworkFailure(message: 'Failed to get area: $e', originalException: e),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────────

  // Convert AreaTreeDto to AreaTree entity
  AreaTree _dtoToEntity(AreaTreeDto dto) {
    return AreaTree(
      uniqueId: dto.uniqueId,
      parentId: dto.parentId,
      name: dto.name,
      code: dto.code,
      id: dto.id,
      mapType: dto.mapType,
      photoPath: dto.photoPath,
      longitude: dto.longitude,
      latitude: dto.latitude,
      zoom: dto.zoom,
      note: dto.note,
      levelName: dto.levelName,
      children: dto.children.map((c) => _dtoToEntity(c)).toList(),
      cameras: dto.cameras.map((c) => _cameraDtoToEntity(c)).toList(),
      status: dto.status,
      displayStatus: dto.displayStatus,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      updatedAt: dto.updatedAt != null
          ? DateTime.tryParse(dto.updatedAt!)
          : null,
      deletedAt: dto.deletedAt != null
          ? DateTime.tryParse(dto.deletedAt!)
          : null,
    );
  }

  // Convert CameraDto to CameraEntity
  CameraEntity _cameraDtoToEntity(CameraDto dto) {
    return CameraEntity(
      id: dto.id ?? 0,
      name: dto.name ?? '',
      code: dto.code,
      description: dto.description,
      areaId: dto.areaId,
      areaName: dto.areaName,
      cameraType: _mapCameraType(dto.cameraType),
      status: _mapStatus(dto.status),
      ipAddress: dto.ipAddress,
      port: dto.port,
      username: dto.username,
      password: dto.password,
      streamUrl: dto.streamUrl,
      thumbnailUrl: dto.thumbnailUrl,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  // Map DTO CameraType to Entity CameraTypeEntity
  CameraTypeEntity? _mapCameraType(CameraType? type) {
    if (type == null) return null;
    switch (type) {
      case CameraType.thermal:
        return CameraTypeEntity.thermal;
      case CameraType.vision:
        return CameraTypeEntity.optical; // vision -> optical (closest match)
    }
  }

  // Map DTO CommonStatus to Entity EntityStatus
  EntityStatus _mapStatus(CommonStatus status) {
    switch (status) {
      case CommonStatus.active:
        return EntityStatus.active;
      case CommonStatus.inactive:
      case CommonStatus.deleted:
        return EntityStatus.inactive;
    }
  }

  @override
  Future<Either<Failure, AreaDto>> createArea(AreaDto area) {
    // TODO: implement createArea
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteArea(int id) {
    // TODO: implement deleteArea
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ShortenBaseDto>>> getAllAreas() {
    // TODO: implement getAllAreas
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PagingResponse<AreaDto>>> getAreaList({int page = 1, int pageSize = 20, CommonStatus? status}) {
    // TODO: implement getAreaList
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AreaDto>> updateArea(AreaDto area) {
    // TODO: implement updateArea
    throw UnimplementedError();
  }
}
