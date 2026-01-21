/// =============================================================================
/// File: camera_entity.dart
/// Description: Camera domain entity
/// 
/// Purpose:
/// - Pure domain model for camera management
/// - Used in thermal camera monitoring
/// =============================================================================

import 'machine_entity.dart';

/// Camera type classification
enum CameraTypeEntity {
  thermal,
  optical,
  hybrid,
}

/// Domain entity representing a Camera
class CameraEntity {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final int? areaId;
  final String? areaName;
  final CameraTypeEntity? cameraType;
  final EntityStatus status;
  final String? ipAddress;
  final int? port;
  final String? username;
  final String? password;
  final String? streamUrl;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CameraEntity({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.areaId,
    this.areaName,
    this.cameraType,
    this.status = EntityStatus.active,
    this.ipAddress,
    this.port,
    this.username,
    this.password,
    this.streamUrl,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == EntityStatus.active;
  bool get isThermal => cameraType == CameraTypeEntity.thermal;
  bool get hasStream => streamUrl?.isNotEmpty == true;
  bool get hasThumbnail => thumbnailUrl?.isNotEmpty == true;

  CameraEntity copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    int? areaId,
    String? areaName,
    CameraTypeEntity? cameraType,
    EntityStatus? status,
    String? ipAddress,
    int? port,
    String? username,
    String? password,
    String? streamUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CameraEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      cameraType: cameraType ?? this.cameraType,
      status: status ?? this.status,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      streamUrl: streamUrl ?? this.streamUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CameraEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CameraEntity(id: $id, name: $name)';
}
