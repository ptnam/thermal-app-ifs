import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/core/error/failure.dart';
import 'package:thermal_mobile/core/usecase/usecase.dart';
import 'package:thermal_mobile/domain/repositories/camera_control_repository.dart';

class SendCameraControlUseCase extends UseCase<bool, SendCameraControlParams> {
  SendCameraControlUseCase(this._repository);

  final CameraControlRepository _repository;

  @override
  Future<Either<Failure, bool>> call(SendCameraControlParams params) {
    return _repository.sendCameraControl(
      cameraId: params.cameraId,
      speed: params.speed,
      command: params.command,
      preCommand: params.preCommand,
    );
  }
}

class SendCameraControlParams {
  SendCameraControlParams({
    required this.cameraId,
    required this.speed,
    required this.command,
    this.preCommand,
  });

  final int cameraId;
  final int speed;
  final int command;
  final int? preCommand;
}
