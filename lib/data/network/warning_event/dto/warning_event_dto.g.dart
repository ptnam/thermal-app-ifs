// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warning_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarningEventDto _$WarningEventDtoFromJson(Map<String, dynamic> json) =>
    WarningEventDto(
      code: json['code'] as String,
      name: json['name'] as String,
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$WarningEventDtoToJson(WarningEventDto instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'id': instance.id,
    };
