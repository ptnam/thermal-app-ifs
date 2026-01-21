import 'package:thermal_mobile/data/network/api/base_dto.dart';

/// =============================================================================
/// File: machine_dto.dart
/// Description: Machine data transfer objects for Machine API
/// 
/// Purpose:
/// - Maps to backend's MachineDto, MachineThermal models
/// - Used for machine CRUD operations
/// - Contains machine, machine type, and component information
/// =============================================================================



/// Helper to parse int from String or int
int? _parseIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// Machine DTO for full machine information
/// Maps to backend's MachineDto model
class MachineDto {
  final int? id;
  final String? name;
  final String? code;
  final String? description;
  final int? areaId;
  final String? areaName;
  final int? machineTypeId;
  final String? machineTypeName;
  final CommonStatus status;
  final String? photo;
  final double? positionX;
  final double? positionY;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MachineDto({
    this.id,
    this.name,
    this.code,
    this.description,
    this.areaId,
    this.areaName,
    this.machineTypeId,
    this.machineTypeName,
    this.status = CommonStatus.active,
    this.photo,
    this.positionX,
    this.positionY,
    this.createdAt,
    this.updatedAt,
  });

  factory MachineDto.fromJson(Map<String, dynamic> json) {
    return MachineDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      description: json['description'] as String?,
      areaId: json['areaId'] as int?,
      areaName: json['areaName'] as String?,
      machineTypeId: json['machineTypeId'] as int?,
      machineTypeName: json['machineTypeName'] as String?,
      status: CommonStatus.fromValue(_parseIntOrNull(json['status']) ?? 1),
      photo: json['photo'] as String?,
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
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
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (areaId != null) 'areaId': areaId,
      if (machineTypeId != null) 'machineTypeId': machineTypeId,
      'status': status.value,
      if (photo != null) 'photo': photo,
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
    };
  }

  MachineDto copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    int? areaId,
    String? areaName,
    int? machineTypeId,
    String? machineTypeName,
    CommonStatus? status,
    String? photo,
    double? positionX,
    double? positionY,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MachineDto(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      machineTypeId: machineTypeId ?? this.machineTypeId,
      machineTypeName: machineTypeName ?? this.machineTypeName,
      status: status ?? this.status,
      photo: photo ?? this.photo,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Machine component info DTO
/// Contains machine with its components for dashboard/map display
class MachineComponentInfo {
  final int machineId;
  final String? machineName;
  final String? machineCode;
  final double? positionX;
  final double? positionY;
  final List<ShortenBaseDto> components;

  const MachineComponentInfo({
    required this.machineId,
    this.machineName,
    this.machineCode,
    this.positionX,
    this.positionY,
    this.components = const [],
  });

  factory MachineComponentInfo.fromJson(Map<String, dynamic> json) {
    return MachineComponentInfo(
      machineId: json['machineId'] as int? ?? 0,
      machineName: json['machineName'] as String?,
      machineCode: json['machineCode'] as String?,
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
      components: (json['components'] as List<dynamic>?)
              ?.map((e) => ShortenBaseDto.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Machine thermal DTO for machine with thermal monitoring info
class MachineThermal {
  final int id;
  final String? name;
  final String? code;
  final int? areaId;
  final List<dynamic>? monitorPoints;

  const MachineThermal({
    required this.id,
    this.name,
    this.code,
    this.areaId,
    this.monitorPoints,
  });

  factory MachineThermal.fromJson(Map<String, dynamic> json) {
    return MachineThermal(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      code: json['code'] as String?,
      areaId: json['areaId'] as int?,
      monitorPoints: json['monitorPoints'] as List<dynamic>?,
    );
  }
}

/// Request DTO for fetching machines by areas
class MachineInfoRequest {
  final List<int> areaIds;
  final String token;

  const MachineInfoRequest({
    required this.areaIds,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'areaIds': areaIds,
      'token': token,
    };
  }
}
