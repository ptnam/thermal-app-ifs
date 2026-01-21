/// =============================================================================
/// File: user_event.dart
/// Description: User BLoC events
/// 
/// Purpose:
/// - Define all events that can be dispatched to UserBloc
/// - Each event represents a user action or intent
/// =============================================================================

import 'package:equatable/equatable.dart';
import 'package:thermal_mobile/domain/models/user_entity.dart';

/// Base class for all user events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load current user profile
class LoadCurrentUserEvent extends UserEvent {
  const LoadCurrentUserEvent();
}

/// Event: Load all users (admin)
class LoadAllUsersEvent extends UserEvent {
  final int? status;

  const LoadAllUsersEvent({this.status});

  @override
  List<Object?> get props => [status];
}

/// Event: Load paginated user list
class LoadUserListEvent extends UserEvent {
  final int page;
  final int pageSize;
  final String? name;
  final int? status;
  final int? roleId;

  const LoadUserListEvent({
    this.page = 1,
    this.pageSize = 10,
    this.name,
    this.status,
    this.roleId,
  });

  @override
  List<Object?> get props => [page, pageSize, name, status, roleId];
}

/// Event: Load more users (pagination)
class LoadMoreUsersEvent extends UserEvent {
  const LoadMoreUsersEvent();
}

/// Event: Load user by ID
class LoadUserByIdEvent extends UserEvent {
  final int userId;

  const LoadUserByIdEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event: Create new user
class CreateUserEvent extends UserEvent {
  final UserEntity user;
  final String password;

  const CreateUserEvent({
    required this.user,
    required this.password,
  });

  @override
  List<Object?> get props => [user, password];
}

/// Event: Update user
class UpdateUserEvent extends UserEvent {
  final int userId;
  final UserEntity user;

  const UpdateUserEvent({
    required this.userId,
    required this.user,
  });

  @override
  List<Object?> get props => [userId, user];
}

/// Event: Delete user
class DeleteUserEvent extends UserEvent {
  final int userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event: Update profile (self)
class UpdateProfileEvent extends UserEvent {
  final UserEntity user;

  const UpdateProfileEvent(this.user);

  @override
  List<Object?> get props => [user];
}

/// Event: Change password
class ChangePasswordEvent extends UserEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Event: Clear user selection
class ClearSelectedUserEvent extends UserEvent {
  const ClearSelectedUserEvent();
}

/// Event: Refresh user list
class RefreshUserListEvent extends UserEvent {
  const RefreshUserListEvent();
}
