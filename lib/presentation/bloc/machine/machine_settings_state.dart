/// =============================================================================
/// File: machine_settings_state.dart
/// Description: Machine Settings BLoC state
///
/// Purpose:
/// - Define all possible states for MachineSettingsBloc
/// =============================================================================

import 'package:equatable/equatable.dart';
import 'package:thermal_mobile/domain/models/machine_entity.dart';

/// Status of machine settings operations
enum MachineSettingsStatus { initial, loading, success, failure }

/// State class for Machine Settings BLoC
class MachineSettingsState extends Equatable {
  final MachineSettingsStatus status;
  final MachineSettingEntity? settings;
  final String? errorMessage;

  const MachineSettingsState({
    this.status = MachineSettingsStatus.initial,
    this.settings,
    this.errorMessage,
  });

  MachineSettingsState copyWith({
    MachineSettingsStatus? status,
    MachineSettingEntity? settings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MachineSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage];
}
