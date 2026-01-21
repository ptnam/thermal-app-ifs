// =============================================================================
// File: camera_repository_impl.dart
// Description: Implementation of CameraRepository interface
//
// Purpose:
// - Implements domain repository interface for cameras
// - Converts API responses to domain entities
// - Maps ApiError to Failure for domain layer compatibility
// =============================================================================

import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/domain/models/camera_stream.dart';

import '../../core/error/failure.dart';
import '../../domain/repositories/camera_repository.dart';
import '../network/camera/camera_stream_api_service.dart';

// Implementation of [CameraRepository] that uses [CameraStreamApiService].
//
// This repository handles:
// - Fetching camera streams
// - Converting DTOs to domain entities
// - Mapping API errors to domain Failures
class CameraRepositoryImpl implements CameraRepository {
  final CameraStreamApiService _cameraStreamApiService;
  final Future<String> Function() _getAccessToken;

  CameraRepositoryImpl({
    required CameraStreamApiService cameraStreamApiService,
    required Future<String> Function() getAccessToken,
  }) : _cameraStreamApiService = cameraStreamApiService,
       _getAccessToken = getAccessToken;

  // ─────────────────────────────────────────────────────────────────────────────
  // Camera Stream Operations
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, CameraStream>> getCameraStream({
    required int cameraId,
  }) async {
    try {
      final token = await _getAccessToken();
      final result = await _cameraStreamApiService.getCameraStream(
        cameraId: cameraId,
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
              ServerFailure(message: 'Camera stream not found', statusCode: 404),
            );
          }

          // Convert CameraStreamDto to CameraStream entity
          final stream = CameraStream(
            cameraId: response.cameraId,
            cameraName: response.cameraName,
            streamUrl: response.streamUrl,
            rtspUrl: response.rtspUrl,
            hlsUrl: response.hlsUrl,
            dashUrl: response.dashUrl,
            status: response.status,
          );

          return Right(stream);
        },
      );
    } catch (e) {
      return Left(
        NetworkFailure(
          message: 'Failed to get camera stream: $e',
          originalException: e,
        ),
      );
    }
  }
}
