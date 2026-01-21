class ApiError {
  final String message;
  final int? statusCode;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;

  const ApiError({
    required this.message,
    this.statusCode,
    this.code,
    this.cause,
    this.stackTrace,
  });
}
