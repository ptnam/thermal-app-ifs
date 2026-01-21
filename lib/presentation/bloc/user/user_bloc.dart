/// =============================================================================
/// File: user_bloc.dart
/// Description: User BLoC for user management
/// 
/// Purpose:
/// - Handle user-related business logic
/// - Manage user list, profile, CRUD operations
/// - Support pagination and filtering
/// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/user_repository.dart';
import '../../../core/logger/app_logger.dart';
import 'user_event.dart';
import 'user_state.dart';

/// BLoC for managing User operations
/// 
/// Handles:
/// - Current user profile
/// - User list with pagination
/// - User CRUD operations (admin)
/// - Password change
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({
    required IUserRepository userRepository,
    AppLogger? logger,
  })  : _userRepository = userRepository,
        _logger = logger ?? AppLogger(tag: 'UserBloc'),
        super(const UserState()) {
    // Register event handlers
    on<LoadCurrentUserEvent>(_onLoadCurrentUser);
    on<LoadAllUsersEvent>(_onLoadAllUsers);
    on<LoadUserListEvent>(_onLoadUserList);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<LoadUserByIdEvent>(_onLoadUserById);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ClearSelectedUserEvent>(_onClearSelectedUser);
    on<RefreshUserListEvent>(_onRefreshUserList);
  }

  final IUserRepository _userRepository;
  final AppLogger _logger;

  // ─────────────────────────────────────────────────────────────────────────
  // Event Handlers
  // ─────────────────────────────────────────────────────────────────────────

  /// Handle: Load current user profile
  Future<void> _onLoadCurrentUser(
    LoadCurrentUserEvent event,
    Emitter<UserState> emit,
  ) async {
    _logger.info('Loading current user profile');
    emit(state.copyWith(profileStatus: UserStatus.loading, clearError: true));

    final result = await _userRepository.getCurrentUser();

    result.fold(
      (error) {
        _logger.error('Failed to load profile: ${error.message}');
        emit(state.copyWith(
          profileStatus: UserStatus.failure,
          errorMessage: error.message,
        ));
      },
      (user) {
        _logger.info('Profile loaded: ${user.userName}');
        emit(state.copyWith(
          profileStatus: UserStatus.success,
          currentUser: user,
        ));
      },
    );
  }

  /// Handle: Load all users
  Future<void> _onLoadAllUsers(
    LoadAllUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    _logger.info('Loading all users');
    emit(state.copyWith(listStatus: UserStatus.loading, clearError: true));

    final result = await _userRepository.getAllUsers(status: event.status);

    result.fold(
      (error) {
        _logger.error('Failed to load users: ${error.message}');
        emit(state.copyWith(
          listStatus: UserStatus.failure,
          errorMessage: error.message,
        ));
      },
      (users) {
        _logger.info('Loaded ${users.length} users');
        emit(state.copyWith(
          listStatus: UserStatus.success,
          users: users,
        ));
      },
    );
  }

  /// Handle: Load paginated user list
  Future<void> _onLoadUserList(
    LoadUserListEvent event,
    Emitter<UserState> emit,
  ) async {
    _logger.info('Loading user list: page=${event.page}');
    emit(state.copyWith(
      listStatus: UserStatus.loading,
      filterName: event.name,
      filterStatus: event.status,
      filterRoleId: event.roleId,
      clearError: true,
    ));

    final result = await _userRepository.getUserList(
      page: event.page,
      pageSize: event.pageSize,
      name: event.name,
      status: event.status,
      roleId: event.roleId,
    );

    result.fold(
      (error) {
        _logger.error('Failed to load user list: ${error.message}');
        emit(state.copyWith(
          listStatus: UserStatus.failure,
          errorMessage: error.message,
        ));
      },
      (response) {
        _logger.info('Loaded ${response.data.length} users, total: ${response.totalRecords}');
        emit(state.copyWith(
          listStatus: UserStatus.success,
          users: response.data,
          currentPage: response.currentPage,
          pageSize: response.pageSize,
          totalRecords: response.totalRecords,
          totalPages: response.totalPages,
          hasMore: response.currentPage < response.totalPages,
        ));
      },
    );
  }

  /// Handle: Load more users (pagination)
  Future<void> _onLoadMoreUsers(
    LoadMoreUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    if (!state.hasMore || state.listStatus == UserStatus.loading) {
      return;
    }

    final nextPage = state.currentPage + 1;
    _logger.info('Loading more users: page=$nextPage');

    final result = await _userRepository.getUserList(
      page: nextPage,
      pageSize: state.pageSize,
      name: state.filterName,
      status: state.filterStatus,
      roleId: state.filterRoleId,
    );

    result.fold(
      (error) {
        _logger.error('Failed to load more users: ${error.message}');
        emit(state.copyWith(errorMessage: error.message));
      },
      (response) {
        _logger.info('Loaded ${response.data.length} more users');
        emit(state.copyWith(
          users: [...state.users, ...response.data],
          currentPage: response.currentPage,
          hasMore: response.currentPage < response.totalPages,
        ));
      },
    );
  }

  /// Handle: Load user by ID
  Future<void> _onLoadUserById(
    LoadUserByIdEvent event,
    Emitter<UserState> emit,
  ) async {
    _logger.info('Loading user: id=${event.userId}');
    emit(state.copyWith(detailStatus: UserStatus.loading, clearError: true));

    final result = await _userRepository.getUserById(event.userId);

    result.fold(
      (error) {
        _logger.error('Failed to load user: ${error.message}');
        emit(state.copyWith(
          detailStatus: UserStatus.failure,
          errorMessage: error.message,
        ));
      },
      (user) {
        _logger.info('User loaded: ${user.userName}');
        emit(state.copyWith(
          detailStatus: UserStatus.success,
          selectedUser: user,
        ));
      },
    );
  }

  /// Handle: Create new user
  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    _logger.info('Creating user: ${event.user.userName}');
    emit(state.copyWith(operationStatus: UserStatus.loading, clearError: true));

    final result = await _userRepository.createUser(event.user, event.password);

    result.fold(
      (error) {
        _logger.error('Failed to create user: ${error.message}');
        emit(state.copyWith(
          operationStatus: UserStatus.failure,
          errorMessage: error.message,
        ));
      },
      (user) {
        _logger.info('User created: ${user.userName}');
        emit(state.copyWith(
          operationStatus: UserStatus.success,
          users: [user, ...state.users],
          successMessage: 'User created successfully',
        ));
      },
    );
  }

  /// Handle: Update user
  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    _logger.info('Updating user: id=${event.userId}');
    emit(state.copyWith(operationStatus: UserStatus.loading, clearError: true));

    final result = await _userRepository.updateUser(event.userId, event.user);

    result.fold(
      (error) {
        _logger.error('Failed to update user: ${error.message}');
        emit(state.copyWith(
          operationStatus: UserStatus.failure,
          errorMessage: error.message,
        ));
      },
      (user) {
        _logger.info('User updated: ${user.userName}');
        
        // Update user in list
        final updatedUsers = state.users.map((u) {
          return u.id == event.userId ? user : u;
        }).toList();

        emit(state.copyWith(
          operationStatus: UserStatus.success,
          users: updatedUsers,
          selectedUser: user,
          successMessage: 'User updated successfully',
        ));
      },
    );
  }

  /// Handle: Delete user
  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    _logger.info('Deleting user: id=${event.userId}');
    emit(state.copyWith(operationStatus: UserStatus.loading, clearError: true));

    final result = await _userRepository.deleteUser(event.userId);

    result.fold(
      (error) {
        _logger.error('Failed to delete user: ${error.message}');
        emit(state.copyWith(
          operationStatus: UserStatus.failure,
          errorMessage: error.message,
        ));
      },
      (_) {
        _logger.info('User deleted');
        
        // Remove user from list
        final updatedUsers = state.users.where((u) => u.id != event.userId).toList();

        emit(state.copyWith(
          operationStatus: UserStatus.success,
          users: updatedUsers,
          clearSelectedUser: true,
          successMessage: 'User deleted successfully',
        ));
      },
    );
  }

  /// Handle: Update profile (self)
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    _logger.info('Updating profile');
    emit(state.copyWith(operationStatus: UserStatus.loading, clearError: true));

    final result = await _userRepository.updateProfile(event.user);

    result.fold(
      (error) {
        _logger.error('Failed to update profile: ${error.message}');
        emit(state.copyWith(
          operationStatus: UserStatus.failure,
          errorMessage: error.message,
        ));
      },
      (user) {
        _logger.info('Profile updated');
        emit(state.copyWith(
          operationStatus: UserStatus.success,
          currentUser: user,
          successMessage: 'Profile updated successfully',
        ));
      },
    );
  }

  /// Handle: Change password
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<UserState> emit,
  ) async {
    _logger.info('Changing password');
    emit(state.copyWith(operationStatus: UserStatus.loading, clearError: true));

    final result = await _userRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (error) {
        _logger.error('Failed to change password: ${error.message}');
        emit(state.copyWith(
          operationStatus: UserStatus.failure,
          errorMessage: error.message,
        ));
      },
      (_) {
        _logger.info('Password changed');
        emit(state.copyWith(
          operationStatus: UserStatus.success,
          successMessage: 'Password changed successfully',
        ));
      },
    );
  }

  /// Handle: Clear selected user
  void _onClearSelectedUser(
    ClearSelectedUserEvent event,
    Emitter<UserState> emit,
  ) {
    emit(state.copyWith(clearSelectedUser: true));
  }

  /// Handle: Refresh user list
  Future<void> _onRefreshUserList(
    RefreshUserListEvent event,
    Emitter<UserState> emit,
  ) async {
    add(LoadUserListEvent(
      page: 1,
      pageSize: state.pageSize,
      name: state.filterName,
      status: state.filterStatus,
      roleId: state.filterRoleId,
    ));
  }
}
