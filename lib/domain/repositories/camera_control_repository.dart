import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/core/error/failure.dart';

abstract class CameraControlRepository {
  Future<Either<Failure, bool>> sendCameraControl({
    required int cameraId,
    required int speed,
    required int command,
    int? preCommand,
  });
}
