import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'vision_notification_endpoints.dart';
import 'dto/vision_notification_dto.dart';

/// Vision Notification API Service
@injectable
class VisionNotificationApiService {
  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger = AppLogger(tag: 'VisionNotificationApi');

  static final Options _jsonOptions = Options(
    headers: {'Content-Type': 'application/json'},
  );

  VisionNotificationApiService(
    this._apiClient,
    this._baseUrlProvider,
  );

  VisionNotificationEndpoints get _endpoints =>
      VisionNotificationEndpoints(_baseUrlProvider.apiBaseUrl);

  /// Get vision notifications list
  /// GET /api/VisionNotifications/list
  Future<VisionNotificationListResponseDto> getVisionNotifications({
    required String accessToken,
    required String fromTime,
    String? toTime,
    int? areaId,
    int? cameraId,
    int? warningEventId,
    int page = 1,
    int pageSize = 50,
  }) async {
    _logger.info(
        'Fetching vision notifications: page=$page, pageSize=$pageSize');

    // Build query parameters
    final queryParams = <String, dynamic>{
      'fromTime': fromTime,
      'page': page,
      'pageSize': pageSize,
    };

    // Add optional parameters
    if (toTime != null) queryParams['toTime'] = toTime;
    if (areaId != null) queryParams['areaId'] = areaId;
    if (cameraId != null) queryParams['cameraId'] = cameraId;
    if (warningEventId != null) queryParams['warningEventId'] = warningEventId;

    final result = await _apiClient.send<VisionNotificationListResponseDto>(
      request: (dio) => dio.get(
        _endpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is Map<String, dynamic>) {
          return VisionNotificationListResponseDto.fromJson(json);
        }
        throw Exception('Invalid response format');
      },
    );

    return result.fold(
      onFailure: (error) {
        _logger.error('Failed to fetch vision notifications: ${error.message}');
        throw Exception(error.message);
      },
      onSuccess: (data) {
        if (data == null) {
          throw Exception('Response data is null');
        }
        _logger.info(
            'Successfully fetched ${data.items?.length ?? 0} vision notifications');
        return data;
      },
    );
  }

  Options _authorizedOptions(String accessToken) {
    return _jsonOptions.copyWith(
      headers: {
        ...?_jsonOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
