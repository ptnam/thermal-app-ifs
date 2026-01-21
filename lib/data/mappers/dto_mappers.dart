/// =============================================================================
/// File: dto_mappers.dart
/// Description: Mappers to convert between DTOs and Domain Entities
///
/// Purpose:
/// - Provide clean separation between data and domain layers
/// - Handle all type conversions in one place
/// =============================================================================

import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/domain/models/area_entity.dart';
import 'package:thermal_mobile/domain/models/camera_entity.dart';
import 'package:thermal_mobile/domain/models/machine_entity.dart';
import 'package:thermal_mobile/domain/models/notification_entity.dart';
import 'package:thermal_mobile/domain/models/role_entity.dart';
import 'package:thermal_mobile/domain/models/thermal_data_entity.dart';
import 'package:thermal_mobile/domain/models/user_entity.dart';

import '../network/user/dto/user_dto.dart';
import '../network/role/dto/role_dto.dart';
import '../network/machine/dto/machine_dto.dart';
import '../network/machine/dto/machine_type_dto.dart';
import '../network/machine/dto/machine_part_dto.dart';
import '../network/machine/dto/machine_setting_dto.dart';
import '../network/camera/dto/camera_dto.dart';
import '../network/area/dto/area_dto.dart';
import '../network/notification/dto/notification_dto.dart';
import '../network/thermal_data/dto/thermal_data_dto.dart';

// ─────────────────────────────────────────────────────────────────────────────
// User Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension UserDtoMapper on UserDto {
  UserEntity toEntity() {
    return UserEntity(
      id: id ?? 0,
      userName: userName ?? '',
      email: email ?? '',
      fullName: fullName,
      phoneNumber: phone, // UserDto uses 'phone' field
      avatarUrl: avatar, // UserDto uses 'avatar' field
      roleId: roleId,
      roleName: roleName,
      status: _mapUserStatus(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static UserStatusEntity _mapUserStatus(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return UserStatusEntity.active;
      case UserStatus.inactive:
        return UserStatusEntity.inactive;
      case UserStatus.deleted:
        return UserStatusEntity.banned; // Map deleted to banned
    }
  }
}

extension UserEntityMapper on UserEntity {
  UserDto toDto() {
    return UserDto(
      id: id,
      userName: userName,
      email: email,
      fullName: fullName,
      phone: phoneNumber, // UserDto uses 'phone' field
      avatar: avatarUrl, // UserDto uses 'avatar' field
      roleId: roleId,
      status: _mapUserStatus(status),
    );
  }

  static UserStatus _mapUserStatus(UserStatusEntity status) {
    switch (status) {
      case UserStatusEntity.active:
        return UserStatus.active;
      case UserStatusEntity.inactive:
        return UserStatus.inactive;
      case UserStatusEntity.banned:
        return UserStatus.deleted; // Map banned to deleted
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension RoleDtoMapper on RoleDto {
  /// Convert RoleDto to RoleEntity
  /// Note: RoleDto has featureIds (List<int>), not features list
  RoleEntity toEntity() {
    return RoleEntity(
      id: id ?? 0,
      name: name ?? '',
      description: description,
      // features: null - RoleDto doesn't have features, only featureIds
      isActive: status == CommonStatus.active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension RoleEntityMapper on RoleEntity {
  RoleDto toDto() {
    return RoleDto(
      id: id,
      name: name,
      description: description,
      status: isActive ? CommonStatus.active : CommonStatus.inactive,
      // featureIds would need to be extracted from features if available
      featureIds: features?.map((f) => f.id).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Machine Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension MachineDtoMapper on MachineDto {
  MachineEntity toEntity() {
    return MachineEntity(
      id: id ?? 0,
      name: name ?? '',
      code: code,
      description: description,
      areaId: areaId,
      areaName: areaName,
      machineTypeId: machineTypeId,
      machineTypeName: machineTypeName,
      status: status == CommonStatus.active
          ? EntityStatus.active
          : EntityStatus.inactive,
      // Note: MachineDto doesn't have components field, it's loaded separately
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension MachineEntityMapper on MachineEntity {
  MachineDto toDto() {
    return MachineDto(
      id: id,
      name: name,
      code: code,
      description: description,
      areaId: areaId,
      machineTypeId: machineTypeId,
      status: status == EntityStatus.active
          ? CommonStatus.active
          : CommonStatus.inactive,
    );
  }
}

extension MachineTypeDtoMapper on MachineTypeDto {
  MachineTypeEntity toEntity() {
    return MachineTypeEntity(
      id: id ?? 0,
      name: name ?? '',
      // Note: MachineTypeDto doesn't have 'code' field
      description: description,
      status: status == CommonStatus.active
          ? EntityStatus.active
          : EntityStatus.inactive,
    );
  }
}

extension MachineTypeEntityMapper on MachineTypeEntity {
  MachineTypeDto toDto() {
    return MachineTypeDto(
      id: id,
      name: name,
      description: description,
      status: status == EntityStatus.active
          ? CommonStatus.active
          : CommonStatus.inactive,
    );
  }
}

extension MachinePartDtoMapper on MachinePartDto {
  MachinePartEntity toEntity() {
    return MachinePartEntity(
      id: id ?? 0,
      name: name ?? '',
      // Note: MachinePartDto doesn't have 'code' field
      description: description,
      parentId: parentId,
      status: status == CommonStatus.active
          ? EntityStatus.active
          : EntityStatus.inactive,
      children: children?.map((c) => c.toEntity()).toList(),
    );
  }
}

extension MachinePartEntityMapper on MachinePartEntity {
  MachinePartDto toDto() {
    return MachinePartDto(
      id: id,
      name: name,
      description: description,
      parentId: parentId,
      status: status == EntityStatus.active
          ? CommonStatus.active
          : CommonStatus.inactive,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sensor Mappers
// ─────────────────────────────────────────────────────────────────────────────

// extension SensorDtoMapper on SensorDto {
//   SensorEntity toEntity() {
//     return SensorEntity(
//       id: id ?? 0,
//       name: name ?? '',
//       code: code,
//       description: description,
//       areaId: areaId,
//       areaName: areaName,
//       sensorTypeId: sensorTypeId,
//       sensorTypeName: sensorTypeName,
//       ipAddress: ipAddress,
//       port: port,
//       status: status == CommonStatus.active
//           ? EntityStatus.active
//           : EntityStatus.inactive,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//     );
//   }
// }

// extension SensorEntityMapper on SensorEntity {
//   SensorDto toDto() {
//     return SensorDto(
//       id: id,
//       name: name,
//       code: code,
//       description: description,
//       areaId: areaId,
//       sensorTypeId: sensorTypeId,
//       ipAddress: ipAddress,
//       port: port,
//       status: status == EntityStatus.active
//           ? CommonStatus.active
//           : CommonStatus.inactive,
//     );
//   }
// }

// extension SensorTypeDtoMapper on SensorTypeDto {
//   SensorTypeEntity toEntity() {
//     return SensorTypeEntity(
//       id: id ?? 0,
//       name: name ?? '',
//       // Note: SensorTypeDto doesn't have 'code' or 'manufacturer' fields
//       description: description,
//       status: status == CommonStatus.active
//           ? EntityStatus.active
//           : EntityStatus.inactive,
//     );
//   }
// }

// extension SensorTypeEntityMapper on SensorTypeEntity {
//   SensorTypeDto toDto() {
//     return SensorTypeDto(
//       id: id,
//       name: name,
//       description: description,
//       status: status == EntityStatus.active
//           ? CommonStatus.active
//           : CommonStatus.inactive,
//     );
//   }
// }

// ─────────────────────────────────────────────────────────────────────────────
// Camera Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension CameraDtoMapper on CameraDto {
  CameraEntity toEntity() {
    return CameraEntity(
      id: id ?? 0,
      name: name ?? '',
      code: code,
      description: description,
      areaId: areaId,
      areaName: areaName,
      cameraType: _mapCameraType(cameraType),
      status: status == CommonStatus.active
          ? EntityStatus.active
          : EntityStatus.inactive,
      ipAddress: ipAddress,
      port: port,
      username: username,
      password: password,
      streamUrl: streamUrl,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static CameraTypeEntity? _mapCameraType(CameraType? type) {
    if (type == null) return null;
    switch (type) {
      case CameraType.thermal:
        return CameraTypeEntity.thermal;
      case CameraType.vision:
        return CameraTypeEntity.optical; // Map vision to optical
      // Note: CameraType enum only has thermal and vision
    }
  }
}

extension CameraEntityMapper on CameraEntity {
  CameraDto toDto() {
    return CameraDto(
      id: id,
      name: name,
      code: code,
      description: description,
      areaId: areaId,
      cameraType: _mapCameraType(cameraType),
      status: status == EntityStatus.active
          ? CommonStatus.active
          : CommonStatus.inactive,
      ipAddress: ipAddress,
      port: port,
      username: username,
      password: password,
      streamUrl: streamUrl,
      thumbnailUrl: thumbnailUrl,
    );
  }

  static CameraType? _mapCameraType(CameraTypeEntity? type) {
    if (type == null) return null;
    switch (type) {
      case CameraTypeEntity.thermal:
        return CameraType.thermal;
      case CameraTypeEntity.optical:
        return CameraType.vision;
      case CameraTypeEntity.hybrid:
        return CameraType.vision; // Map hybrid to vision (no hybrid in DTO)
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Area Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension AreaDtoMapper on AreaDto {
  AreaEntity toEntity() {
    return AreaEntity(
      id: id ?? 0,
      name: name ?? '',
      code: code,
      description: description,
      parentId: parentId,
      parentName: parentName,
      level: level,
      status: status == CommonStatus.active
          ? EntityStatus.active
          : EntityStatus.inactive,
      children: children?.map((c) => c.toEntity()).toList(),
      cameras: cameras
          ?.map(
            (c) => CameraEntity(
              id: c.id,
              name: c.name ?? '',
              code: c.code,
              streamUrl: c.streamUrl,
              thumbnailUrl: c.thumbnailUrl,
            ),
          )
          .toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension AreaEntityMapper on AreaEntity {
  AreaDto toDto() {
    return AreaDto(
      id: id,
      name: name,
      code: code,
      description: description,
      parentId: parentId,
      status: status == EntityStatus.active
          ? CommonStatus.active
          : CommonStatus.inactive,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension NotificationDtoMapper on NotificationExtendDto {
  NotificationEntity toEntity() {
    // Parse String id to int - use hashCode as fallback
    int parsedId = 0;
    if (id != null) {
      parsedId = int.tryParse(id!) ?? id.hashCode;
    }

    return NotificationEntity(
      id: parsedId,
      title: warningEventName ?? machineComponentName ?? 'Thông báo',
      content: '$areaName - $machineName',
      machineName: machineName,
      machineComponentName: machineComponentName,
      warningType: WarningTypeEntity.temperature,
      status: _mapNotificationStatus(status),
      temperature: componentValue,
      createdAt: dataTime,
    );
  }

  static NotificationStatusEntity _mapNotificationStatus(
    NotificationStatus status,
  ) {
    switch (status) {
      case NotificationStatus.pending:
        return NotificationStatusEntity.unread;
      case NotificationStatus.processed:
        return NotificationStatusEntity.read;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Thermal Data Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension ThermalDataDtoMapper on ThermalDataDetailExtend {
  ThermalDataEntity toEntity() {
    // Parse String id to int - use hashCode as fallback
    int parsedId = 0;
    if (id != null) {
      parsedId = int.tryParse(id!) ?? id.hashCode;
    }

    return ThermalDataEntity(
      id: parsedId,
      machineComponentId: machineComponentId,
      machineComponentName: machineComponentName,
      machineId: machineId,
      machineName: machineName,
      maxTemperature: temperature, // Use temperature as max
      minTemperature: null, // Not available in ThermalDataDetailExtend
      avgTemperature: temperature, // Use temperature as avg
      level: _mapTemperatureLevel(temperatureLevel),
      dataTime: dataTime ?? DateTime.now(),
      // ThermalDataDetailExtend doesn't have 'createdAt'
    );
  }

  static TemperatureLevelEntity _mapTemperatureLevel(TemperatureLevel? level) {
    if (level == null) return TemperatureLevelEntity.normal;
    switch (level) {
      case TemperatureLevel.normal:
        return TemperatureLevelEntity.normal;
      case TemperatureLevel.warning:
        return TemperatureLevelEntity.warning;
      case TemperatureLevel.critical:
        return TemperatureLevelEntity.danger; // Map critical to danger
    }
  }
}

extension ChartOutputMapper on ChartOutput {
  ThermalChartEntity toEntity({String? name, int? machineComponentId}) {
    return ThermalChartEntity(
      name: name, // Passed in from caller since ChartOutput doesn't have it
      machineComponentId: machineComponentId, // Passed in from caller
      dataPoints: dataPoints?.map((p) => p.toEntity()).toList() ?? [],
    );
  }
}

extension ChartDataPointMapper on ChartDataPoint {
  ChartDataPointEntity toEntity() {
    return ChartDataPointEntity(
      time: time ?? DateTime.now(),
      value: value,
      label: label,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension FeatureDtoMapper on FeatureDto {
  /// Convert FeatureDto to FeatureEntity
  FeatureEntity toEntity() {
    return FeatureEntity(
      id: id,
      code: code ?? '',
      name: name,
      description: description,
      // FeatureDto doesn't have parentId or children
      parentId: null,
      children: null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Machine Component with Thermal Datas Mapper
// ─────────────────────────────────────────────────────────────────────────────

extension MachineComponentAndThermalDatasMapper
    on MachineComponentAndThermalDatas {
  /// Convert MachineComponentAndThermalDatas to ThermalDashboardEntity
  /// This aggregates thermal data from multiple components
  ThermalDashboardEntity toEntity() {
    // Calculate counts from thermal data
    int normalCount = 0;
    int warningCount = 0;
    int dangerCount = 0;
    final List<ThermalDataEntity> recentReadings = [];

    if (thermalDatas != null) {
      for (final entry in thermalDatas!.entries) {
        for (final data in entry.value) {
          switch (data.temperatureLevel) {
            case TemperatureLevel.normal:
              normalCount++;
              break;
            case TemperatureLevel.warning:
              warningCount++;
              break;
            case TemperatureLevel.critical:
              dangerCount++;
              break;
            case null:
              normalCount++;
              break;
          }
          // Add to recent readings (first item per component)
          if (recentReadings.length < 10) {
            recentReadings.add(data.toEntity());
          }
        }
      }
    }

    return ThermalDashboardEntity(
      totalMachines: components?.length ?? 0,
      normalCount: normalCount,
      warningCount: warningCount,
      dangerCount: dangerCount,
      recentReadings: recentReadings,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Machine Settings Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension MachineSettingDtoMapper on MachineSettingDto {
  MachineSettingEntity toEntity() {
    return MachineSettingEntity(
      userId: userId,
      areaId: areaId,
      machineIds: machineIds,
      machineComponentIds: machineComponentIds,
      id: id,
    );
  }
}

extension MachineSettingEntityMapper on MachineSettingEntity {
  MachineSettingDto toDto() {
    return MachineSettingDto(
      userId: userId,
      areaId: areaId,
      machineIds: machineIds,
      machineComponentIds: machineComponentIds,
      id: id,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Environment Thermal Data Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension EnvironmentThermalDataMapper on EnvironmentThermalData {
  EnvironmentThermalEntity toEntity() {
    return EnvironmentThermalEntity(
      temperature: temperature,
      frequency: frequency,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Multi Thermal Data Mappers
// ─────────────────────────────────────────────────────────────────────────────

extension ThermalChartSeriesMapper on ThermalChartSeries {
  ThermalChartSeriesEntity toEntity() {
    return ThermalChartSeriesEntity(name: name, data: data);
  }
}

extension ThermalDataMultiResponseMapper on ThermalDataMultiResponse {
  ThermalDataMultiEntity toEntity() {
    return ThermalDataMultiEntity(
      categories: categories,
      chartData: chartData.map((series) => series.toEntity()).toList(),
    );
  }
}
