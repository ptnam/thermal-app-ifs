/// =============================================================================
/// File: user_api_service.dart
/// Description: API service for User management operations
/// 
/// Purpose:
/// - Handles all HTTP calls related to User management
/// - CRUD operations for users
/// - User profile and password management
/// =============================================================================

import 'package:dio/dio.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import '../../../core/logger/app_logger.dart';
import 'user_endpoints.dart';
import 'dto/user_dto.dart';

/// Service for User API calls
/// 
/// Provides methods for:
/// - Fetching user lists (all, paginated)
/// - CRUD operations on users
/// - Profile management
/// - Password change
class UserApiService {
  UserApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider,
        _logger = logger ?? AppLogger(tag: 'UserApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  /// Get all users (shortened list for dropdowns)
  /// 
  /// Returns: List of BaseUserDto with minimal user info
  Future<ApiResult<List<BaseUserDto>>> getAll({
    required String accessToken,
  }) async {
    _logger.info('Fetching all users');
    return _apiClient.send<List<BaseUserDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.all,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => BaseUserDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get paginated user list with filters
  /// 
  /// [page] - Page number (1-indexed)
  /// [pageSize] - Items per page
  /// [roleId] - Filter by role (optional)
  /// [userStatus] - Filter by status (optional)
  /// [name] - Filter by name (optional)
  /// [email] - Filter by email (optional)
  Future<ApiResult<PagingResponse<UserDto>>> getList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    int? roleId,
    UserStatus? userStatus,
    String? name,
    String? email,
  }) async {
    _logger.info('Fetching user list: page=$page');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (roleId != null) 'roleId': roleId,
      if (userStatus != null) 'userStatus': userStatus.value,
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    return _apiClient.send<PagingResponse<UserDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, UserDto.fromJson),
    );
  }

  /// Get user by ID
  /// 
  /// [id] - User ID
  Future<ApiResult<UserDto>> getById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching user: id=$id');
    return _apiClient.send<UserDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => UserDto.fromJson(json),
    );
  }

  /// Get current user profile
  Future<ApiResult<UserDto>> getMyProfile({
    required String accessToken,
  }) async {
    _logger.info('Fetching current user profile');
    return _apiClient.send<UserDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.myProfile,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => UserDto.fromJson(json),
    );
  }

  /// Create new user
  /// 
  /// [user] - User data to create
  Future<ApiResult<UserDto>> create({
    required UserDto user,
    required String accessToken,
  }) async {
    _logger.info('Creating user: ${user.userName}');
    return _apiClient.send<UserDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _endpoints.create,
        data: user.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => UserDto.fromJson(json),
    );
  }

  /// Update user by ID
  /// 
  /// [id] - User ID to update
  /// [user] - Updated user data
  Future<ApiResult<UserDto>> update({
    required int id,
    required UserDto user,
    required String accessToken,
  }) async {
    _logger.info('Updating user: id=$id');
    return _apiClient.send<UserDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _endpoints.update(id),
        data: user.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => UserDto.fromJson(json),
    );
  }

  /// Delete user by ID
  /// 
  /// [id] - User ID to delete
  Future<ApiResult<void>> delete({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting user: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _endpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  /// Change password for current user
  /// 
  /// [request] - Change password request with old and new password
  Future<ApiResult<void>> changePassword({
    required ChangePasswordRequestDto request,
    required String accessToken,
  }) async {
    _logger.info('Changing password');
    return _apiClient.send<void>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _endpoints.changePassword,
        data: request.toJson(),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  UserEndpoints get _endpoints => UserEndpoints(_baseUrlProvider.apiBaseUrl);

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
