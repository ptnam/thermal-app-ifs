import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/domain/models/camera_stream.dart';
import 'package:thermal_mobile/domain/usecases/camera_usecase.dart';
import '../../../core/error/failure.dart';

/// Event base class for Camera Stream BLoC
abstract class CameraStreamEvent {
  const CameraStreamEvent();
}

/// Event to fetch camera stream
class FetchCameraStreamEvent extends CameraStreamEvent {
  final int cameraId;
  const FetchCameraStreamEvent({required this.cameraId});
}

/// State base class for Camera Stream BLoC
abstract class CameraStreamState {
  const CameraStreamState();
}

/// Initial state
class CameraStreamInitial extends CameraStreamState {
  const CameraStreamInitial();
}

/// Loading state
class CameraStreamLoading extends CameraStreamState {
  const CameraStreamLoading();
}

/// Loaded state - displaying camera stream
class CameraStreamLoaded extends CameraStreamState {
  final CameraStream cameraStream;
  const CameraStreamLoaded(this.cameraStream);
}

/// Error state
class CameraStreamError extends CameraStreamState {
  final String message;
  const CameraStreamError(this.message);
}

/// Camera Stream BLoC
class CameraStreamBloc extends Bloc<CameraStreamEvent, CameraStreamState> {
  final GetCameraStreamUseCase _getCameraStreamUseCase;

  CameraStreamBloc({
    required GetCameraStreamUseCase getCameraStreamUseCase,
  })  : _getCameraStreamUseCase = getCameraStreamUseCase,
        super(const CameraStreamInitial()) {
    on<FetchCameraStreamEvent>(_onFetchCameraStream);
  }

  Future<void> _onFetchCameraStream(
    FetchCameraStreamEvent event,
    Emitter<CameraStreamState> emit,
  ) async {
    emit(const CameraStreamLoading());

    final result = await _getCameraStreamUseCase(
      GetCameraStreamParams(cameraId: event.cameraId),
    );

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        emit(CameraStreamError(message));
      },
      (cameraStream) {
        emit(CameraStreamLoaded(cameraStream));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Lỗi kết nối mạng: ${failure.message}';
      case ServerFailure:
        return 'Lỗi máy chủ: ${failure.message}';
      case AuthFailure:
        return 'Lỗi xác thực: ${failure.message}';
      case CacheFailure:
        return 'Lỗi bộ nhớ đệm: ${failure.message}';
      case ParsingFailure:
        return 'Lỗi xử lý dữ liệu: ${failure.message}';
      default:
        return 'Lỗi không xác định: ${failure.message}';
    }
  }
}
