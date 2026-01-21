/// =============================================================================
/// File: role_event.dart
/// Description: Events for RoleBloc
/// =============================================================================

import 'package:equatable/equatable.dart';

/// Base class for all role events.
abstract class RoleEvent extends Equatable {
  const RoleEvent();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// Role Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event to load all roles (for dropdowns).
class LoadAllRolesEvent extends RoleEvent {
  const LoadAllRolesEvent();
}

/// Event to load role list with pagination.
class LoadRoleListEvent extends RoleEvent {
  final int page;
  final int pageSize;
  final String? searchKeyword;
  final String? status;

  const LoadRoleListEvent({
    this.page = 1,
    this.pageSize = 10,
    this.searchKeyword,
    this.status,
  });

  @override
  List<Object?> get props => [page, pageSize, searchKeyword, status];
}

/// Event to load a specific role by ID.
class LoadRoleByIdEvent extends RoleEvent {
  final int id;

  const LoadRoleByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event to create a new role.
class CreateRoleEvent extends RoleEvent {
  final String name;
  final String? description;
  final List<int>? featureIds;

  const CreateRoleEvent({
    required this.name,
    this.description,
    this.featureIds,
  });

  @override
  List<Object?> get props => [name, description, featureIds];
}

/// Event to update an existing role.
class UpdateRoleEvent extends RoleEvent {
  final int id;
  final String? name;
  final String? description;
  final String? status;
  final List<int>? featureIds;

  const UpdateRoleEvent({
    required this.id,
    this.name,
    this.description,
    this.status,
    this.featureIds,
  });

  @override
  List<Object?> get props => [id, name, description, status, featureIds];
}

/// Event to delete a role.
class DeleteRoleEvent extends RoleEvent {
  final int id;

  const DeleteRoleEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event to load all features (flat list).
class LoadAllFeaturesEvent extends RoleEvent {
  const LoadAllFeaturesEvent();
}

/// Event to load feature tree (hierarchical structure).
class LoadFeatureTreeEvent extends RoleEvent {
  const LoadFeatureTreeEvent();
}

// ─────────────────────────────────────────────────────────────────────────────
// State Management Events
// ─────────────────────────────────────────────────────────────────────────────

/// Event to reset operation status.
class ResetRoleOperationStatusEvent extends RoleEvent {
  const ResetRoleOperationStatusEvent();
}

/// Event to clear selected role.
class ClearSelectedRoleEvent extends RoleEvent {
  const ClearSelectedRoleEvent();
}
