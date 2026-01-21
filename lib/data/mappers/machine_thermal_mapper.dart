import 'package:thermal_mobile/data/network/thermal_data/dto/machine_result_dto.dart';
import 'package:thermal_mobile/domain/models/machine_thermal_entity.dart';

/// Mapper for MachineResult and ThermalComponent
class MachineThermalMapper {
  static MachineResultEntity toEntity(MachineResultDto dto) {
    return MachineResultEntity(
      key: dto.key,
      machineId: dto.machineId,
      deviceType: dto.deviceType,
      deviceTypeName: dto.deviceTypeName,
      monitorPointIcon: dto.monitorPointIcon,
      longitude: dto.longitude,
      latitude: dto.latitude,
      level: dto.level,
      code: dto.code,
      name: dto.name,
      id: dto.id,
    );
  }

  static ThermalComponentEntity toThermalEntity(ThermalComponentDto dto) {
    return ThermalComponentEntity(
      dateData: dto.dateData,
      timeData: dto.timeData,
      areaName: dto.areaName,
      machineName: dto.machineName,
      temperature: dto.temperature,
      minTemperature: dto.minTemperature,
      maxTemperature: dto.maxTemperature,
      aveTemperature: dto.aveTemperature,
      machineComponentName: dto.machineComponentName,
      monitorPointCode: dto.monitorPointCode,
      orderNumber: dto.orderNumber,
      dataSourceType: dto.dataSourceType,
    );
  }
}
