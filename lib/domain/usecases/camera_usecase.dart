import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/domain/models/camera_stream.dart';

import '../../core/error/failure.dart';
import '../repositories/camera_repository.dart';
import '../../core/usecase/usecase.dart';

/// Use case for getting camera stream
class GetCameraStreamUseCase extends UseCase<CameraStream, GetCameraStreamParams> {
  final CameraRepository repository;

  GetCameraStreamUseCase(this.repository);

  @override
  Future<Either<Failure, CameraStream>> call(GetCameraStreamParams params) async {
    return await repository.getCameraStream(cameraId: params.cameraId);
  }
}

class GetCameraStreamParams {
  final int cameraId;

  GetCameraStreamParams({required this.cameraId});
}
