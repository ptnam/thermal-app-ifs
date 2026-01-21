/// =============================================================================
/// File: role_api_service.dart
/// Description: API service for Role management operations
/// 
/// Purpose:
/// - Handles all HTTP calls related to Role management
/// - CRUD operations for roles
/// - Feature/permission management
/// =============================================================================

import 'package:dio/dio.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import '../../../core/logger/app_logger.dart';
import 'role_endpoints.dart';
import 'dto/role_dto.dart';

/// Service for Role API calls
/// 
/// Provides methods for:
/// - Fetching role lists (all, paginated)
/// - CRUD operations on roles
/// - Feature/permission management
class RoleApiService {
  RoleApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider,
        _logger = logger ?? AppLogger(tag: 'RoleApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  /// Get all roles (shortened list for dropdowns)
  /// 
  /// Returns: List of ShortenBaseDto with minimal role info
  Future<ApiResult<List<ShortenBaseDto>>> getAll({
    required String accessToken,
  }) async {
    _logger.info('Fetching all roles');
    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.all,
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

  /// Get paginated role list with filters
  /// 
  /// [page] - Page number (1-indexed)
  /// [pageSize] - Items per page
  /// [status] - Filter by status (optional)
  Future<ApiResult<PagingResponse<RoleDto>>> getList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    CommonStatus? status,
  }) async {
    _logger.info('Fetching role list: page=$page');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<PagingResponse<RoleDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, RoleDto.fromJson),
    );
  }

  /// Get role by ID
  /// 
  /// [id] - Role ID
  Future<ApiResult<RoleDto>> getById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching role: id=$id');
    return _apiClient.send<RoleDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => RoleDto.fromJson(json),
    );
  }

  /// Create new role
  /// 
  /// [role] - Role data to create
  Future<ApiResult<RoleDto>> create({
    required RoleDto role,
    required String accessToken,
  }) async {
    _logger.info('Creating role: ${role.name}');
    return _apiClient.send<RoleDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _endpoints.create,
        data: role.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => RoleDto.fromJson(json),
    );
  }

  /// Update role by ID
  /// 
  /// [id] - Role ID to update
  /// [role] - Updated role data
  Future<ApiResult<RoleDto>> update({
    required int id,
    required RoleDto role,
    required String accessToken,
  }) async {
    _logger.info('Updating role: id=$id');
    return _apiClient.send<RoleDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _endpoints.update(id),
        data: role.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => RoleDto.fromJson(json),
    );
  }

  /// Delete role by ID
  /// 
  /// [id] - Role ID to delete
  Future<ApiResult<void>> delete({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting role: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _endpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  /// Get all available features/permissions
  /// 
  /// Returns: List of all system features
  Future<ApiResult<List<FeatureDto>>> getAllFeatures({
    required String accessToken,
  }) async {
    _logger.info('Fetching all features');
    return _apiClient.send<List<FeatureDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.allFeatures,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => FeatureDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  RoleEndpoints get _endpoints => RoleEndpoints(_baseUrlProvider.apiBaseUrl);

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
