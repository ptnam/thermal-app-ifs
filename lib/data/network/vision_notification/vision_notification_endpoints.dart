import 'package:thermal_mobile/data/network/api/base_url_provider.dart';

/// Vision Notification API Endpoints
class VisionNotificationEndpoints {
  final String baseUrl;

  VisionNotificationEndpoints(this.baseUrl);

  /// GET /api/VisionNotifications/list
  String get list => '$baseUrl/api/VisionNotifications/list';
}
