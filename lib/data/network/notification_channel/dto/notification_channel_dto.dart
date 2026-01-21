/// =============================================================================
/// File: notification_channel_dto.dart
/// Description: Notification Channel data transfer object
/// 
/// Purpose:
/// - Maps to backend's NotificationChannelDto model
/// - Used for notification channel management
/// =============================================================================

import 'package:thermal_mobile/data/network/api/base_dto.dart';



/// Notification Channel DTO
class NotificationChannelDto {
  final int? id;
  final String? name;
  final String? description;
  final NotificationChannelType? channelType;
  final NotificationChannelStatus channelStatus;
  final CommonStatus status;
  final int? userId;
  final String? userName;
  final String? config;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotificationChannelDto({
    this.id,
    this.name,
    this.description,
    this.channelType,
    this.channelStatus = NotificationChannelStatus.active,
    this.status = CommonStatus.active,
    this.userId,
    this.userName,
    this.config,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationChannelDto.fromJson(Map<String, dynamic> json) {
    return NotificationChannelDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      channelType: json['channelType'] != null
          ? NotificationChannelType.fromValue(json['channelType'] as int)
          : null,
      channelStatus: NotificationChannelStatus.fromValue(
          json['channelStatus'] as int? ?? 1),
      status: CommonStatus.fromValue(json['status'] as int? ?? 1),
      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      config: json['config'] as String?,
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
      if (channelType != null) 'channelType': channelType!.value,
      'channelStatus': channelStatus.value,
      'status': status.value,
      if (userId != null) 'userId': userId,
      if (config != null) 'config': config,
    };
  }

  NotificationChannelDto copyWith({
    int? id,
    String? name,
    String? description,
    NotificationChannelType? channelType,
    NotificationChannelStatus? channelStatus,
    CommonStatus? status,
    int? userId,
    String? userName,
    String? config,
  }) {
    return NotificationChannelDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      channelType: channelType ?? this.channelType,
      channelStatus: channelStatus ?? this.channelStatus,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      config: config ?? this.config,
    );
  }
}
