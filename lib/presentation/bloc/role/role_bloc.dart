/// =============================================================================
/// File: role_bloc.dart
/// Description: BLoC for Role management
///
/// Purpose:
/// - Handle role CRUD operations
/// - Handle feature loading
/// - Manage pagination and filters
/// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/domain/models/role_entity.dart';
import '../../../domain/repositories/role_repository.dart';
import 'role_event.dart';
import 'role_state.dart';

/// BLoC for Role management.
///
/// Handles:
/// - Role list with pagination
/// - Role CRUD operations
/// - Feature loading for role assignment
class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final IRoleRepository _roleRepository;

  RoleBloc({required IRoleRepository roleRepository})
    : _roleRepository = roleRepository,
      super(RoleState.initial()) {
    // Role events
    on<LoadAllRolesEvent>(_onLoadAllRoles);
    on<LoadRoleListEvent>(_onLoadRoleList);
    on<LoadRoleByIdEvent>(_onLoadRoleById);
    on<CreateRoleEvent>(_onCreateRole);
    on<UpdateRoleEvent>(_onUpdateRole);
    on<DeleteRoleEvent>(_onDeleteRole);

    // Feature events
    on<LoadAllFeaturesEvent>(_onLoadAllFeatures);

    // State management events
    on<ResetRoleOperationStatusEvent>(_onResetOperationStatus);
    on<ClearSelectedRoleEvent>(_onClearSelectedRole);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Role Event Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Load all roles (for dropdowns)
  Future<void> _onLoadAllRoles(
    LoadAllRolesEvent event,
    Emitter<RoleState> emit,
  ) async {
    emit(state.copyWith(listStatus: RoleStatus.loading));

    final result = await _roleRepository.getAllRoles();

    result.fold(
      (error) => emit(
        state.copyWith(
          listStatus: RoleStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (roles) => emit(
        state.copyWith(
          listStatus: RoleStatus.success,
          allRoles: roles,
          clearError: true,
        ),
      ),
    );
  }

  /// Load paginated role list
  Future<void> _onLoadRoleList(
    LoadRoleListEvent event,
    Emitter<RoleState> emit,
  ) async {
    emit(
      state.copyWith(
        listStatus: RoleStatus.loading,
        searchKeyword: event.searchKeyword,
        statusFilter: event.status,
      ),
    );

    final result = await _roleRepository.getRoleList(
      page: event.page,
      pageSize: event.pageSize,
      name: event.searchKeyword,
      status: _parseStatus(event.status),
    );

    result.fold(
      (error) => emit(
        state.copyWith(
          listStatus: RoleStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (pagingResponse) => emit(
        state.copyWith(
          listStatus: RoleStatus.success,
          roles: pagingResponse.data,
          currentPage: pagingResponse.currentPage,
          pageSize: pagingResponse.pageSize,
          totalRecords: pagingResponse.totalRecords,
          totalPages: pagingResponse.totalPages,
          clearError: true,
        ),
      ),
    );
  }

  /// Load role by ID
  Future<void> _onLoadRoleById(
    LoadRoleByIdEvent event,
    Emitter<RoleState> emit,
  ) async {
    emit(state.copyWith(detailStatus: RoleStatus.loading));

    final result = await _roleRepository.getRoleById(event.id);

    result.fold(
      (error) => emit(
        state.copyWith(
          detailStatus: RoleStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (role) => emit(
        state.copyWith(
          detailStatus: RoleStatus.success,
          selectedRole: role,
          clearError: true,
        ),
      ),
    );
  }

  /// Create new role
  Future<void> _onCreateRole(
    CreateRoleEvent event,
    Emitter<RoleState> emit,
  ) async {
    emit(state.copyWith(operationStatus: RoleStatus.loading));

    final newRole = RoleEntity(
      id: 0, // Will be assigned by backend
      name: event.name,
      description: event.description,
      features: event.featureIds
          ?.map((id) => FeatureEntity(id: id, code: ''))
          .toList(),
    );

    final result = await _roleRepository.createRole(newRole);

    result.fold(
      (error) => emit(
        state.copyWith(
          operationStatus: RoleStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (createdRole) => emit(
        state.copyWith(
          operationStatus: RoleStatus.success,
          operationResult: createdRole,
          clearError: true,
        ),
      ),
    );
  }

  /// Update existing role
  Future<void> _onUpdateRole(
    UpdateRoleEvent event,
    Emitter<RoleState> emit,
  ) async {
    emit(state.copyWith(operationStatus: RoleStatus.loading));

    final updatedRole = RoleEntity(
      id: event.id,
      name: event.name ?? state.selectedRole?.name ?? '',
      description: event.description ?? state.selectedRole?.description,
      isActive: event.status == '1' || event.status == 'active',
      features: event.featureIds
          ?.map((id) => FeatureEntity(id: id, code: ''))
          .toList(),
    );

    final result = await _roleRepository.updateRole(event.id, updatedRole);

    result.fold(
      (error) => emit(
        state.copyWith(
          operationStatus: RoleStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (role) => emit(
        state.copyWith(
          operationStatus: RoleStatus.success,
          operationResult: role,
          selectedRole: role,
          clearError: true,
        ),
      ),
    );
  }

  /// Delete role
  Future<void> _onDeleteRole(
    DeleteRoleEvent event,
    Emitter<RoleState> emit,
  ) async {
    emit(state.copyWith(operationStatus: RoleStatus.loading));

    final result = await _roleRepository.deleteRole(event.id);

    result.fold(
      (error) => emit(
        state.copyWith(
          operationStatus: RoleStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          operationStatus: RoleStatus.success,
          clearError: true,
          clearSelectedRole: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Feature Event Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Load all features
  Future<void> _onLoadAllFeatures(
    LoadAllFeaturesEvent event,
    Emitter<RoleState> emit,
  ) async {
    emit(state.copyWith(featureStatus: RoleStatus.loading));

    final result = await _roleRepository.getAllFeatures();

    result.fold(
      (error) => emit(
        state.copyWith(
          featureStatus: RoleStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (features) => emit(
        state.copyWith(
          featureStatus: RoleStatus.success,
          allFeatures: features,
          clearError: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // State Management Event Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Reset operation status
  void _onResetOperationStatus(
    ResetRoleOperationStatusEvent event,
    Emitter<RoleState> emit,
  ) {
    emit(
      state.copyWith(
        operationStatus: RoleStatus.initial,
        clearOperationResult: true,
        clearError: true,
      ),
    );
  }

  /// Clear selected role
  void _onClearSelectedRole(
    ClearSelectedRoleEvent event,
    Emitter<RoleState> emit,
  ) {
    emit(
      state.copyWith(clearSelectedRole: true, detailStatus: RoleStatus.initial),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Parse status string to int
  int? _parseStatus(String? status) {
    if (status == null || status.isEmpty) return null;
    if (status == 'active' || status == '1') return 1;
    if (status == 'inactive' || status == '0') return 0;
    return int.tryParse(status);
  }
}
