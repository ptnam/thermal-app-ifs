import 'package:dio/dio.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import '../../../core/logger/app_logger.dart';
import 'area_endpoints.dart';
import 'dto/area_tree_dto.dart';
import 'dto/area_dto.dart';

/// API service for Area management
/// Provides methods to fetch area tree and related data from the backend
class AreaApiService {
  AreaApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider,
        _logger = logger ?? AppLogger(tag: 'AreaApiService');

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;
  final AppLogger _logger;

  /// Fetch complete area all tree
  /// [accessToken] - Bearer token for authorization
  /// Returns: List of root area nodes with nested children and associated cameras
  Future<ApiResult<List<AreaTreeDto>>> getAreaAllTree({
    required String accessToken,
  }) async {
    return _apiClient.send<List<AreaTreeDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.allTree,
        queryParameters: {'cameras': true},
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        
        // Json có thể là Map (wrapper) hoặc List trực tiếp
        if (json is List) {
          
          return (json)
              .map((e) {
                try {
                  return AreaTreeDto.fromJson(_castToStringDynamic(e));
                } catch (e) {
                  _logger.error('Failed to parse area: $e');
                  rethrow;
                }
              })
              .toList();
        }
        
        // Hoặc là Map wrapper với data field
        final jsonMap = _castToStringDynamic(json);
        final data = jsonMap['data'];
        
        if (data == null) {
          _logger.error('Response data is null');
          throw FormatException('Response data field is null');
        }
        
        if (data is! List) {
          _logger.error('Response data is not a list: ${data.runtimeType}');
          throw FormatException('Response data is not a list: ${data.runtimeType}');
        }
        
        
        return (data)
            .map((e) {
              try {
                return AreaTreeDto.fromJson(_castToStringDynamic(e));
              } catch (e) {
                _logger.error('Failed to parse area: $e');
                rethrow;
              }
            })
            .toList();
      },
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Fetch single area by ID
  /// [id] - Area ID
  /// [accessToken] - Bearer token for authorization
  Future<ApiResult<AreaTreeDto>> getAreaById({
    required int id,
    required String accessToken,
  }) async {
    return _apiClient.send<AreaTreeDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.byId(id),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        
        // Cast to proper type
        final jsonMap = _castToStringDynamic(json);
        
        // Check if response is wrapped with data field
        final data = jsonMap['data'];
        if (data != null && data is Map) {
          return AreaTreeDto.fromJson(_castToStringDynamic(data));
        }
        
        // Or response might be the area directly
        if (jsonMap.containsKey('id')) {
          return AreaTreeDto.fromJson(jsonMap);
        }
        
        _logger.error('Invalid response format for area $id: ${json.runtimeType}');
        throw FormatException('Invalid response format for area $id');
      },
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  AreaEndpoints get _endpoints => AreaEndpoints(_baseUrlProvider.apiBaseUrl);

  // ─────────────────────────────────────────────────────────────────────────
  // Additional CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all areas (flat list)
  Future<ApiResult<List<ShortenBaseDto>>> getAllAreas({
    required String accessToken,
    CommonStatus? status,
  }) async {
    final queryParams = <String, dynamic>{
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<List<ShortenBaseDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.all,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) {
        if (json is List) {
          return json.map((e) => ShortenBaseDto.fromJson(_castToStringDynamic(e))).toList();
        }
        return [];
      },
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Get paginated area list
  Future<ApiResult<PagingResponse<AreaDto>>> getAreaList({
    required String accessToken,
    int page = 1,
    int pageSize = 10,
    String? name,
    CommonStatus? status,
  }) async {
    _logger.info('Fetching area list: page=$page');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (name != null && name.isNotEmpty) 'name': name,
      if (status != null) 'status': status.value,
    };

    return _apiClient.send<PagingResponse<AreaDto>>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.list,
        queryParameters: queryParams,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => PagingResponse.fromJson(_castToStringDynamic(json), AreaDto.fromJson),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Create new area
  Future<ApiResult<AreaDto>> createArea({
    required AreaDto area,
    required String accessToken,
  }) async {
    _logger.info('Creating area: ${area.name}');
    return _apiClient.send<AreaDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _endpoints.create,
        data: area.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => AreaDto.fromJson(_castToStringDynamic(json)),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Update area by ID
  Future<ApiResult<AreaDto>> updateArea({
    required int id,
    required AreaDto area,
    required String accessToken,
  }) async {
    _logger.info('Updating area: id=$id');
    return _apiClient.send<AreaDto>(
      request: (dio) => dio.put<Map<String, dynamic>>(
        _endpoints.update(id),
        data: area.toJson(),
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => AreaDto.fromJson(_castToStringDynamic(json)),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  /// Delete area by ID
  Future<ApiResult<void>> deleteArea({
    required int id,
    required String accessToken,
  }) async {
    _logger.info('Deleting area: id=$id');
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
