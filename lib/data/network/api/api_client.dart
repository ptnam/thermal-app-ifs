import 'package:dio/dio.dart';

import 'api_error.dart';
import 'api_result.dart';
import '../../../core/logger/app_logger.dart';

class ApiClient {
  ApiClient(this._dio, {AppLogger? logger})
      : _logger = logger ?? AppLogger(tag: 'ApiClient');

  final Dio _dio;
  final AppLogger _logger;

  Future<ApiResult<T>> send<T>({
    required Future<Response<Map<String, dynamic>>> Function(Dio dio) request,
    T Function(dynamic json)? mapper,
    String Function(String message)? errorMessageTransformer,
  }) async {
    try {
      final response = await request(_dio);
      final envelope = _ServerEnvelope.fromResponse(response);

      if (!envelope.isSuccess) {
        final message = _transformMessage(
          envelope.message ?? 'Unexpected server response',
          errorMessageTransformer,
        );
        _logger.warning('API error: $message');
        return ApiResult.failure(
          ApiError(
            message: message,
            statusCode: response.statusCode,
            code: envelope.code,
          ),
        );
      }

      if (mapper == null) {
        return ApiResult.success<T>();
      }

      final dataJson = envelope.data;
      
      // Data can be Map or List, pass it as-is to mapper
      if (dataJson != null) {
        try {
          return ApiResult.success<T>(mapper(dataJson));
        } catch (e, st) {
          _logger.error('Mapper error', error: e, stackTrace: st);
          return ApiResult.failure(
            ApiError(
              message: 'Failed to parse response: $e',
              statusCode: response.statusCode,
              code: envelope.code,
            ),
          );
        }
      }

      return ApiResult.failure(
        ApiError(
          message: 'Response payload is missing or has invalid format',
          statusCode: response.statusCode,
          code: envelope.code,
        ),
      );
    } on DioException catch (exception, stackTrace) {
      final errorMsg = _extractErrorMessage(exception, errorMessageTransformer);
      _logger.error('DioException: ${exception.type}', error: exception, stackTrace: stackTrace);
      return ApiResult.failure(
        ApiError(
          message: errorMsg,
          statusCode: exception.response?.statusCode,
          code: exception.response?.statusCode?.toString(),
          cause: exception,
          stackTrace: stackTrace,
        ),
      );
    } catch (exception, stackTrace) {
      _logger.error('Unexpected error', error: exception, stackTrace: stackTrace);
      return ApiResult.failure(
        ApiError(
          message: 'Unexpected error: $exception',
          cause: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  String _extractErrorMessage(
    DioException exception,
    String Function(String message)? transformer,
  ) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final serverMessage = data['message'] as String?;
      if (serverMessage != null && serverMessage.isNotEmpty) {
        return _transformMessage(serverMessage, transformer);
      }
    }
    return exception.message ?? 'Network error';
  }

  String _transformMessage(
    String message,
    String Function(String message)? transformer,
  ) {
    if (transformer == null) {
      return message;
    }
    return transformer(message);
  }
}

class _ServerEnvelope {
  final bool isSuccess;
  final String? message;
  final Object? data;
  final String? code;

  const _ServerEnvelope({
    required this.isSuccess,
    this.message,
    this.data,
    this.code,
  });

  factory _ServerEnvelope.fromResponse(
    Response<Map<String, dynamic>> response,
  ) {
    final payload = response.data ?? const <String, dynamic>{};
    return _ServerEnvelope(
      isSuccess: payload['isSuccess'] as bool? ?? false,
      message: payload['message'] as String?,
      data: payload['data'],
      code: payload['code']?.toString(),
    );
  }
}
