import 'package:dio/dio.dart';
import 'package:thermal_mobile/data/network/api/api_client.dart';
import 'package:thermal_mobile/data/network/api/api_result.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';
import 'auth_endpoints.dart';
import 'dto/auth_tokens_dto.dart';
import 'dto/login_request_dto.dart';
import 'dto/login_response_dto.dart';
import 'dto/refresh_token_request_dto.dart';
import 'dto/user_dto.dart';
import '../../../core/logger/app_logger.dart';

class AuthApiService {
  AuthApiService(
    ApiClient apiClient,
    BaseUrlProvider baseUrlProvider, {
    AppLogger? logger,
  })  : _apiClient = apiClient,
        _baseUrlProvider = baseUrlProvider;

  final ApiClient _apiClient;
  final BaseUrlProvider _baseUrlProvider;

  Future<ApiResult<AuthTokensDto>> login(LoginRequestDto request) {
    return _apiClient.send<AuthTokensDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _endpoints.login,
        data: request.toJson(),
        options: _jsonOptions,
      ),
      mapper: (json) => LoginResponseDto.fromJson(json).tokens,
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  Future<ApiResult<void>> logout({required String accessToken}) {
    return _apiClient.send<void>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _endpoints.logout,
        data: {}, // Send empty body to satisfy API validation
        options: _authorizedOptions(accessToken),
      ),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  Future<ApiResult<AuthTokensDto>> refreshToken(
    RefreshTokenRequestDto request,
  ) {
    return _apiClient.send<AuthTokensDto>(
      request: (dio) => dio.post<Map<String, dynamic>>(
        _endpoints.refresh,
        data: request.toJson(),
        options: _jsonOptions,
      ),
      mapper: (json) => AuthTokensDto.fromJson(json),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  Future<ApiResult<UserDto>> getProfile({required String accessToken}) {
    return _apiClient.send<UserDto>(
      request: (dio) => dio.get<Map<String, dynamic>>(
        _endpoints.profile,
        options: _authorizedOptions(accessToken),
      ),
      mapper: (json) => UserDto.fromJson(json),
      errorMessageTransformer: _decodeHtmlEntities,
    );
  }

  AuthEndpoints get _endpoints => AuthEndpoints(_baseUrlProvider.apiBaseUrl);

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
}
