/// =============================================================================
/// File: machine_entity.dart
/// Description: Machine domain entities
///
/// Purpose:
/// - Pure domain models for machine, machine type, machine part
/// - Used in machine monitoring and management features
/// =============================================================================

/// Common status for entities
enum EntityStatus { active, inactive }

/// Domain entity representing a Machine Type
class MachineTypeEntity {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final EntityStatus status;

  const MachineTypeEntity({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.status = EntityStatus.active,
  });

  bool get isActive => status == EntityStatus.active;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MachineTypeEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Domain entity representing a Machine Part
class MachinePartEntity {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final int? parentId;
  final EntityStatus status;
  final List<MachinePartEntity>? children;

  const MachinePartEntity({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.parentId,
    this.status = EntityStatus.active,
    this.children,
  });

  bool get isActive => status == EntityStatus.active;
  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get isRoot => parentId == null;

  /// Get flattened list of all descendants
  List<MachinePartEntity> get allDescendants {
    final result = <MachinePartEntity>[];
    void traverse(MachinePartEntity part) {
      result.add(part);
      if (part.hasChildren) {
        for (final child in part.children!) {
          traverse(child);
        }
      }
    }

    traverse(this);
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MachinePartEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Domain entity representing a Machine
class MachineEntity {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final int? areaId;
  final String? areaName;
  final int? machineTypeId;
  final String? machineTypeName;
  final MachineTypeEntity? machineType;
  final EntityStatus status;
  final List<MachineComponentEntity>? components;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MachineEntity({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.areaId,
    this.areaName,
    this.machineTypeId,
    this.machineTypeName,
    this.machineType,
    this.status = EntityStatus.active,
    this.components,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == EntityStatus.active;
  bool get hasComponents => components != null && components!.isNotEmpty;

  MachineEntity copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    int? areaId,
    String? areaName,
    int? machineTypeId,
    String? machineTypeName,
    MachineTypeEntity? machineType,
    EntityStatus? status,
    List<MachineComponentEntity>? components,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MachineEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      machineTypeId: machineTypeId ?? this.machineTypeId,
      machineTypeName: machineTypeName ?? this.machineTypeName,
      machineType: machineType ?? this.machineType,
      status: status ?? this.status,
      components: components ?? this.components,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MachineEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MachineEntity(id: $id, name: $name)';
}

/// Domain entity representing a Machine Component
class MachineComponentEntity {
  final int id;
  final String name;
  final int machineId;
  final int? machinePartId;
  final String? machinePartName;
  final EntityStatus status;
  final ThermalSummaryEntity? thermalSummary;

  const MachineComponentEntity({
    required this.id,
    required this.name,
    required this.machineId,
    this.machinePartId,
    this.machinePartName,
    this.status = EntityStatus.active,
    this.thermalSummary,
  });

  bool get isActive => status == EntityStatus.active;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MachineComponentEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Thermal summary for a component
class ThermalSummaryEntity {
  final double? currentTemperature;
  final double? maxTemperature;
  final double? minTemperature;
  final double? avgTemperature;
  final TemperatureLevelEntity? level;
  final DateTime? lastUpdated;

  const ThermalSummaryEntity({
    this.currentTemperature,
    this.maxTemperature,
    this.minTemperature,
    this.avgTemperature,
    this.level,
    this.lastUpdated,
  });
}

/// Temperature level classification
enum TemperatureLevelEntity { normal, warning, danger }

/// Domain entity representing Machine Settings
class MachineSettingEntity {
  final int? userId;
  final int? areaId;
  final List<int>? machineIds;
  final List<int>? machineComponentIds;
  final int? id;

  const MachineSettingEntity({
    this.userId,
    this.areaId,
    this.machineIds,
    this.machineComponentIds,
    this.id,
  });

  MachineSettingEntity copyWith({
    int? userId,
    int? areaId,
    List<int>? machineIds,
    List<int>? machineComponentIds,
    int? id,
  }) {
    return MachineSettingEntity(
      userId: userId ?? this.userId,
      areaId: areaId ?? this.areaId,
      machineIds: machineIds ?? this.machineIds,
      machineComponentIds: machineComponentIds ?? this.machineComponentIds,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MachineSettingEntity &&
        other.userId == userId &&
        other.areaId == areaId &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(userId, areaId, id);

  @override
  String toString() {
    return 'MachineSettingEntity(userId: $userId, areaId: $areaId, '
        'machineIds: $machineIds, machineComponentIds: $machineComponentIds, '
        'id: $id)';
  }
}
