import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/domain/models/area_tree.dart';
import 'package:thermal_mobile/domain/usecases/area_usecase.dart';

import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';

/// Event base class for Area BLoC
abstract class AreaEvent {
  const AreaEvent();
}

/// Event to fetch area tree
class FetchAreaTreeEvent extends AreaEvent {
  const FetchAreaTreeEvent();
}

/// State base class for Area BLoC
abstract class AreaState {
  const AreaState();
}

/// Initial state
class AreaInitial extends AreaState {
  const AreaInitial();
}

/// Loading state
class AreaLoading extends AreaState {
  const AreaLoading();
}

/// Loaded state - displaying area tree
class AreaTreeLoaded extends AreaState {
  final List<AreaTree> areas;
  final int? expandedAreaId; // Track which area is expanded

  const AreaTreeLoaded(this.areas, {this.expandedAreaId});

  AreaTreeLoaded copyWith({
    List<AreaTree>? areas,
    int? expandedAreaId,
  }) {
    return AreaTreeLoaded(
      areas ?? this.areas,
      expandedAreaId: expandedAreaId ?? this.expandedAreaId,
    );
  }
}

/// Error state
class AreaError extends AreaState {
  final String message;
  const AreaError(this.message);
}

/// Area BLoC
class AreaBloc extends Bloc<AreaEvent, AreaState> {
  final GetAreaAllTreeUseCase _getAreaTreeUseCase;

  AreaBloc({
    required GetAreaAllTreeUseCase getAreaTreeUseCase,
    required GetAreaByIdUseCase getAreaByIdUseCase,
  })  : _getAreaTreeUseCase = getAreaTreeUseCase,
        super(const AreaInitial()) {
    on<FetchAreaTreeEvent>(_onFetchAreaTree);
  }

  Future<void> _onFetchAreaTree(
    FetchAreaTreeEvent event,
    Emitter<AreaState> emit,
  ) async {
    emit(const AreaLoading());

    final result = await _getAreaTreeUseCase(const NoParams());

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        emit(AreaError(message));
      },
      (areas) {
        emit(AreaTreeLoaded(areas));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is AuthFailure) {
      return 'Authentication failed. Please log in again.';
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else if (failure is ServerFailure) {
      return 'Server error. Please try again later.';
    } else if (failure is CacheFailure) {
      return 'Cache error. Please try again.';
    }
    return 'An unexpected error occurred.';
  }
}
