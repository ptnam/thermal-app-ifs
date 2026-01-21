/// =============================================================================
/// File: machine_event.dart
/// Description: Machine BLoC events
/// 
/// Purpose:
/// - Define all events for Machine, MachineType, MachinePart operations
/// =============================================================================

import 'package:equatable/equatable.dart';
import 'package:thermal_mobile/domain/models/machine_entity.dart';

/// Base class for all machine events
abstract class MachineEvent extends Equatable {
  const MachineEvent();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// Machine Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event: Load all machines
class LoadAllMachinesEvent extends MachineEvent {
  final int? areaId;
  final int? machineTypeId;
  final int? status;

  const LoadAllMachinesEvent({
    this.areaId,
    this.machineTypeId,
    this.status,
  });

  @override
  List<Object?> get props => [areaId, machineTypeId, status];
}

/// Event: Load paginated machine list
class LoadMachineListEvent extends MachineEvent {
  final int page;
  final int pageSize;
  final String? name;
  final int? areaId;
  final int? machineTypeId;
  final int? status;

  const LoadMachineListEvent({
    this.page = 1,
    this.pageSize = 10,
    this.name,
    this.areaId,
    this.machineTypeId,
    this.status,
  });

  @override
  List<Object?> get props => [page, pageSize, name, areaId, machineTypeId, status];
}

/// Event: Load more machines
class LoadMoreMachinesEvent extends MachineEvent {
  const LoadMoreMachinesEvent();
}

/// Event: Load machine by ID
class LoadMachineByIdEvent extends MachineEvent {
  final int machineId;

  const LoadMachineByIdEvent(this.machineId);

  @override
  List<Object?> get props => [machineId];
}

/// Event: Create machine
class CreateMachineEvent extends MachineEvent {
  final MachineEntity machine;

  const CreateMachineEvent(this.machine);

  @override
  List<Object?> get props => [machine];
}

/// Event: Update machine
class UpdateMachineEvent extends MachineEvent {
  final int machineId;
  final MachineEntity machine;

  const UpdateMachineEvent({
    required this.machineId,
    required this.machine,
  });

  @override
  List<Object?> get props => [machineId, machine];
}

/// Event: Delete machine
class DeleteMachineEvent extends MachineEvent {
  final int machineId;

  const DeleteMachineEvent(this.machineId);

  @override
  List<Object?> get props => [machineId];
}

/// Event: Load machine components
class LoadMachineComponentsEvent extends MachineEvent {
  final int machineId;

  const LoadMachineComponentsEvent(this.machineId);

  @override
  List<Object?> get props => [machineId];
}

// ─────────────────────────────────────────────────────────────────────────────
// Machine Type Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event: Load all machine types
class LoadAllMachineTypesEvent extends MachineEvent {
  final int? status;

  const LoadAllMachineTypesEvent({this.status});

  @override
  List<Object?> get props => [status];
}

/// Event: Load machine type list
class LoadMachineTypeListEvent extends MachineEvent {
  final int page;
  final int pageSize;
  final String? name;
  final int? status;

  const LoadMachineTypeListEvent({
    this.page = 1,
    this.pageSize = 10,
    this.name,
    this.status,
  });

  @override
  List<Object?> get props => [page, pageSize, name, status];
}

/// Event: Create machine type
class CreateMachineTypeEvent extends MachineEvent {
  final MachineTypeEntity machineType;

  const CreateMachineTypeEvent(this.machineType);

  @override
  List<Object?> get props => [machineType];
}

/// Event: Update machine type
class UpdateMachineTypeEvent extends MachineEvent {
  final int machineTypeId;
  final MachineTypeEntity machineType;

  const UpdateMachineTypeEvent({
    required this.machineTypeId,
    required this.machineType,
  });

  @override
  List<Object?> get props => [machineTypeId, machineType];
}

/// Event: Delete machine type
class DeleteMachineTypeEvent extends MachineEvent {
  final int machineTypeId;

  const DeleteMachineTypeEvent(this.machineTypeId);

  @override
  List<Object?> get props => [machineTypeId];
}

// ─────────────────────────────────────────────────────────────────────────────
// Machine Part Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event: Load machine part tree
class LoadMachinePartTreeEvent extends MachineEvent {
  const LoadMachinePartTreeEvent();
}

/// Event: Create machine part
class CreateMachinePartEvent extends MachineEvent {
  final MachinePartEntity machinePart;

  const CreateMachinePartEvent(this.machinePart);

  @override
  List<Object?> get props => [machinePart];
}

/// Event: Update machine part
class UpdateMachinePartEvent extends MachineEvent {
  final int machinePartId;
  final MachinePartEntity machinePart;

  const UpdateMachinePartEvent({
    required this.machinePartId,
    required this.machinePart,
  });

  @override
  List<Object?> get props => [machinePartId, machinePart];
}

/// Event: Delete machine part
class DeleteMachinePartEvent extends MachineEvent {
  final int machinePartId;

  const DeleteMachinePartEvent(this.machinePartId);

  @override
  List<Object?> get props => [machinePartId];
}

// ─────────────────────────────────────────────────────────────────────────────
// Common Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event: Clear selected machine
class ClearSelectedMachineEvent extends MachineEvent {
  const ClearSelectedMachineEvent();
}

/// Event: Refresh machine list
class RefreshMachineListEvent extends MachineEvent {
  const RefreshMachineListEvent();
}
