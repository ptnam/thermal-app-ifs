/// =============================================================================
/// File: machine_setting_dto.dart
/// Description: Machine settings data transfer object
///
/// Purpose:
/// - Maps to backend's Machine Setting model
/// - Contains user's machine, area, and component preferences
/// =============================================================================

/// Machine Setting DTO
/// Maps to backend's machine setting model
class MachineSettingDto {
  final int? userId;
  final int? areaId;
  final List<int>? machineIds;
  final List<int>? machineComponentIds;
  final int? id;

  const MachineSettingDto({
    this.userId,
    this.areaId,
    this.machineIds,
    this.machineComponentIds,
    this.id,
  });

  factory MachineSettingDto.fromJson(Map<String, dynamic> json) {
    return MachineSettingDto(
      userId: json['userId'] as int?,
      areaId: json['areaId'] as int?,
      machineIds: (json['machineIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      machineComponentIds: (json['machineComponentIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      id: json['id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'areaId': areaId,
      'machineIds': machineIds,
      'machineComponentIds': machineComponentIds,
      'id': id,
    };
  }

  MachineSettingDto copyWith({
    int? userId,
    int? areaId,
    List<int>? machineIds,
    List<int>? machineComponentIds,
    int? id,
  }) {
    return MachineSettingDto(
      userId: userId ?? this.userId,
      areaId: areaId ?? this.areaId,
      machineIds: machineIds ?? this.machineIds,
      machineComponentIds: machineComponentIds ?? this.machineComponentIds,
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    return 'MachineSettingDto(userId: $userId, areaId: $areaId, '
        'machineIds: $machineIds, machineComponentIds: $machineComponentIds, '
        'id: $id)';
  }
}
