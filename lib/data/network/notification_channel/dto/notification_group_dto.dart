/// =============================================================================
/// File: notification_group_dto.dart
/// Description: Notification Group data transfer object
/// 
/// Purpose:
/// - Maps to backend's NotificationGroupDto model
/// - Used for notification group management
/// =============================================================================

import 'package:thermal_mobile/data/network/api/base_dto.dart';


/// Notification Group DTO
class NotificationGroupDto {
  final int? id;
  final String? name;
  final String? description;
  final CommonStatus status;
  final List<int>? userIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotificationGroupDto({
    this.id,
    this.name,
    this.description,
    this.status = CommonStatus.active,
    this.userIds,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationGroupDto.fromJson(Map<String, dynamic> json) {
    return NotificationGroupDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: CommonStatus.fromValue(json['status'] as int? ?? 1),
      userIds: (json['userIds'] as List<dynamic>?)
          ?.map((e) => e as int)
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
      'status': status.value,
      if (userIds != null) 'userIds': userIds,
    };
  }

  NotificationGroupDto copyWith({
    int? id,
    String? name,
    String? description,
    CommonStatus? status,
    List<int>? userIds,
  }) {
    return NotificationGroupDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      userIds: userIds ?? this.userIds,
    );
  }
}
