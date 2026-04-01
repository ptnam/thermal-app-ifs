import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/error/failure.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/domain/usecases/camera_control_usecase.dart';

abstract class CameraControlEvent {
  const CameraControlEvent();
}

class SendCameraControlEvent extends CameraControlEvent {
  const SendCameraControlEvent({
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

abstract class CameraControlState {
  const CameraControlState();
}

class CameraControlInitial extends CameraControlState {
  const CameraControlInitial();
}

class CameraControlSending extends CameraControlState {
  const CameraControlSending();
}

class CameraControlSuccess extends CameraControlState {
  const CameraControlSuccess();
}

class CameraControlFailure extends CameraControlState {
  const CameraControlFailure(this.message);

  final String message;
}

class CameraControlBloc extends Bloc<CameraControlEvent, CameraControlState> {
  CameraControlBloc({
    required SendCameraControlUseCase sendCameraControlUseCase,
    required AppLogger logger,
  }) : _sendCameraControlUseCase = sendCameraControlUseCase,
       _logger = logger,
       super(const CameraControlInitial()) {
    on<SendCameraControlEvent>(_onSendCameraControl);
  }

  final SendCameraControlUseCase _sendCameraControlUseCase;
  final AppLogger _logger;

  Future<void> _onSendCameraControl(
    SendCameraControlEvent event,
    Emitter<CameraControlState> emit,
  ) async {
    emit(const CameraControlSending());

    final result = await _sendCameraControlUseCase(
      SendCameraControlParams(
        cameraId: event.cameraId,
        speed: event.speed,
        command: event.command,
        preCommand: event.preCommand,
      ),
    );

    result.fold(
      (failure) {
        _logger.error(
          'PTZ control failed',
          error: failure,
          stackTrace: failure.originalException is StackTrace
              ? failure.originalException as StackTrace
              : null,
        );
        emit(CameraControlFailure(_mapFailureMessage(failure)));
      },
      (_) {
        emit(const CameraControlSuccess());
      },
    );
  }

  String _mapFailureMessage(Failure failure) {
    switch (failure) {
      case AuthFailure _:
        return 'Lỗi xác thực PTZ';
      case ServerFailure _:
        return 'Lỗi máy chủ PTZ: ${failure.message}';
      case NetworkFailure _:
        return 'Lỗi mạng PTZ: ${failure.message}';
      default:
        return failure.message;
    }
  }
}
