/// =============================================================================
/// File: user_state.dart
/// Description: User BLoC states
/// 
/// Purpose:
/// - Define all possible states for UserBloc
/// - Each state represents the current UI state
/// =============================================================================

import 'package:equatable/equatable.dart';
import 'package:thermal_mobile/domain/models/user_entity.dart';

/// Status of async operations
enum UserStatus {
  initial,
  loading,
  success,
  failure,
}

/// State class for User BLoC
class UserState extends Equatable {
  // ─────────────────────────────────────────────────────────────────────────
  // Status Flags
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Current user profile loading status
  final UserStatus profileStatus;

  /// User list loading status
  final UserStatus listStatus;

  /// User detail loading status
  final UserStatus detailStatus;

  /// User create/update/delete operation status
  final UserStatus operationStatus;

  // ─────────────────────────────────────────────────────────────────────────
  // Data
  // ─────────────────────────────────────────────────────────────────────────

  /// Current logged-in user
  final UserEntity? currentUser;

  /// List of users for admin view
  final List<UserEntity> users;

  /// Selected user for detail view
  final UserEntity? selectedUser;

  // ─────────────────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────────────────

  /// Current page number
  final int currentPage;

  /// Page size
  final int pageSize;

  /// Total number of records
  final int totalRecords;

  /// Total number of pages
  final int totalPages;

  /// Whether more data is available
  final bool hasMore;

  // ─────────────────────────────────────────────────────────────────────────
  // Filters
  // ─────────────────────────────────────────────────────────────────────────

  /// Filter by name
  final String? filterName;

  /// Filter by status
  final int? filterStatus;

  /// Filter by role
  final int? filterRoleId;

  // ─────────────────────────────────────────────────────────────────────────
  // Error & Message
  // ─────────────────────────────────────────────────────────────────────────

  /// Error message if any operation fails
  final String? errorMessage;

  /// Success message after operation
  final String? successMessage;

  const UserState({
    this.profileStatus = UserStatus.initial,
    this.listStatus = UserStatus.initial,
    this.detailStatus = UserStatus.initial,
    this.operationStatus = UserStatus.initial,
    this.currentUser,
    this.users = const [],
    this.selectedUser,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalRecords = 0,
    this.totalPages = 0,
    this.hasMore = false,
    this.filterName,
    this.filterStatus,
    this.filterRoleId,
    this.errorMessage,
    this.successMessage,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Check if any loading operation is in progress
  bool get isLoading =>
      profileStatus == UserStatus.loading ||
      listStatus == UserStatus.loading ||
      detailStatus == UserStatus.loading ||
      operationStatus == UserStatus.loading;

  /// Check if profile is loaded
  bool get hasProfile =>
      profileStatus == UserStatus.success && currentUser != null;

  /// Check if list is empty
  bool get isEmpty => users.isEmpty && listStatus == UserStatus.success;

  /// Check if has error
  bool get hasError => errorMessage != null;

  // ─────────────────────────────────────────────────────────────────────────
  // Copy With
  // ─────────────────────────────────────────────────────────────────────────

  UserState copyWith({
    UserStatus? profileStatus,
    UserStatus? listStatus,
    UserStatus? detailStatus,
    UserStatus? operationStatus,
    UserEntity? currentUser,
    List<UserEntity>? users,
    UserEntity? selectedUser,
    int? currentPage,
    int? pageSize,
    int? totalRecords,
    int? totalPages,
    bool? hasMore,
    String? filterName,
    int? filterStatus,
    int? filterRoleId,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedUser = false,
  }) {
    return UserState(
      profileStatus: profileStatus ?? this.profileStatus,
      listStatus: listStatus ?? this.listStatus,
      detailStatus: detailStatus ?? this.detailStatus,
      operationStatus: operationStatus ?? this.operationStatus,
      currentUser: currentUser ?? this.currentUser,
      users: users ?? this.users,
      selectedUser: clearSelectedUser ? null : (selectedUser ?? this.selectedUser),
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      filterName: filterName ?? this.filterName,
      filterStatus: filterStatus ?? this.filterStatus,
      filterRoleId: filterRoleId ?? this.filterRoleId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        profileStatus,
        listStatus,
        detailStatus,
        operationStatus,
        currentUser,
        users,
        selectedUser,
        currentPage,
        pageSize,
        totalRecords,
        totalPages,
        hasMore,
        filterName,
        filterStatus,
        filterRoleId,
        errorMessage,
        successMessage,
      ];
}
