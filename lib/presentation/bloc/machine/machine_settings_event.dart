/// =============================================================================
/// File: machine_settings_event.dart
/// Description: Machine Settings BLoC events
///
/// Purpose:
/// - Define all events for Machine Settings operations
/// =============================================================================

import 'package:equatable/equatable.dart';

/// Base class for all machine settings events
abstract class MachineSettingsEvent extends Equatable {
  const MachineSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load machine settings
class LoadMachineSettingsEvent extends MachineSettingsEvent {
  const LoadMachineSettingsEvent();
}

/// Event: Clear machine settings
class ClearMachineSettingsEvent extends MachineSettingsEvent {
  const ClearMachineSettingsEvent();
}
