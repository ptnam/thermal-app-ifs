import 'package:bloc/bloc.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/domain/models/notification.dart';
import 'package:thermal_mobile/domain/usecases/notification_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetNotificationDetailUseCase getNotificationDetailUseCase;
  final GetNotificationCountUseCase getNotificationCountUseCase;
  final AppLogger logger;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.getNotificationDetailUseCase,
    required this.getNotificationCountUseCase,
    required this.logger,
  }) : super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<LoadNotificationDetailEvent>(_onLoadNotificationDetail);
    on<LoadNotificationCountEvent>(_onLoadNotificationCount);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
  }

  // Track last params and current data for load-more
  GetNotificationsParams? _lastParams;
  NotificationListEntity? _currentData;

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final params = GetNotificationsParams(queryParameters: event.queryParameters);

      final result = await getNotificationsUseCase(params);
      result.fold(
        (failure) {
          logger.error('BLoC: Failure received: ${failure.message}');
          emit(NotificationError(message: failure.message));
        },
        (list) {
          // store current data and params for pagination
          _currentData = list;
          _lastParams = params;
          emit(NotificationListLoaded(list: list));
        },
      );
    } catch (e, st) {
      logger.error('Exception in LoadNotifications', error: e, stackTrace: st);
      emit(NotificationError(message: 'Lỗi khi tải danh sách thông báo'));
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (_lastParams == null || _currentData == null) return;
    if (!_currentData!.hasNextPage) return;

    // Emit loading more state
    emit(NotificationLoadingMore(currentList: _currentData!));

    // Prepare next page params
    final nextPage = (_currentData!.pageIndex ?? 1) + 1;
    final nextQueryParams = Map<String, dynamic>.from(_lastParams!.queryParameters);
    nextQueryParams['page'] = nextPage;

    final nextParams = GetNotificationsParams(queryParameters: nextQueryParams);

    final result = await getNotificationsUseCase(nextParams);

    result.fold(
      (failure) {
        // Revert to loaded state and show error
        emit(NotificationListLoaded(list: _currentData!));
        emit(NotificationError(message: failure.message));
      },
      (newData) {
        // Merge items
        final mergedItems = [
          ..._currentData!.items,
          ...newData.items,
        ];

        final merged = NotificationListEntity(
          totalRow: newData.totalRow,
          pageSize: newData.pageSize,
          pageIndex: newData.pageIndex,
          totalPages: newData.totalPages,
          items: mergedItems,
        );

        _currentData = merged;
        _lastParams = nextParams;

        emit(NotificationListLoaded(list: merged));
      },
    );
  }
  Future<void> _onLoadNotificationDetail(
    LoadNotificationDetailEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final result = await getNotificationDetailUseCase(
        GetNotificationDetailParams(id: event.id, dataTime: event.dataTime),
      );
      result.fold(
        (failure) {
          logger.error('BLoC: Failure received: ${failure.message}');
          emit(NotificationError(message: failure.message));
        },
        (item) {
          emit(NotificationDetailLoaded(item: item));
        },
      );
    } catch (e, st) {
      logger.error(
        'Exception in LoadNotificationDetail',
        error: e,
        stackTrace: st,
      );
      emit(NotificationError(message: 'Lỗi khi tải chi tiết thông báo'));
    }
  }

  Future<void> _onLoadNotificationCount(
    LoadNotificationCountEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final result = await getNotificationCountUseCase(
        GetNotificationCountParams(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
      result.fold(
        (failure) {
          logger.error('BLoC: Failure received: ${failure.message}');
          emit(NotificationError(message: failure.message));
        },
        (counts) {
          logger.info('Notification count loaded: ${counts.length} records');
          emit(NotificationCountLoaded(counts: counts));
        },
      );
    } catch (e, st) {
      logger.error(
        'Exception in LoadNotificationCount',
        error: e,
        stackTrace: st,
      );
      emit(NotificationError(message: 'Lỗi khi tải thống kê thông báo'));
    }
  }
}
