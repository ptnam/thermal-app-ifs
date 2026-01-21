import 'package:thermal_mobile/data/network/api/endpoints.dart';

class CameraEndpoints extends Endpoints {
  CameraEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get all cameras (shortened list or full with monitor points)
  /// Query params: areaId, cameraType, includeMonitorPoints
  String get all => path('/api/Cameras/all');

  /// GET: Get all cameras shortened
  String get allShorten => path('/api/Cameras/allShorten');

  /// GET: Get paginated camera list
  String get list => path('/api/Cameras/list');

  /// GET: Get camera by ID
  String byId(int id) => path('/api/Cameras/$id');

  /// POST: Create new camera
  String get create => path('/api/Cameras');

  /// PUT: Update camera by ID
  String update(int id) => path('/api/Cameras/$id');

  /// DELETE: Delete camera by ID
  String delete(int id) => path('/api/Cameras/$id');
}