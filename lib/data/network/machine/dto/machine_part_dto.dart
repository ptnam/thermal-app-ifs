/// =============================================================================
/// File: machine_part_dto.dart
/// Description: Machine Part data transfer object
/// 
/// Purpose:
/// - Maps to backend's MachinePartDto model
/// - Used for machine part/component management
/// =============================================================================

import 'package:thermal_mobile/data/network/api/base_dto.dart';

/// Machine Part DTO
class MachinePartDto {
  final int? id;
  final String? name;
  final String? description;
  final int? machineTypeId;
  final String? machineTypeName;
  final int? parentId;
  final String? parentName;
  final CommonStatus status;
  final List<MachinePartDto>? children;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MachinePartDto({
    this.id,
    this.name,
    this.description,
    this.machineTypeId,
    this.machineTypeName,
    this.parentId,
    this.parentName,
    this.status = CommonStatus.active,
    this.children,
    this.createdAt,
    this.updatedAt,
  });

  factory MachinePartDto.fromJson(Map<String, dynamic> json) {
    return MachinePartDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      machineTypeId: json['machineTypeId'] as int?,
      machineTypeName: json['machineTypeName'] as String?,
      parentId: json['parentId'] as int?,
      parentName: json['parentName'] as String?,
      status: CommonStatus.fromValue(json['status'] as int? ?? 1),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => MachinePartDto.fromJson(e as Map<String, dynamic>))
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
      if (machineTypeId != null) 'machineTypeId': machineTypeId,
      if (parentId != null) 'parentId': parentId,
      'status': status.value,
    };
  }

  MachinePartDto copyWith({
    int? id,
    String? name,
    String? description,
    int? machineTypeId,
    String? machineTypeName,
    int? parentId,
    String? parentName,
    CommonStatus? status,
    List<MachinePartDto>? children,
  }) {
    return MachinePartDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      machineTypeId: machineTypeId ?? this.machineTypeId,
      machineTypeName: machineTypeName ?? this.machineTypeName,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      status: status ?? this.status,
      children: children ?? this.children,
    );
  }
}
