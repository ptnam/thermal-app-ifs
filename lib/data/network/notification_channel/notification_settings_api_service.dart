/// =============================================================================
/// File: notification_settings_api_service.dart
/// Description: API service for Notification Channel and Group management
/// 
/// Purpose:
/// - Handles all HTTP calls for notification channels and groups
/// - CRUD operations for notification settings
/// =============================================================================

import 'package:dio/dio.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/data/network/notification_channel/dto/notification_group_dto.dart';
import 'package:thermal_mobile/data/network/notification_channel/notification_channel_endpoints.dart';
import '../../../core/logger/app_logger.dart';
import 'dto/notification_channel_dto.dart';



/// Service for Notification Channel and Group API calls
class NotificationSettingsApiService {
  NotificationSettingsApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider,
        _logger = logger ?? AppLogger(tag: 'NotificationSettingsApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  // ─────────────────────────────────────────────────────────────────────────
  // Notification Channel Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all notification channels
  Future<ApiResult<List<ShortenBaseDto>>> getAllChannels({
    required String accessToken,
  }) async {
    _logger.info('Fetching all notification channels');
    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _channelEndpoints.all,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => ShortenBaseDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get paginated notification channel list
  Future<ApiResult<PagingResponse<NotificationChannelDto>>> getChannelList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    CommonStatus? status,
    String? name,
    NotificationChannelType? channelType,
    int? userId,
    NotificationChannelStatus? channelStatus,
  }) async {
    _logger.info('Fetching notification channel list: page=$page');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status.value,
      if (name != null && name.isNotEmpty) 'name': name,
      if (channelType != null) 'channelType': channelType.value,
      if (userId != null) 'userId': userId,
      if (channelStatus != null) 'channelStatus': channelStatus.value,
    };

    return _apiClient.send<PagingResponse<NotificationChannelDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _channelEndpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, NotificationChannelDto.fromJson),
    );
  }

  /// Get notification channel by ID
  Future<ApiResult<NotificationChannelDto>> getChannelById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching notification channel: id=$id');
    return _apiClient.send<NotificationChannelDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _channelEndpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => NotificationChannelDto.fromJson(json),
    );
  }

  /// Create notification channel
  Future<ApiResult<NotificationChannelDto>> createChannel({
    required NotificationChannelDto channel,
    required String accessToken,
  }) async {
    _logger.info('Creating notification channel: ${channel.name}');
    return _apiClient.send<NotificationChannelDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _channelEndpoints.create,
        data: channel.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => NotificationChannelDto.fromJson(json),
    );
  }

  /// Update notification channel
  Future<ApiResult<NotificationChannelDto>> updateChannel({
    required int id,
    required NotificationChannelDto channel,
    required String accessToken,
  }) async {
    _logger.info('Updating notification channel: id=$id');
    return _apiClient.send<NotificationChannelDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _channelEndpoints.update(id),
        data: channel.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => NotificationChannelDto.fromJson(json),
    );
  }

  /// Delete notification channel
  Future<ApiResult<void>> deleteChannel({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting notification channel: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _channelEndpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Notification Group Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all notification groups
  Future<ApiResult<List<ShortenBaseDto>>> getAllGroups({
    required String accessToken,
  }) async {
    _logger.info('Fetching all notification groups');
    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _groupEndpoints.all,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => ShortenBaseDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get paginated notification group list
  Future<ApiResult<PagingResponse<NotificationGroupDto>>> getGroupList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    CommonStatus? status,
  }) async {
    _logger.info('Fetching notification group list: page=$page');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<PagingResponse<NotificationGroupDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _groupEndpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, NotificationGroupDto.fromJson),
    );
  }

  /// Get notification group by ID
  Future<ApiResult<NotificationGroupDto>> getGroupById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching notification group: id=$id');
    return _apiClient.send<NotificationGroupDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _groupEndpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => NotificationGroupDto.fromJson(json),
    );
  }

  /// Create notification group
  Future<ApiResult<NotificationGroupDto>> createGroup({
    required NotificationGroupDto group,
    required String accessToken,
  }) async {
    _logger.info('Creating notification group: ${group.name}');
    return _apiClient.send<NotificationGroupDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _groupEndpoints.create,
        data: group.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => NotificationGroupDto.fromJson(json),
    );
  }

  /// Update notification group
  Future<ApiResult<NotificationGroupDto>> updateGroup({
    required int id,
    required NotificationGroupDto group,
    required String accessToken,
  }) async {
    _logger.info('Updating notification group: id=$id');
    return _apiClient.send<NotificationGroupDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _groupEndpoints.update(id),
        data: group.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => NotificationGroupDto.fromJson(json),
    );
  }

  /// Delete notification group
  Future<ApiResult<void>> deleteGroup({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting notification group: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _groupEndpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  NotificationChannelEndpoints get _channelEndpoints =>
      NotificationChannelEndpoints(_baseUrlProvider.apiBaseUrl);
  NotificationGroupEndpoints get _groupEndpoints =>
      NotificationGroupEndpoints(_baseUrlProvider.apiBaseUrl);

  Options _authorizedOptions(String accessToken) {
    return Options(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }
}
