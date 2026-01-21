import 'package:thermal_mobile/data/network/api/base_dto.dart';

/// =============================================================================
/// File: camera_dto.dart
/// Description: Camera data transfer objects for Camera API
/// 
/// Purpose:
/// - Maps to backend's CameraDto models
/// - Used for camera CRUD operations
/// - Contains camera stream and settings information
/// =============================================================================

/// Helper to parse int from either int or String
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// Camera DTO for full camera information
class CameraDto {
  final int? id;
  final String? name;
  final String? code;
  final String? description;
  final int? areaId;
  final String? areaName;
  final CameraType? cameraType;
  final CommonStatus status;
  final String? ipAddress;
  final int? port;
  final String? username;
  final String? password;
  final String? streamUrl;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? monitorPoints;

  const CameraDto({
    this.id,
    this.name,
    this.code,
    this.description,
    this.areaId,
    this.areaName,
    this.cameraType,
    this.status = CommonStatus.active,
    this.ipAddress,
    this.port,
    this.username,
    this.password,
    this.streamUrl,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
    this.monitorPoints,
  });

  factory CameraDto.fromJson(Map<String, dynamic> json) {
    return CameraDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      description: json['description'] as String?,
      areaId: json['areaId'] as int?,
      areaName: json['areaName'] as String?,
      cameraType: json['cameraType'] != null
          ? CameraType.fromValue(_parseInt(json['cameraType']) ?? 0)
          : null,
      status: CommonStatus.fromValue(_parseInt(json['status']) ?? 1),
      ipAddress: json['ipAddress'] as String?,
      port: json['port'] != null ? _parseInt(json['port']) : null,
      username: json['username'] as String?,
      password: json['password'] as String?,
      streamUrl: json['streamUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      monitorPoints: json['monitorPoints'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (areaId != null) 'areaId': areaId,
      if (cameraType != null) 'cameraType': cameraType!.value,
      'status': status.value,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (port != null) 'port': port,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (streamUrl != null) 'streamUrl': streamUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }

  CameraDto copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    int? areaId,
    String? areaName,
    CameraType? cameraType,
    CommonStatus? status,
    String? ipAddress,
    int? port,
    String? username,
    String? password,
    String? streamUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<dynamic>? monitorPoints,
  }) {
    return CameraDto(
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
      monitorPoints: monitorPoints ?? this.monitorPoints,
    );
  }
}

/// Camera shorten DTO for lists
class CameraShortenDto {
  final int id;
  final String? name;
  final String? code;
  final int? areaId;
  final CameraType? cameraType;
  final String? streamUrl;
  final String? thumbnailUrl;

  const CameraShortenDto({
    required this.id,
    this.name,
    this.code,
    this.areaId,
    this.cameraType,
    this.streamUrl,
    this.thumbnailUrl,
  });

  factory CameraShortenDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    return CameraShortenDto(
      id: parseInt(json['id']),
      name: json['name'] as String?,
      code: json['code'] as String?,
      areaId: json['areaId'] != null ? parseInt(json['areaId']) : null,
      cameraType: json['cameraType'] != null
          ? CameraType.fromValue(parseInt(json['cameraType']))
          : null,
      streamUrl: json['streamUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}

/// Camera setting DTO
class CameraSettingDto {
  final int? id;
  final int? userId;
  final List<int>? pinnedCameraIds;

  const CameraSettingDto({
    this.id,
    this.userId,
    this.pinnedCameraIds,
  });

  factory CameraSettingDto.fromJson(Map<String, dynamic> json) {
    return CameraSettingDto(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      pinnedCameraIds: (json['pinnedCameraIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );
  }
}

/// Favourite camera request
class FavouriteCameraRequest {
  final int cameraId;
  final bool isFavourite;

  const FavouriteCameraRequest({
    required this.cameraId,
    required this.isFavourite,
  });

  Map<String, dynamic> toJson() {
    return {
      'cameraId': cameraId,
      'isFavourite': isFavourite,
    };
  }
}
