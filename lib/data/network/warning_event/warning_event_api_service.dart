import 'package:dio/dio.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/api_response.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'warning_event_endpoints.dart';
import 'dto/warning_event_dto.dart';

/// Warning Event API Service
class WarningEventApiService {
  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger = AppLogger(tag: 'WarningEventApiService');

  static final Options _jsonOptions = Options(
    headers: {'Content-Type': 'application/json'},
  );

  WarningEventApiService(
    this._apiClient,
    this._baseUrlProvider,
  );

  WarningEventEndpoints get _endpoints =>
      WarningEventEndpoints(_baseUrlProvider.apiBaseUrl);

  Options _authorizedOptions(String accessToken) {
    return _jsonOptions.copyWith(
      headers: {
        ...?_jsonOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  /// Get all warning events by type
  /// warningType: 1 = Thermal, 2 = AI
  Future<ApiResult<ApiResponse<List<WarningEventDto>>>> getAllWarningEvents({
    required String accessToken,
    required int warningType,
  }) async {
    _logger.info('Fetching warning events: warningType=$warningType');

    return _apiClient.send<ApiResponse<List<WarningEventDto>>>(
      request: (dio) => dio.get(
        _endpoints.all,
        queryParameters: {'warningType': warningType},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is Map<String, dynamic>) {
          return ApiResponse<List<WarningEventDto>>.fromJson(
            json,
            fromJson: (data) {
              if (data is List) {
                return data
                    .map((item) => WarningEventDto.fromJson(
                        item as Map<String, dynamic>))
                    .toList();
              }
              return <WarningEventDto>[];
            },
          );
        }
        throw Exception('Invalid response format');
      },
    );
  }
}
