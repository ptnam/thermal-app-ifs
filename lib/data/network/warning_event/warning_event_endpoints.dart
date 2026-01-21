import 'package:thermal_mobile/data/network/api/endpoints.dart';

/// Warning Event API endpoints
class WarningEventEndpoints extends Endpoints {
  WarningEventEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all warning events
  /// Query params: warningType (1 = Thermal, 2 = AI)
  String get all => path('/api/WarningEvents/All');
}
