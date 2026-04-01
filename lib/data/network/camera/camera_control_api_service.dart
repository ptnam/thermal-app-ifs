import 'package:dio/dio.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';

class CameraControlApiService {
  CameraControlApiService(this._dio, this._baseUrlProvider, {AppLogger? logger})
    : _logger = logger ?? AppLogger(tag: 'CameraControlApiService');

  final Dio _dio;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  String get _baseUrl => _baseUrlProvider.apiBaseUrl;

  Future<bool> sendCameraControl({
    required int cameraId,
    required int speed,
    required int command,
    int? preCommand,
    required String accessToken,
  }) async {
    final headers = <String, String>{
      'Accept': '*/*',
      'Content-Type': 'application/json-patch+json',
      'Authorization': 'Bearer $accessToken',
    };

    final payload = <String, dynamic>{
      'cameraId': cameraId,
      'speed': speed,
      'command': command,
      if (preCommand != null) 'preCommand': preCommand,
    };

    _logger.info('PTZ request: $payload');

    final response = await _dio.post(
      '$_baseUrl/api/Cameras/control',
      data: payload,
      options: Options(headers: headers),
    );

    _logger.info('PTZ response status: ${response.statusCode}');

    return response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204;
  }
}
