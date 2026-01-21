/// =============================================================================
/// File: warning_event_dto.dart
/// Description: Warning Event Data Transfer Objects
/// 
/// Purpose:
/// - DTOs for warning event API responses
/// - JSON serialization/deserialization
/// =============================================================================

import 'package:json_annotation/json_annotation.dart';

part 'warning_event_dto.g.dart';

@JsonSerializable()
class WarningEventDto {
  final String code;
  final String name;
  final int id;

  const WarningEventDto({
    required this.code,
    required this.name,
    required this.id,
  });

  factory WarningEventDto.fromJson(Map<String, dynamic> json) =>
      _$WarningEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WarningEventDtoToJson(this);
}
