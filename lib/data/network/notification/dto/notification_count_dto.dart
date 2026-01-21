/// =============================================================================
/// File: notification_count_dto.dart
/// Description: DTO for notification count statistics
///
/// Purpose:
/// - Represent notification count data by date
/// =============================================================================

/// DTO for notification count by date
class NotificationCountDto {
  final String? dataDate;
  final int? numberOfNotifications;

  const NotificationCountDto({this.dataDate, this.numberOfNotifications});

  factory NotificationCountDto.fromJson(Map<String, dynamic> json) {
    return NotificationCountDto(
      dataDate: json['dataDate'] as String?,
      numberOfNotifications: json['numberOfNotifications'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataDate': dataDate,
      'numberOfNotifications': numberOfNotifications,
    };
  }
}
