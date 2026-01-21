/// =============================================================================
/// File: machine_type_dto.dart
/// Description: Machine Type data transfer object
/// 
/// Purpose:
/// - Maps to backend's MachineTypeDto model
/// - Used for machine type management
/// =============================================================================

import 'package:thermal_mobile/data/network/api/base_dto.dart';

/// Machine Type DTO
class MachineTypeDto {
  final int? id;
  final String? name;
  final String? description;
  final CommonStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MachineTypeDto({
    this.id,
    this.name,
    this.description,
    this.status = CommonStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  factory MachineTypeDto.fromJson(Map<String, dynamic> json) {
    return MachineTypeDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: CommonStatus.fromValue(json['status'] as int? ?? 1),
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
    };
  }

  MachineTypeDto copyWith({
    int? id,
    String? name,
    String? description,
    CommonStatus? status,
  }) {
    return MachineTypeDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
