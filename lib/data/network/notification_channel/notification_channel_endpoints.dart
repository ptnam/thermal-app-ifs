import 'package:thermal_mobile/data/network/api/endpoints.dart';

/// Notification Channel endpoints
class NotificationChannelEndpoints extends Endpoints {
  NotificationChannelEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  String get all => path('/api/NotificationChannels/all');
  String get list => path('/api/NotificationChannels/list');
  String byId(int id) => path('/api/NotificationChannels/$id');
  String get create => path('/api/NotificationChannels');
  String update(int id) => path('/api/NotificationChannels/$id');
  String delete(int id) => path('/api/NotificationChannels/$id');
}

/// Notification Group endpoints
class NotificationGroupEndpoints extends Endpoints {
  NotificationGroupEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  String get all => path('/api/NotificationGroups/all');
  String get list => path('/api/NotificationGroups/list');
  String byId(int id) => path('/api/NotificationGroups/$id');
  String get create => path('/api/NotificationGroups');
  String update(int id) => path('/api/NotificationGroups/$id');
  String delete(int id) => path('/api/NotificationGroups/$id');
}