/// =============================================================================
/// File: user_entity.dart
/// Description: User domain entity
/// 
/// Purpose:
/// - Pure domain model for user business logic
/// - Independent of API layer DTOs
/// - Contains only essential business attributes
/// =============================================================================

import 'role_entity.dart';

/// User status in the system
enum UserStatusEntity {
  active,
  inactive,
  banned,
}

/// Domain entity representing a User
class UserEntity {
  final int id;
  final String userName;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final int? roleId;
  final String? roleName;
  final RoleEntity? role;
  final UserStatusEntity status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.userName,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.roleId,
    this.roleName,
    this.role,
    this.status = UserStatusEntity.active,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if user is active
  bool get isActive => status == UserStatusEntity.active;

  /// Check if user has a role
  bool get hasRole => roleId != null || role != null;

  /// Get display name (fullName or userName)
  String get displayName => fullName?.isNotEmpty == true ? fullName! : userName;

  UserEntity copyWith({
    int? id,
    String? userName,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    int? roleId,
    String? roleName,
    RoleEntity? role,
    UserStatusEntity? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserEntity(id: $id, userName: $userName, email: $email)';
}
