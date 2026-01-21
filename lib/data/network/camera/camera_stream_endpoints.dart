/// Camera API endpoints
class CameraStreamEndpoints {
  final String baseUrl;

  CameraStreamEndpoints(this.baseUrl);

  /// Get camera stream URL
  /// [cameraId] - ID của camera
  String cameraStream(int cameraId) => '$baseUrl/api/Cameras/stream/$cameraId';
}
