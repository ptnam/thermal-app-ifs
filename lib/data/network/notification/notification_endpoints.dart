import 'package:thermal_mobile/data/network/api/endpoints.dart';

/// =============================================================================
/// File: notification_endpoints.dart
/// Description: Notification API endpoints configuration
///
/// Purpose:
/// - Define all notification-related API endpoints
/// - Support notification listing, read status, count operations
/// =============================================================================


/// Notification API endpoints
class NotificationEndpoints extends Endpoints {
  NotificationEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get paginated notification list
  /// Query params: page, pageSize, status (read/unread), machineId, areaId
  String get list => path('/api/Notifications/list');

  /// GET: Get notification by ID
  String byId(String id) => path('/api/Notifications/$id');

  /// GET: Get notification by ID and dataTime
  /// Query params: id (Guid), dataTime
  String get getOne => path('/api/Notifications');

  /// GET: Get latest notifications
  /// Query params: numberOfRecord
  String get latest => path('/api/Notifications/lastest');

  /// GET: Get notification brief (latest notifications summary)
  /// Query params: numberOfRecord
  String get lastestBrief => path('/api/Notifications/lastestBrief');

  /// PUT: Update notification status (read/unread)
  /// Path param: id (Guid)
  String updateStatus(String id) => path('/api/Notifications/$id');

  /// PUT: Mark all notifications as read
  String get markAllRead => path('/api/Notifications/markAllRead');

  /// DELETE: Delete notification
  String delete(String id) => path('/api/Notifications/$id');

  /// GET: Get notification count by date range
  /// Query params: startDate, endDate
  String get count => path('/api/Notifications/count');
}
