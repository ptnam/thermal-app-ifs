import 'package:thermal_mobile/data/network/api/base_dto.dart';

/// =============================================================================
/// File: user_dto.dart
/// Description: User data transfer object for User API
/// 
/// Purpose:
/// - Maps to backend's UserDto model
/// - Used for user CRUD operations
/// - Contains user profile information
/// =============================================================================



/// Helper to parse int from String or int
int? _parseIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// User DTO for full user information
/// Maps to backend's UserDto model
class UserDto {
  final int? id;
  final String? userName;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? password;
  final int? roleId;
  final String? roleName;
  final UserStatus status;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserDto({
    this.id,
    this.userName,
    this.fullName,
    this.email,
    this.phone,
    this.password,
    this.roleId,
    this.roleName,
    this.status = UserStatus.active,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Handle both 'userName' and 'username' from API
    final userName = json['userName'] as String? ?? json['username'] as String?;
    
    // Parse status - support both int and string status
    UserStatus userStatus = UserStatus.active;
    if (json['status'] != null) {
      if (json['status'] is int) {
        userStatus = UserStatus.fromValue(json['status'] as int);
      } else if (json['status'] is String) {
        final statusStr = (json['status'] as String).toLowerCase();
        if (statusStr == 'active') {
          userStatus = UserStatus.active;
        } else if (statusStr == 'inactive' || statusStr == 'deleted') {
          userStatus = UserStatus.inactive;
        }
      }
    }
    
    // Extract roleId and roleName from roles array or direct fields
    int? roleId;
    String? roleName;
    
    if (json['roles'] != null && json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      final firstRole = (json['roles'] as List).first;
      roleId = _parseIntOrNull(firstRole['id']);
      roleName = firstRole['name'] as String?;
    } else {
      roleId = _parseIntOrNull(json['roleId']);
      roleName = json['roleName'] as String? ?? json['roleNames'] as String?;
    }
    
    // Parse dates - support DD-MM-YYYY HH:mm:ss format
    DateTime? parseDate(dynamic dateStr) {
      if (dateStr == null) return null;
      if (dateStr is! String) return null;
      
      // Try ISO format first
      var parsed = DateTime.tryParse(dateStr);
      if (parsed != null) return parsed;
      
      // Try DD-MM-YYYY HH:mm:ss format
      try {
        final parts = dateStr.split(' ');
        if (parts.length == 2) {
          final dateParts = parts[0].split('-');
          final timeParts = parts[1].split(':');
          if (dateParts.length == 3 && timeParts.length == 3) {
            return DateTime(
              int.parse(dateParts[2]), // year
              int.parse(dateParts[1]), // month
              int.parse(dateParts[0]), // day
              int.parse(timeParts[0]), // hour
              int.parse(timeParts[1]), // minute
              int.parse(timeParts[2]), // second
            );
          }
        }
      } catch (_) {}
      
      return null;
    }
    
    return UserDto(
      id: _parseIntOrNull(json['id']),
      userName: userName,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String?,
      roleId: roleId,
      roleName: roleName,
      status: userStatus,
      avatar: json['avatar'] as String?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userName != null) 'userName': userName,
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (password != null) 'password': password,
      if (roleId != null) 'roleId': roleId,
      'status': status.value,
      if (avatar != null) 'avatar': avatar,
    };
  }

  UserDto copyWith({
    int? id,
    String? userName,
    String? fullName,
    String? email,
    String? phone,
    String? password,
    int? roleId,
    String? roleName,
    UserStatus? status,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDto(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Base user DTO for minimal user info (dropdown, references)
class BaseUserDto {
  final int id;
  final String? fullName;
  final String? email;

  const BaseUserDto({
    required this.id,
    this.fullName,
    this.email,
  });

  factory BaseUserDto.fromJson(Map<String, dynamic> json) {
    return BaseUserDto(
      id: json['id'] as int? ?? 0,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
    );
  }
}

/// Change password request DTO
class ChangePasswordRequestDto {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequestDto({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}
