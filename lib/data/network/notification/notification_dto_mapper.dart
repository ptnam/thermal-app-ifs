

import 'package:thermal_mobile/data/network/notification/dto/notification_detail_response_dto.dart';
import 'package:thermal_mobile/data/network/notification/dto/notification_list_response_dto.dart';
import 'package:thermal_mobile/domain/models/notification.dart';

class NotificationDtoMapper {
  static NotificationListEntity toDomainList(NotificationListResponseDto dto) {
    final items = dto.items
            ?.map((e) => NotificationItemEntity(
                  id: e.id ?? '',
                  formattedDate: e.formattedDate,
                  areaName: e.areaName,
                  machineName: e.machineName,
                  componentValue: e.componentValue,
                  warningEventName: e.warningEventName,
                  dataTime: e.dataTime,
                  imagePath: e.imagePath,
                  dateData: e.dateData,
                  timeData: e.timeData,
                  compareTypeObject: e.compareTypeObject != null
                      ? CompareTypeEntity(
                          id: e.compareTypeObject!.id,
                          code: e.compareTypeObject!.code,
                          name: e.compareTypeObject!.name,
                        )
                      : null,
                  compareResultObject: e.compareResultObject != null
                      ? CompareResultEntity(
                          id: e.compareResultObject!.id,
                          code: e.compareResultObject!.code,
                          name: e.compareResultObject!.name,
                        )
                      : null,
                  statusObject: e.statusObject != null
                      ? StatusEntity(
                          id: e.statusObject!.id,
                          code: e.statusObject!.code,
                          name: e.statusObject!.name,
                        )
                      : null,
                  compareValue: e.compareValue,
                  deltaValue: e.deltaValue,
                  monitorPointCode: e.monitorPointCode,
                  machineComponentName: e.machineComponentName,
                  resolveTime: e.resolveTime,
                  compareComponent: e.compareComponent,
                  compareMonitorPoint: e.compareMonitorPoint,
                  compareDataTime: e.compareDataTime,
                  compareMinTemperature: e.compareMinTemperature,
                  compareMaxTemperature: e.compareMaxTemperature,
                  compareAveTemperature: e.compareAveTemperature,
                ))
            .toList() ??
        [];

    return NotificationListEntity(
      totalRow: dto.totalRow,
      pageSize: dto.pageSize,
      pageIndex: dto.pageIndex,
      items: items,
    );
  }

  static NotificationItemEntity toDomainDetail(NotificationDetailResponseDto dto) {
    return NotificationItemEntity(
      id: dto.id ?? '',
      formattedDate: dto.formattedDate,
      areaName: dto.areaName,
      machineName: dto.machineName,
      componentValue: dto.componentValue,
      warningEventName: dto.warningEventName,
      dataTime: dto.dataTime,
      imagePath: dto.imagePath,
      dateData: dto.dateData,
      timeData: dto.timeData,
      compareTypeObject: dto.compareTypeObject != null
          ? CompareTypeEntity(
              id: dto.compareTypeObject!.id,
              code: dto.compareTypeObject!.code,
              name: dto.compareTypeObject!.name,
            )
          : null,
      compareResultObject: dto.compareResultObject != null
          ? CompareResultEntity(
              id: dto.compareResultObject!.id,
              code: dto.compareResultObject!.code,
              name: dto.compareResultObject!.name,
            )
          : null,
      statusObject: dto.statusObject != null
          ? StatusEntity(
              id: dto.statusObject!.id,
              code: dto.statusObject!.code,
              name: dto.statusObject!.name,
            )
          : null,
      compareValue: dto.compareValue,
      deltaValue: dto.deltaValue,
      monitorPointCode: dto.monitorPointCode,
      machineComponentName: dto.machineComponentName,
      resolveTime: dto.resolveTime,
      compareComponent: dto.compareComponent,
      compareMonitorPoint: dto.compareMonitorPoint,
      compareDataTime: dto.compareDataTime,
      compareMinTemperature: dto.compareMinTemperature,
      compareMaxTemperature: dto.compareMaxTemperature,
      compareAveTemperature: dto.compareAveTemperature,
    );
  }
}
