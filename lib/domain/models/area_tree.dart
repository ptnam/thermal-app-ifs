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
  final int? mapTypeId;
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
  final int totalWarnings;
  final double? thresholdTemperature;
  final double? environmentTemperature;
  final String? comparationDataMode;
  final int? provinceId;
  final String? emapPhotoPath;

  const AreaTree({
    required this.uniqueId,
    required this.parentId,
    required this.name,
    required this.code,
    required this.id,
    required this.mapType,
    this.mapTypeId,
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
    this.totalWarnings = 0,
    this.thresholdTemperature,
    this.environmentTemperature,
    this.comparationDataMode,
    this.provinceId,
    this.emapPhotoPath,
  });

  /// Create a copy with optional fields replaced
  AreaTree copyWith({
    String? uniqueId,
    int? parentId,
    String? name,
    String? code,
    int? id,
    String? mapType,
    int? mapTypeId,
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
    int? totalWarnings,
    double? thresholdTemperature,
    double? environmentTemperature,
    String? comparationDataMode,
    int? provinceId,
    String? emapPhotoPath,
  }) {
    return AreaTree(
      uniqueId: uniqueId ?? this.uniqueId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      code: code ?? this.code,
      id: id ?? this.id,
      mapType: mapType ?? this.mapType,
      mapTypeId: mapTypeId ?? this.mapTypeId,
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
      totalWarnings: totalWarnings ?? this.totalWarnings,
      thresholdTemperature: thresholdTemperature ?? this.thresholdTemperature,
      environmentTemperature:
          environmentTemperature ?? this.environmentTemperature,
      comparationDataMode: comparationDataMode ?? this.comparationDataMode,
      provinceId: provinceId ?? this.provinceId,
      emapPhotoPath: emapPhotoPath ?? this.emapPhotoPath,
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
