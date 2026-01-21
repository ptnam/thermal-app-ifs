/// =============================================================================
/// File: machine_api_service.dart
/// Description: API service for Machine management operations
///
/// Purpose:
/// - Handles all HTTP calls related to Machine management
/// - CRUD operations for machines
/// - Machine component queries
/// =============================================================================

import 'package:dio/dio.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import '../../../core/logger/app_logger.dart';
import 'machine_endpoints.dart';
import 'dto/machine_dto.dart';
import 'dto/machine_type_dto.dart';
import 'dto/machine_part_dto.dart';
import 'dto/machine_setting_dto.dart';

/// Service for Machine API calls
///
/// Provides methods for:
/// - Fetching machine lists (all, paginated)
/// - CRUD operations on machines
/// - Machine component queries
/// - Machine thermal data
class MachineApiService {
  MachineApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  }) : _apiClient = apiClient,
       _baseUrlProvider = baseUrlProvider,
       _logger = logger ?? AppLogger(tag: 'MachineApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  // ─────────────────────────────────────────────────────────────────────────
  // Machine CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all machines (shortened list)
  ///
  /// [areaId] - Filter by area (optional)
  /// [machineTypeId] - Filter by machine type (optional)
  Future<ApiResult<List<ShortenBaseDto>>> getAll({
    required String accessToken,
    int? areaId,
    int? machineTypeId,
  }) async {
    _logger.info('Fetching all machines');

    final queryParams = <String, dynamic>{
      if (areaId != null) 'areaId': areaId,
      if (machineTypeId != null) 'machineTypeId': machineTypeId,
    };

    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineEndpoints.all,
        queryParameters: queryParams,
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

  /// Get paginated machine list
  Future<ApiResult<PagingResponse<MachineDto>>> getList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    int? areaId,
    int? machineTypeId,
    String? name,
    CommonStatus? status,
  }) async {
    _logger.info('Fetching machine list: page=$page');

    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (areaId != null) 'areaId': areaId,
      if (machineTypeId != null) 'machineTypeId': machineTypeId,
      if (name != null && name.isNotEmpty) 'name': name,
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<PagingResponse<MachineDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineEndpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, MachineDto.fromJson),
    );
  }

  /// Get machine by ID
  Future<ApiResult<MachineDto>> getById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching machine: id=$id');
    return _apiClient.send<MachineDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineEndpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachineDto.fromJson(json),
    );
  }

  /// Create new machine
  Future<ApiResult<MachineDto>> create({
    required MachineDto machine,
    required String accessToken,
  }) async {
    _logger.info('Creating machine: ${machine.name}');
    return _apiClient.send<MachineDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _machineEndpoints.create,
        data: machine.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachineDto.fromJson(json),
    );
  }

  /// Update machine by ID
  Future<ApiResult<MachineDto>> update({
    required int id,
    required MachineDto machine,
    required String accessToken,
  }) async {
    _logger.info('Updating machine: id=$id');
    return _apiClient.send<MachineDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _machineEndpoints.update(id),
        data: machine.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachineDto.fromJson(json),
    );
  }

  /// Delete machine by ID
  Future<ApiResult<void>> delete({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting machine: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _machineEndpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Component Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get machines by area with component info
  Future<ApiResult<List<MachineComponentInfo>>> getMachinesByArea({
    required int areaId,
    required String accessToken,
  }) async {
    _logger.info('Fetching machines by area: areaId=$areaId');
    return _apiClient.send<List<MachineComponentInfo>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineEndpoints.machinesByArea,
        queryParameters: {'areaId': areaId},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => MachineComponentInfo.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get machine components
  Future<ApiResult<List<ShortenBaseDto>>> getComponents({
    required int machineId,
    required String accessToken,
    bool hasMonitorPoints = true,
  }) async {
    _logger.info('Fetching machine components: machineId=$machineId');
    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineEndpoints.components,
        queryParameters: {
          'machineId': machineId,
          'hasMonitorPoints': hasMonitorPoints,
        },
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

  /// Get multiple machine components
  Future<ApiResult<List<ShortenBaseDto>>> getMultiComponents({
    required List<int> machineIds,
    required String accessToken,
    bool hasMonitorPoints = true,
  }) async {
    _logger.info(
      'Fetching multi machine components: ${machineIds.length} machines',
    );
    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineEndpoints.multiComponents,
        queryParameters: {
          'machineIds[]': machineIds,
          'hasMonitorPoints': hasMonitorPoints,
        },
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

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Type Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all machine types (shortened list)
  Future<ApiResult<List<ShortenBaseDto>>> getAllTypes({
    required String accessToken,
  }) async {
    _logger.info('Fetching all machine types');
    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineTypeEndpoints.all,
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

  /// Get paginated machine type list
  Future<ApiResult<PagingResponse<MachineTypeDto>>> getTypeList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    String? name,
    CommonStatus? status,
  }) async {
    _logger.info('Fetching machine type list: page=$page');

    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (name != null && name.isNotEmpty) 'name': name,
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<PagingResponse<MachineTypeDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineTypeEndpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(json, MachineTypeDto.fromJson),
    );
  }

  /// Get machine type by ID
  Future<ApiResult<MachineTypeDto>> getTypeById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching machine type: id=$id');
    return _apiClient.send<MachineTypeDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineTypeEndpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachineTypeDto.fromJson(json),
    );
  }

  /// Create new machine type
  Future<ApiResult<MachineTypeDto>> createType({
    required MachineTypeDto machineType,
    required String accessToken,
  }) async {
    _logger.info('Creating machine type: ${machineType.name}');
    return _apiClient.send<MachineTypeDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _machineTypeEndpoints.create,
        data: machineType.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachineTypeDto.fromJson(json),
    );
  }

  /// Update machine type by ID
  Future<ApiResult<MachineTypeDto>> updateType({
    required int id,
    required MachineTypeDto machineType,
    required String accessToken,
  }) async {
    _logger.info('Updating machine type: id=$id');
    return _apiClient.send<MachineTypeDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _machineTypeEndpoints.update(id),
        data: machineType.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachineTypeDto.fromJson(json),
    );
  }

  /// Delete machine type by ID
  Future<ApiResult<void>> deleteType({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting machine type: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _machineTypeEndpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Part Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all machine parts for machine type
  Future<ApiResult<List<ShortenBaseDto>>> getAllParts({
    required int machineTypeId,
    required String accessToken,
  }) async {
    _logger.info('Fetching all machine parts: machineTypeId=$machineTypeId');
    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machinePartEndpoints.all,
        queryParameters: {'machineTypeId': machineTypeId},
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

  /// Get machine parts as tree structure
  Future<ApiResult<List<MachinePartDto>>> getPartsTree({
    required int machineTypeId,
    required String accessToken,
  }) async {
    _logger.info('Fetching machine parts tree: machineTypeId=$machineTypeId');
    return _apiClient.send<List<MachinePartDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machinePartEndpoints.allTree,
        queryParameters: {'machineTypeId': machineTypeId},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => MachinePartDto.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  /// Get machine part by ID
  Future<ApiResult<MachinePartDto>> getPartById({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Fetching machine part: id=$id');
    return _apiClient.send<MachinePartDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machinePartEndpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachinePartDto.fromJson(json),
    );
  }

  /// Create new machine part
  Future<ApiResult<MachinePartDto>> createPart({
    required MachinePartDto machinePart,
    required String accessToken,
  }) async {
    _logger.info('Creating machine part: ${machinePart.name}');
    return _apiClient.send<MachinePartDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _machinePartEndpoints.create,
        data: machinePart.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachinePartDto.fromJson(json),
    );
  }

  /// Update machine part by ID
  Future<ApiResult<MachinePartDto>> updatePart({
    required int id,
    required MachinePartDto machinePart,
    required String accessToken,
  }) async {
    _logger.info('Updating machine part: id=$id');
    return _apiClient.send<MachinePartDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _machinePartEndpoints.update(id),
        data: machinePart.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachinePartDto.fromJson(json),
    );
  }

  /// Delete machine part by ID
  Future<ApiResult<void>> deletePart({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting machine part: id=$id');
    return _apiClient.send<void>(
      request: (dio) => dio.delete<Map<String, dynamic>>(
        _machinePartEndpoints.delete(id),
        options: _authorizedOptions(accessToken),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Settings Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get machine settings for current user
  Future<ApiResult<MachineSettingDto>> getMachineSetting({
    required String accessToken,
  }) async {
    _logger.info('Fetching machine settings');
    return _apiClient.send<MachineSettingDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _machineEndpoints.machineSetting,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => MachineSettingDto.fromJson(json),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  MachineEndpoints get _machineEndpoints =>
      MachineEndpoints(_baseUrlProvider.apiBaseUrl);
  MachineTypeEndpoints get _machineTypeEndpoints =>
      MachineTypeEndpoints(_baseUrlProvider.apiBaseUrl);
  MachinePartEndpoints get _machinePartEndpoints =>
      MachinePartEndpoints(_baseUrlProvider.apiBaseUrl);

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
