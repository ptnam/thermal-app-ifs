/// =============================================================================
/// File: role_state.dart
/// Description: State for RoleBloc
/// =============================================================================

import 'package:equatable/equatable.dart';
import 'package:thermal_mobile/domain/models/role_entity.dart';

/// Status for async operations in RoleBloc.
enum RoleStatus {
  initial,
  loading,
  success,
  failure,
}

/// State for RoleBloc.
class RoleState extends Equatable {
  // ─────────────────────────────────────────────────────────────────────────────
  // Role State
  // ─────────────────────────────────────────────────────────────────────────────

  /// All roles (for dropdowns).
  final List<RoleEntity> allRoles;

  /// Paginated role list.
  final List<RoleEntity> roles;

  /// Currently selected/viewed role.
  final RoleEntity? selectedRole;

  /// Status for role list operations.
  final RoleStatus listStatus;

  /// Status for role detail operations.
  final RoleStatus detailStatus;

  /// Status for role CRUD operations.
  final RoleStatus operationStatus;

  // ─────────────────────────────────────────────────────────────────────────────
  // Feature State
  // ─────────────────────────────────────────────────────────────────────────────

  /// All features (flat list).
  final List<FeatureEntity> allFeatures;

  /// Feature tree (hierarchical structure).
  final List<FeatureEntity> featureTree;

  /// Status for feature loading.
  final RoleStatus featureStatus;

  // ─────────────────────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────────────────────

  /// Current page.
  final int currentPage;

  /// Page size.
  final int pageSize;

  /// Total records.
  final int totalRecords;

  /// Total pages.
  final int totalPages;

  // ─────────────────────────────────────────────────────────────────────────────
  // Filters
  // ─────────────────────────────────────────────────────────────────────────────

  /// Search keyword filter.
  final String? searchKeyword;

  /// Status filter.
  final String? statusFilter;

  // ─────────────────────────────────────────────────────────────────────────────
  // Error & Operation Result
  // ─────────────────────────────────────────────────────────────────────────────

  /// Error message when operation fails.
  final String? errorMessage;

  /// Result of last CRUD operation.
  final RoleEntity? operationResult;

  const RoleState({
    this.allRoles = const [],
    this.roles = const [],
    this.selectedRole,
    this.listStatus = RoleStatus.initial,
    this.detailStatus = RoleStatus.initial,
    this.operationStatus = RoleStatus.initial,
    this.allFeatures = const [],
    this.featureTree = const [],
    this.featureStatus = RoleStatus.initial,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalRecords = 0,
    this.totalPages = 0,
    this.searchKeyword,
    this.statusFilter,
    this.errorMessage,
    this.operationResult,
  });

  /// Initial state factory.
  factory RoleState.initial() => const RoleState();

  /// Creates a copy of this state with specified fields replaced.
  RoleState copyWith({
    List<RoleEntity>? allRoles,
    List<RoleEntity>? roles,
    RoleEntity? selectedRole,
    RoleStatus? listStatus,
    RoleStatus? detailStatus,
    RoleStatus? operationStatus,
    List<FeatureEntity>? allFeatures,
    List<FeatureEntity>? featureTree,
    RoleStatus? featureStatus,
    int? currentPage,
    int? pageSize,
    int? totalRecords,
    int? totalPages,
    String? searchKeyword,
    String? statusFilter,
    String? errorMessage,
    RoleEntity? operationResult,
    bool clearSelectedRole = false,
    bool clearOperationResult = false,
    bool clearError = false,
  }) {
    return RoleState(
      allRoles: allRoles ?? this.allRoles,
      roles: roles ?? this.roles,
      selectedRole: clearSelectedRole ? null : (selectedRole ?? this.selectedRole),
      listStatus: listStatus ?? this.listStatus,
      detailStatus: detailStatus ?? this.detailStatus,
      operationStatus: operationStatus ?? this.operationStatus,
      allFeatures: allFeatures ?? this.allFeatures,
      featureTree: featureTree ?? this.featureTree,
      featureStatus: featureStatus ?? this.featureStatus,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      operationResult: clearOperationResult ? null : (operationResult ?? this.operationResult),
    );
  }

  @override
  List<Object?> get props => [
        allRoles,
        roles,
        selectedRole,
        listStatus,
        detailStatus,
        operationStatus,
        allFeatures,
        featureTree,
        featureStatus,
        currentPage,
        pageSize,
        totalRecords,
        totalPages,
        searchKeyword,
        statusFilter,
        errorMessage,
        operationResult,
      ];
}
