/// =============================================================================
/// File: machine_settings_bloc.dart
/// Description: Machine Settings BLoC
///
/// Purpose:
/// - Handle machine settings operations
/// - Manage machine settings state
/// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/domain/usecases/machine_usecase.dart';
import 'machine_settings_event.dart';
import 'machine_settings_state.dart';

/// BLoC for managing Machine Settings
class MachineSettingsBloc
    extends Bloc<MachineSettingsEvent, MachineSettingsState> {
  MachineSettingsBloc({
    required GetMachineSettingUseCase getMachineSettingUseCase,
    AppLogger? logger,
  }) : _getMachineSettingUseCase = getMachineSettingUseCase,
       _logger = logger ?? AppLogger(tag: 'MachineSettingsBloc'),
       super(const MachineSettingsState()) {
    on<LoadMachineSettingsEvent>(_onLoadMachineSettings);
    on<ClearMachineSettingsEvent>(_onClearMachineSettings);
  }

  final GetMachineSettingUseCase _getMachineSettingUseCase;
  final AppLogger _logger;

  Future<void> _onLoadMachineSettings(
    LoadMachineSettingsEvent event,
    Emitter<MachineSettingsState> emit,
  ) async {
    _logger.info('Loading machine settings');
    emit(
      state.copyWith(status: MachineSettingsStatus.loading, clearError: true),
    );

    final result = await _getMachineSettingUseCase();

    result.fold(
      (error) {
        _logger.error('Failed to load machine settings: ${error.message}');
        emit(
          state.copyWith(
            status: MachineSettingsStatus.failure,
            errorMessage: error.message,
          ),
        );
      },
      (settings) {
        _logger.info('Loaded machine settings successfully');
        emit(
          state.copyWith(
            status: MachineSettingsStatus.success,
            settings: settings,
          ),
        );
      },
    );
  }

  Future<void> _onClearMachineSettings(
    ClearMachineSettingsEvent event,
    Emitter<MachineSettingsState> emit,
  ) async {
    _logger.info('Clearing machine settings');
    emit(const MachineSettingsState());
  }
}
