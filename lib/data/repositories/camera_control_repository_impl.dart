import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thermal_mobile/core/error/failure.dart';
import 'package:thermal_mobile/data/network/camera/camera_control_api_service.dart';
import 'package:thermal_mobile/domain/repositories/camera_control_repository.dart';

class CameraControlRepositoryImpl implements CameraControlRepository {
  CameraControlRepositoryImpl({
    required CameraControlApiService cameraControlApiService,
    required Future<String> Function() getAccessToken,
  }) : _cameraControlApiService = cameraControlApiService,
       _getAccessToken = getAccessToken;

  final CameraControlApiService _cameraControlApiService;
  final Future<String> Function() _getAccessToken;

  @override
  Future<Either<Failure, bool>> sendCameraControl({
    required int cameraId,
    required int speed,
    required int command,
    int? preCommand,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken.isEmpty) {
        return Left(AuthFailure(message: 'Không tìm thấy access token'));
      }

      final isSuccess = await _cameraControlApiService.sendCameraControl(
        cameraId: cameraId,
        speed: speed,
        command: command,
        preCommand: preCommand,
        accessToken: accessToken,
      );

      if (!isSuccess) {
        return Left(
          ServerFailure(message: 'PTZ command failed', statusCode: 500),
        );
      }

      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message:
              e.response?.data?.toString() ?? e.message ?? 'PTZ request failed',
          statusCode: e.response?.statusCode,
          originalException: e,
        ),
      );
    } catch (e) {
      return Left(
        NetworkFailure(message: 'PTZ network error: $e', originalException: e),
      );
    }
  }
}
