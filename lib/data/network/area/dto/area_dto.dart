/// =============================================================================
/// File: area_dto.dart
/// Description: Area data transfer objects
///
/// Purpose:
/// - Maps to backend's AreaDto models
/// - Used for area hierarchy management
/// - Contains area tree structure with cameras
/// =============================================================================

import 'package:thermal_mobile/data/network/api/base_dto.dart';

import '../../camera/dto/camera_dto.dart';

/// Area DTO for full area information
class AreaDto {
  final int? id;
  final String? name;
  final String? code;
  final String? description;
  final int? parentId;
  final String? parentName;
  final int? level;
  final CommonStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AreaDto>? children;
  final List<CameraShortenDto>? cameras;

  const AreaDto({
    this.id,
    this.name,
    this.code,
    this.description,
    this.parentId,
    this.parentName,
    this.level,
    this.status = CommonStatus.active,
    this.createdAt,
    this.updatedAt,
    this.children,
    this.cameras,
  });

  factory AreaDto.fromJson(Map<String, dynamic> json) {
    // Parse status from statusObject.id if available, otherwise try status field
    int statusValue = 1; // default to active
    if (json['statusObject'] != null && json['statusObject']['id'] != null) {
      statusValue = json['statusObject']['id'] as int;
    } else if (json['status'] is int) {
      statusValue = json['status'] as int;
    }

    return AreaDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      description: json['description'] as String?,
      parentId: json['parentId'] as int?,
      parentName: json['parentName'] as String?,
      level: json['level'] as int?,
      status: CommonStatus.fromValue(statusValue),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => AreaDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      cameras: (json['cameras'] as List<dynamic>?)
          ?.map((e) => CameraShortenDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (parentId != null) 'parentId': parentId,
      'status': status.value,
    };
  }

  AreaDto copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    int? parentId,
    String? parentName,
    int? level,
    CommonStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AreaDto>? children,
    List<CameraShortenDto>? cameras,
  }) {
    return AreaDto(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      level: level ?? this.level,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      children: children ?? this.children,
      cameras: cameras ?? this.cameras,
    );
  }

  /// Check if area has children
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// Check if area has cameras
  bool get hasCameras => cameras != null && cameras!.isNotEmpty;

  /// Get flattened list of all descendants
  List<AreaDto> get allDescendants {
    final result = <AreaDto>[];
    void traverse(AreaDto area) {
      result.add(area);
      if (area.hasChildren) {
        for (final child in area.children!) {
          traverse(child);
        }
      }
    }

    if (hasChildren) {
      for (final child in children!) {
        traverse(child);
      }
    }
    return result;
  }
}

/// Area shorten DTO for lists/dropdowns
class AreaShortenDto {
  final int id;
  final String? name;
  final String? code;
  final int? parentId;
  final int? level;

  const AreaShortenDto({
    required this.id,
    this.name,
    this.code,
    this.parentId,
    this.level,
  });

  factory AreaShortenDto.fromJson(Map<String, dynamic> json) {
    return AreaShortenDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      code: json['code'] as String?,
      parentId: json['parentId'] as int?,
      level: json['level'] as int?,
    );
  }
}
