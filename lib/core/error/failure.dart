/// Base failure class for error handling
/// Used in Either<Failure, T> pattern for result handling
abstract class Failure {
  final String message;
  final String? code;
  final dynamic originalException;

  Failure({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}

/// Network-related failure
class NetworkFailure extends Failure {
  NetworkFailure({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'NETWORK_ERROR',
    originalException: originalException,
  );
}

/// Server-related failure (4xx, 5xx HTTP responses)
class ServerFailure extends Failure {
  final int? statusCode;

  ServerFailure({
    required String message,
    this.statusCode,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'SERVER_ERROR',
    originalException: originalException,
  );
}

/// Cache-related failure
class CacheFailure extends Failure {
  CacheFailure({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'CACHE_ERROR',
    originalException: originalException,
  );
}

/// Parsing/serialization failure
class ParsingFailure extends Failure {
  ParsingFailure({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'PARSING_ERROR',
    originalException: originalException,
  );
}

/// Authentication failure
class AuthFailure extends Failure {
  AuthFailure({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'AUTH_ERROR',
    originalException: originalException,
  );
}

/// Generic failure for unmapped errors
class GenericFailure extends Failure {
  GenericFailure({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'UNKNOWN_ERROR',
    originalException: originalException,
  );
}
