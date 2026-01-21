import 'camera_entity.dart';

/// Domain entity for Area Tree
/// Represents a hierarchical area with nested children
class AreaTree {
  final String uniqueId;
  final int? parentId;
  final String name;
  final String code;
  final int id;
  final String mapType;
  final String? photoPath;
  final double longitude;
  final double latitude;
  final int zoom;
  final String? note;
  final String? levelName;
  final List<AreaTree> children;
  final List<CameraEntity> cameras;
  final String status;
  final String displayStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const AreaTree({
    required this.uniqueId,
    required this.parentId,
    required this.name,
    required this.code,
    required this.id,
    required this.mapType,
    required this.photoPath,
    required this.longitude,
    required this.latitude,
    required this.zoom,
    required this.note,
    required this.levelName,
    required this.children,
    this.cameras = const [],
    required this.status,
    required this.displayStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  /// Create a copy with optional fields replaced
  AreaTree copyWith({
    String? uniqueId,
    int? parentId,
    String? name,
    String? code,
    int? id,
    String? mapType,
    String? photoPath,
    double? longitude,
    double? latitude,
    int? zoom,
    String? note,
    String? levelName,
    List<AreaTree>? children,
    List<CameraEntity>? cameras,
    String? status,
    String? displayStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AreaTree(
      uniqueId: uniqueId ?? this.uniqueId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      code: code ?? this.code,
      id: id ?? this.id,
      mapType: mapType ?? this.mapType,
      photoPath: photoPath ?? this.photoPath,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      zoom: zoom ?? this.zoom,
      note: note ?? this.note,
      levelName: levelName ?? this.levelName,
      children: children ?? this.children,
      cameras: cameras ?? this.cameras,
      status: status ?? this.status,
      displayStatus: displayStatus ?? this.displayStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() => 'AreaTree(id: $id, name: $name, children: ${children.length}, cameras: ${cameras.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaTree &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uniqueId == other.uniqueId;

  @override
  int get hashCode => id.hashCode ^ uniqueId.hashCode;
}
