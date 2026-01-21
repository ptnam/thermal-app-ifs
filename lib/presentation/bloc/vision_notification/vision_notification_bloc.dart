import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:thermal_mobile/domain/models/vision_notification_entity.dart';
import 'package:thermal_mobile/domain/usecases/vision_notification_usecase.dart';

// ============================================================================
// Events
// ============================================================================

abstract class VisionNotificationEvent {}

class FetchVisionNotifications extends VisionNotificationEvent {
  final String fromTime;
  final String? toTime;
  final int? areaId;
  final int? cameraId;
  final int? warningEventId;
  final int page;
  final int pageSize;

  FetchVisionNotifications({
    required this.fromTime,
    this.toTime,
    this.areaId,
    this.cameraId,
    this.warningEventId,
    this.page = 1,
    this.pageSize = 50,
  });
}

class LoadMoreVisionNotifications extends VisionNotificationEvent {}

class RefreshVisionNotifications extends VisionNotificationEvent {}

// ============================================================================
// States
// ============================================================================

abstract class VisionNotificationState {}

class VisionNotificationInitial extends VisionNotificationState {}

class VisionNotificationLoading extends VisionNotificationState {}

class VisionNotificationLoaded extends VisionNotificationState {
  final VisionNotificationListEntity notifications;
  final bool hasReachedMax;

  VisionNotificationLoaded({
    required this.notifications,
    this.hasReachedMax = false,
  });
}

class VisionNotificationLoadingMore extends VisionNotificationState {
  final VisionNotificationListEntity currentNotifications;

  VisionNotificationLoadingMore(this.currentNotifications);
}

class VisionNotificationError extends VisionNotificationState {
  final String message;

  VisionNotificationError(this.message);
}

// ============================================================================
// BLoC
// ============================================================================

@injectable
class VisionNotificationBloc
    extends Bloc<VisionNotificationEvent, VisionNotificationState> {
  final GetVisionNotificationsUseCase getVisionNotificationsUseCase;

  // Store last fetch params for load more
  GetVisionNotificationsParams? _lastParams;
  VisionNotificationListEntity? _currentData;

  VisionNotificationBloc({
    required this.getVisionNotificationsUseCase,
  }) : super(VisionNotificationInitial()) {
    on<FetchVisionNotifications>(_onFetchVisionNotifications);
    on<LoadMoreVisionNotifications>(_onLoadMoreVisionNotifications);
    on<RefreshVisionNotifications>(_onRefreshVisionNotifications);
  }

  Future<void> _onFetchVisionNotifications(
    FetchVisionNotifications event,
    Emitter<VisionNotificationState> emit,
  ) async {
    emit(VisionNotificationLoading());

    final params = GetVisionNotificationsParams(
      fromTime: event.fromTime,
      toTime: event.toTime,
      areaId: event.areaId,
      cameraId: event.cameraId,
      warningEventId: event.warningEventId,
      page: event.page,
      pageSize: event.pageSize,
    );

    _lastParams = params;

    final result = await getVisionNotificationsUseCase(params);

    result.fold(
      (failure) => emit(VisionNotificationError(failure.message)),
      (notifications) {
        _currentData = notifications;
        emit(VisionNotificationLoaded(
          notifications: notifications,
          hasReachedMax: !notifications.hasNextPage,
        ));
      },
    );
  }

  Future<void> _onLoadMoreVisionNotifications(
    LoadMoreVisionNotifications event,
    Emitter<VisionNotificationState> emit,
  ) async {
    if (_lastParams == null || _currentData == null) return;
    if (!_currentData!.hasNextPage) return;

    // Emit loading more state
    emit(VisionNotificationLoadingMore(_currentData!));

    // Load next page
    final nextPageParams = _lastParams!.copyWith(
      page: _currentData!.pageIndex + 1,
    );

    final result = await getVisionNotificationsUseCase(nextPageParams);

    result.fold(
      (failure) {
        // Return to loaded state on error
        emit(VisionNotificationLoaded(
          notifications: _currentData!,
          hasReachedMax: !_currentData!.hasNextPage,
        ));
        emit(VisionNotificationError(failure.message));
      },
      (newData) {
        // Merge items
        final mergedItems = [
          ..._currentData!.items,
          ...newData.items,
        ];

        final mergedData = VisionNotificationListEntity(
          totalRow: newData.totalRow,
          pageSize: newData.pageSize,
          pageIndex: newData.pageIndex,
          rowIndex: newData.rowIndex,
          lastRowIndex: newData.lastRowIndex,
          totalPages: newData.totalPages,
          items: mergedItems,
        );

        _currentData = mergedData;
        _lastParams = nextPageParams;

        emit(VisionNotificationLoaded(
          notifications: mergedData,
          hasReachedMax: !newData.hasNextPage,
        ));
      },
    );
  }

  Future<void> _onRefreshVisionNotifications(
    RefreshVisionNotifications event,
    Emitter<VisionNotificationState> emit,
  ) async {
    if (_lastParams == null) return;

    // Reset to first page
    final refreshParams = _lastParams!.copyWith(page: 1);

    final result = await getVisionNotificationsUseCase(refreshParams);

    result.fold(
      (failure) => emit(VisionNotificationError(failure.message)),
      (notifications) {
        _currentData = notifications;
        _lastParams = refreshParams;
        emit(VisionNotificationLoaded(
          notifications: notifications,
          hasReachedMax: !notifications.hasNextPage,
        ));
      },
    );
  }
}
