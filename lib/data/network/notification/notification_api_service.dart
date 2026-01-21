import 'package:dio/dio.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import '../../../core/logger/app_logger.dart';
import 'notification_endpoints.dart';
import 'dto/notification_count_dto.dart';
import 'dto/notification_dto.dart';

/// API service for Notifications
class NotificationApiService {
  NotificationApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  }) : _apiClient = apiClient,
       _baseUrlProvider = baseUrlProvider,
       _logger = logger ?? AppLogger(tag: 'NotificationApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  NotificationEndpoints get _endpoints =>
      NotificationEndpoints(_baseUrlProvider.apiBaseUrl);

  // ─────────────────────────────────────────────────────────────────────────
  // Additional Notification Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get paginated notification list with typed response
  /// Backend params: fromTime, areaId, machineId, notificationStatus, page, pageSize
  /// Note: toTime is optional - web frontend doesn't send it
  Future<ApiResult<PagingResponse<NotificationExtendDto>>> getNotificationList({
    required String accessToken,
    required DateTime fromTime,
    int page = 1,
    int pageSize = 10,
    NotificationStatus? notificationStatus,
    int? machineId,
    int? areaId,
  }) async {
    _logger.info('Fetching notification list: page=$page');

    // Format DateTime for C# backend: yyyy-MM-dd HH:mm:ss
    String formatDateTime(DateTime dt) {
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    }

    final queryParams = <String, dynamic>{
      'fromTime': formatDateTime(fromTime),
      'page': page,
      'pageSize': pageSize,
      if (notificationStatus != null)
        'notificationStatus': notificationStatus.value,
      if (machineId != null) 'machineId': machineId,
      if (areaId != null) 'areaId': areaId,
    };

    _logger.info('Query params: $queryParams');
    _logger.info('Endpoint: ${_endpoints.list}');

    return _apiClient.send<PagingResponse<NotificationExtendDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        _logger.info('Raw API response: $json');
        return PagingResponse.fromJson(
          _castToStringDynamic(json),
          NotificationExtendDto.fromJson,
        );
      },
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Get notification by ID and dataTime
  Future<ApiResult<NotificationExtendDto>> getNotificationById({
    required String id,
    required DateTime dataTime,
    required String accessToken,
  }) async {
    _logger.info('Fetching notification: id=$id');
    return _apiClient.send<NotificationExtendDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.getOne,
        queryParameters: {'id': id, 'dataTime': dataTime.toIso8601String()},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) =>
          NotificationExtendDto.fromJson(_castToStringDynamic(json)),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Get latest notifications
  Future<ApiResult<List<NotificationExtendDto>>> getLatestNotifications({
    required String accessToken,
    int numberOfRecord = 10,
  }) async {
    _logger.info('Fetching latest notifications: count=$numberOfRecord');
    return _apiClient.send<List<NotificationExtendDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.latest,
        queryParameters: {'numberOfRecord': numberOfRecord},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json
              .map(
                (e) => NotificationExtendDto.fromJson(_castToStringDynamic(e)),
              )
              .toList();
        }
        return [];
      },
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Get notification brief (latest brief summary for header)
  Future<ApiResult<NotificationBriefTotal>> getNotificationBrief({
    required String accessToken,
    int numberOfRecord = 5,
  }) async {
    _logger.info('Fetching notification brief');
    return _apiClient.send<NotificationBriefTotal>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.lastestBrief,
        queryParameters: {'numberOfRecord': numberOfRecord},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) =>
          NotificationBriefTotal.fromJson(_castToStringDynamic(json)),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Update notification status (read/unread)
  Future<ApiResult<void>> updateNotificationStatus({
    required String id,
    required UpdateNotificationStatusRequest request,
    required String accessToken,
  }) async {
    _logger.info(
      'Updating notification status: id=$id, status=${request.status}',
    );
    return _apiClient.send<void>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _endpoints.updateStatus(id),
        data: request.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Mark all notifications as read
  Future<ApiResult<void>> markAllNotificationsRead({
    required String accessToken,
  }) async {
    _logger.info('Marking all notifications as read');
    return _apiClient.send<void>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _endpoints.markAllRead,
        options: _authorizedOptions(accessToken),
      ),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Delete notification by ID
  Future<ApiResult<void>> deleteNotification({
    required String id,
    required String accessToken,
  }) async {
    _logger.info('Deleting notification: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _endpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

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

  /// Fetch notification list
  /// [queryParameters] - query params for paging/filtering
  /// [accessToken] - bearer token
  Future<ApiResult<Map<String, dynamic>>> getNotifications({
    required Map<String, dynamic> queryParameters,
    required String accessToken,
  }) async {
    return _apiClient.send<Map<String, dynamic>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.list,
        queryParameters: queryParameters,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is Map) {
          return _castToStringDynamic(json);
        }
        _logger.error(
          'Invalid notifications response format: ${json.runtimeType}',
        );
        throw FormatException('Invalid response format: ${json.runtimeType}');
      },
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Fetch notification detail by id and dataTime
  Future<ApiResult<Map<String, dynamic>>> getNotificationDetail({
    required String id,
    required String dataTime,
    required String accessToken,
  }) async {
    return _apiClient.send<Map<String, dynamic>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.getOne,
        queryParameters: {'id': id, 'dataTime': dataTime},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is Map) {
          return _castToStringDynamic(json);
        }
        _logger.error(
          'Invalid notification detail format: ${json.runtimeType}',
        );
        throw FormatException('Invalid response format: ${json.runtimeType}');
      },
      errorMessageTransformer: _decodeHtmlEntities,
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

  /// Get notification count by date range
  /// Returns list of daily notification counts
  Future<ApiResult<List<NotificationCountDto>>> getNotificationCount({
    required String accessToken,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _logger.info(
      'Fetching notification count: startDate=$startDate, endDate=$endDate',
    );

    // Format dates as yyyy-MM-dd
    String formatDate(DateTime dt) {
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }

    final queryParams = <String, dynamic>{
      'startDate': formatDate(startDate),
      'endDate': formatDate(endDate),
    };

    return _apiClient.send<List<NotificationCountDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.count,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => NotificationCountDto.fromJson(e)).toList();
        }
        return [];
      },
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }
}
