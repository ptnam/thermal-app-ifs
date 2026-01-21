import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:thermal_mobile/domain/models/machine_thermal_entity.dart';
import 'package:thermal_mobile/domain/usecases/machine_thermal_usecase.dart';

// Events
abstract class MachineThermalEvent {}

class LoadAreaThermalOverview extends MachineThermalEvent {
  final int areaId;

  LoadAreaThermalOverview(this.areaId);
}

class ClearMachineThermal extends MachineThermalEvent {}

// States
abstract class MachineThermalState {}

class MachineThermalInitial extends MachineThermalState {}

class MachineThermalLoading extends MachineThermalState {}

class MachineThermalLoaded extends MachineThermalState {
  final AreaThermalOverviewEntity overview;

  MachineThermalLoaded(this.overview);
}

class MachineThermalError extends MachineThermalState {
  final String message;

  MachineThermalError(this.message);
}

// BLoC
@injectable
class MachineThermalBloc
    extends Bloc<MachineThermalEvent, MachineThermalState> {
  final GetAreaThermalOverviewUseCase _getAreaThermalOverviewUseCase;

  MachineThermalBloc(this._getAreaThermalOverviewUseCase)
      : super(MachineThermalInitial()) {
    on<LoadAreaThermalOverview>(_onLoadAreaThermalOverview);
    on<ClearMachineThermal>(_onClear);
  }

  Future<void> _onLoadAreaThermalOverview(
    LoadAreaThermalOverview event,
    Emitter<MachineThermalState> emit,
  ) async {
    print('🔥 MachineThermalBloc: Loading thermal overview for areaId=${event.areaId}');
    emit(MachineThermalLoading());

    final result = await _getAreaThermalOverviewUseCase(event.areaId);

    result.fold(
      (failure) {
        print('❌ MachineThermalBloc: Error - ${failure.message}');
        emit(MachineThermalError(failure.message));
      },
      (overview) {
        print('✅ MachineThermalBloc: Loaded ${overview.machines.length} machines');
        print('   Hottest: ${overview.hottestMachine?.machine.name} - ${overview.hottestMachine?.maxTemperature}°C');
        print('   Coldest: ${overview.coldestMachine?.machine.name} - ${overview.coldestMachine?.minTemperature}°C');
        emit(MachineThermalLoaded(overview));
      },
    );
  }

  void _onClear(
    ClearMachineThermal event,
    Emitter<MachineThermalState> emit,
  ) {
    emit(MachineThermalInitial());
  }
}
