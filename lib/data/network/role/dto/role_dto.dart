/// =============================================================================
/// File: role_dto.dart
/// Description: Role data transfer object for Role API
/// 
/// Purpose:
/// - Maps to backend's RoleDto model
/// - Used for role CRUD operations
/// - Contains role and permission information
/// =============================================================================

import 'package:thermal_mobile/data/network/api/base_dto.dart';

/// Helper to parse int from String or int
int? _parseIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// Role DTO for full role information
/// Maps to backend's RoleDto model
class RoleDto {
  final int? id;
  final String? name;
  final String? description;
  final CommonStatus status;
  final List<int>? featureIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleDto({
    this.id,
    this.name,
    this.description,
    this.status = CommonStatus.active,
    this.featureIds,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    return RoleDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: CommonStatus.fromValue(_parseIntOrNull(json['status']) ?? 1),
      featureIds: (json['featureIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      'status': status.value,
      if (featureIds != null) 'featureIds': featureIds,
    };
  }

  RoleDto copyWith({
    int? id,
    String? name,
    String? description,
    CommonStatus? status,
    List<int>? featureIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      featureIds: featureIds ?? this.featureIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Feature DTO for permissions/features
class FeatureDto {
  final int id;
  final String? name;
  final String? description;
  final String? code;

  const FeatureDto({
    required this.id,
    this.name,
    this.description,
    this.code,
  });

  factory FeatureDto.fromJson(Map<String, dynamic> json) {
    return FeatureDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      description: json['description'] as String?,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (code != null) 'code': code,
    };
  }
}
