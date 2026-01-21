/// =============================================================================
/// File: camera_api_service.dart
/// Description: API service for Camera management operations
/// 
/// Purpose:
/// - Handles all HTTP calls related to Camera management
/// - CRUD operations for cameras
/// - Camera settings and pinning
/// =============================================================================

import 'package:dio/dio.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'package:thermal_mobile/data/network/api/endpoints.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/data/network/camera/camera_endpoints.dart';
import '../../../core/logger/app_logger.dart';
import 'dto/camera_dto.dart';

/// Camera endpoints


/// Camera Settings endpoints
class CameraSettingsEndpoints extends Endpoints {
  CameraSettingsEndpoints(this.baseUrl);

  @override
  final String baseUrl;

  /// GET: Get camera settings for current user
  String get settings => path('/api/CameraSettings');

  /// GET: Get pinned cameras for current user
  String get pinnedCameras => path('/api/CameraSettings/pinnedCameras');

  /// POST: Save camera settings (pin/unpin)
  String get saveSettings => path('/api/CameraSettings');
}

/// Service for Camera API calls
class CameraApiService {
  CameraApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider,
        _logger = logger ?? AppLogger(tag: 'CameraApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  // ─────────────────────────────────────────────────────────────────────────
  // Camera CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all cameras (full list with optional monitor points)
  Future<ApiResult<List<CameraDto>>> getAll({
    required String accessToken,
    int? areaId,
    CameraType? cameraType,
    bool includeMonitorPoints = false,
  }) async {
    _logger.info('Fetching all cameras: includeMonitorPoints=$includeMonitorPoints');
    
    final queryParams = <String, dynamic>{
      if (areaId != null) 'areaId': areaId,
      if (cameraType != null) 'cameraType': cameraType.value,
      'includeMonitorPoints': includeMonitorPoints,
    };

    return _apiClient.send<List<CameraDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _cameraEndpoints.all,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => CameraDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get all cameras (shortened list for dropdowns)
  Future<ApiResult<List<CameraShortenDto>>> getAllShorten({
    required String accessToken,
    int? areaId,
    CameraType? cameraType,
  }) async {
    _logger.info('Fetching all cameras shortened');
    
    final queryParams = <String, dynamic>{
      if (areaId != null) 'areaId': areaId,
      if (cameraType != null) 'cameraType': cameraType.value,
    };

    return _apiClient.send<List<CameraShortenDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _cameraEndpoints.allShorten,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => CameraShortenDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get paginated camera list
  Future<ApiResult<PagingResponse<CameraDto>>> getList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    int? areaId,
    CameraType? cameraType,
    String? name,
    CommonStatus? status,
  }) async {
    _logger.info('Fetching camera list: page=$page');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (areaId != null) 'areaId': areaId,
      if (cameraType != null) 'cameraType': cameraType.value,
      if (name != null && name.isNotEmpty) 'name': name,
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<PagingResponse<CameraDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _cameraEndpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, CameraDto.fromJson),
    );
  }

  /// Get camera by ID
  Future<ApiResult<CameraDto>> getById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching camera: id=$id');
    return _apiClient.send<CameraDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _cameraEndpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => CameraDto.fromJson(json),
    );
  }

  /// Create new camera
  Future<ApiResult<CameraDto>> create({
    required CameraDto camera,
    required String accessToken,
  }) async {
    _logger.info('Creating camera: ${camera.name}');
    return _apiClient.send<CameraDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _cameraEndpoints.create,
        data: camera.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => CameraDto.fromJson(json),
    );
  }

  /// Update camera by ID
  Future<ApiResult<CameraDto>> update({
    required int id,
    required CameraDto camera,
    required String accessToken,
  }) async {
    _logger.info('Updating camera: id=$id');
    return _apiClient.send<CameraDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _cameraEndpoints.update(id),
        data: camera.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => CameraDto.fromJson(json),
    );
  }

  /// Delete camera by ID
  Future<ApiResult<void>> delete({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting camera: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _cameraEndpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Camera Settings Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get camera settings for current user
  Future<ApiResult<CameraSettingDto>> getSettings({
    required String accessToken,
  }) async {
    _logger.info('Fetching camera settings');
    return _apiClient.send<CameraSettingDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _settingsEndpoints.settings,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => CameraSettingDto.fromJson(json),
    );
  }

  /// Get pinned cameras for current user
  Future<ApiResult<List<CameraShortenDto>>> getPinnedCameras({
    required String accessToken,
  }) async {
    _logger.info('Fetching pinned cameras');
    return _apiClient.send<List<CameraShortenDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _settingsEndpoints.pinnedCameras,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => CameraShortenDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Save camera favourite setting
  Future<ApiResult<CameraSettingDto>> saveFavourite({
    required FavouriteCameraRequest request,
    required String accessToken,
  }) async {
    _logger.info('Saving camera favourite: cameraId=${request.cameraId}');
    return _apiClient.send<CameraSettingDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _settingsEndpoints.saveSettings,
        data: request.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => CameraSettingDto.fromJson(json),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  CameraEndpoints get _cameraEndpoints =>
      CameraEndpoints(_baseUrlProvider.apiBaseUrl);
  CameraSettingsEndpoints get _settingsEndpoints =>
      CameraSettingsEndpoints(_baseUrlProvider.apiBaseUrl);

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
