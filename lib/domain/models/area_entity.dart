/// =============================================================================
/// File: area_entity.dart
/// Description: Area domain entity
/// 
/// Purpose:
/// - Pure domain model for area hierarchy
/// - Contains nested structure for area tree
/// =============================================================================

import 'machine_entity.dart';
import 'camera_entity.dart';

/// Domain entity representing an Area
class AreaEntity {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final int? parentId;
  final String? parentName;
  final int? level;
  final EntityStatus status;
  final List<AreaEntity>? children;
  final List<CameraEntity>? cameras;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AreaEntity({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.parentId,
    this.parentName,
    this.level,
    this.status = EntityStatus.active,
    this.children,
    this.cameras,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == EntityStatus.active;
  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get hasCameras => cameras != null && cameras!.isNotEmpty;
  bool get isRoot => parentId == null;

  /// Get total camera count including children
  int get totalCameraCount {
    int count = cameras?.length ?? 0;
    if (hasChildren) {
      for (final child in children!) {
        count += child.totalCameraCount;
      }
    }
    return count;
  }

  /// Get flattened list of all descendant areas
  List<AreaEntity> get allDescendants {
    final result = <AreaEntity>[];
    void traverse(AreaEntity area) {
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

  /// Get all cameras from this area and descendants
  List<CameraEntity> get allCameras {
    final result = <CameraEntity>[];
    if (hasCameras) result.addAll(cameras!);
    if (hasChildren) {
      for (final child in children!) {
        result.addAll(child.allCameras);
      }
    }
    return result;
  }

  AreaEntity copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    int? parentId,
    String? parentName,
    int? level,
    EntityStatus? status,
    List<AreaEntity>? children,
    List<CameraEntity>? cameras,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AreaEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      level: level ?? this.level,
      status: status ?? this.status,
      children: children ?? this.children,
      cameras: cameras ?? this.cameras,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AreaEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AreaEntity(id: $id, name: $name)';
}
