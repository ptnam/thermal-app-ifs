import 'package:dio/dio.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import '../../../core/logger/app_logger.dart';
import 'camera_stream_endpoints.dart';
import 'dto/camera_stream_dto.dart';

/// API service for Camera Stream management
/// Provides methods to fetch camera stream information from the backend
class CameraStreamApiService {
  CameraStreamApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider,
        _logger = logger ?? AppLogger(tag: 'CameraStreamApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  /// Fetch camera stream by camera ID
  /// [cameraId] - ID của camera
  /// [accessToken] - Bearer token for authorization
  /// Returns: Camera stream information with RTSP/HLS/DASH URLs
  Future<ApiResult<CameraStreamDto>> getCameraStream({
    required int cameraId,
    required String accessToken,
  }) async {
    return _apiClient.send<CameraStreamDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.cameraStream(cameraId),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        
        // If data is a String directly (camera name/url)
        if (json is String) {
          
          return CameraStreamDto(
            cameraId: cameraId,
            cameraName: json,
            status: 'online',
            streamUrl: json,
          );
        }

        // Json phải là Map (wrapper hoặc object)
        if (json is! Map) {
          _logger.error('Invalid response: expected Map or String but got ${json.runtimeType}');
          throw FormatException('Invalid response format: ${json.runtimeType}');
        }

        final jsonMap = _castToStringDynamic(json);

        // Check if response is wrapped with data field
        final data = jsonMap['data'];
        
        // If data is a String (camera name/url)
        if (data is String) {
          return CameraStreamDto(
            cameraId: cameraId,
            cameraName: data,
            status: 'online',
            streamUrl: data,
          );
        }

        // If data is a Map, parse as full object
        if (data is Map) {
          
          return CameraStreamDto.fromJson(_castToStringDynamic(data));
        }

        // Or response might be the stream object directly
        if (jsonMap.containsKey('rtspUrl') ||
            jsonMap.containsKey('hlsUrl') ||
            jsonMap.containsKey('streamUrl') ||
            jsonMap.containsKey('cameraId')) {
          
          return CameraStreamDto.fromJson(jsonMap);
        }

        _logger.error('Invalid response format for camera stream $cameraId: no recognized fields');
        throw FormatException('Invalid response format for camera stream $cameraId');
      },
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  CameraStreamEndpoints get _endpoints => CameraStreamEndpoints(_baseUrlProvider.apiBaseUrl);

  Options get _jsonOptions => Options(
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

  Options _authorizedOptions(String accessToken) {
    return _jsonOptions.copyWith(
      headers: {
        ...?_jsonOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  /// Decode Vietnamese characters in error messages
  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll(r'\u1EAD', 'ậ')
        .replaceAll(r'\u1EA9', 'ẩ')
        .replaceAll(r'\u00F4', 'ô')
        .replaceAll(r'\u0111', 'đ')
        .replaceAll(r'\u00FA', 'ú')
        .replaceAll(r'\u0103', 'ă')
        .replaceAll(r'\u1EA7', 'ầ')
        .replaceAll(r'\u1EA5', 'ấ')
        .replaceAll(r'\u1EB9', 'ẹ')
        .replaceAll(r'\u1EC3', 'ể')
        .replaceAll(r'\u1EC1', 'ế')
        .replaceAll(r'\u1EC9', 'ệ')
        .replaceAll(r'\u1EC5', 'ễ')
        .replaceAll(r'\u00E2', 'â')
        .replaceAll(r'\u1EA1', 'ạ')
        .replaceAll(r'\u1EB3', 'ẳ')
        .replaceAll(r'\u1EB1', 'ẳ')
        .replaceAll(r'\u1EBB', 'ỳ')
        .replaceAll(r'\u1EBD', 'ỵ')
        .replaceAll(r'\u1EB5', 'ỵ')
        .replaceAll(r'\u1EB7', 'ỷ')
        .replaceAll(r'\u1EAF', 'ặ')
        .replaceAll(r'\u1EAB', 'ặ')
        .replaceAll(r'\u1EA3', 'ả')
        .replaceAll(r'\u00E0', 'à')
        .replaceAll(r'\u00E1', 'á')
        .replaceAll(r'\u00E3', 'ã')
        .replaceAll(r'\u00E8', 'è')
        .replaceAll(r'\u00E9', 'é')
        .replaceAll(r'\u00EC', 'ì')
        .replaceAll(r'\u00ED', 'í')
        .replaceAll(r'\u00F2', 'ò')
        .replaceAll(r'\u00F3', 'ó')
        .replaceAll(r'\u00F5', 'õ')
        .replaceAll(r'\u00F9', 'ù')
        .replaceAll(r'\u0169', 'ũ')
        .replaceAll(r'\u1EF1', 'ự')
        .replaceAll(r'\u1EF3', 'ỳ')
        .replaceAll(r'\u1EF5', 'ỵ')
        .replaceAll(r'\u1EF7', 'ỷ')
        .replaceAll(r'\u1EF9', 'ỹ');
  }

  /// Helper to cast dynamic to Map<String, dynamic>
  Map<String, dynamic> _castToStringDynamic(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw TypeError();
  }
}
