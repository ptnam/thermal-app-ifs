/// =============================================================================
/// File: api_response.dart
/// Description: Standard API response wrapper model
/// 
/// Purpose:
/// - Wraps all API responses in a consistent format
/// - Maps to backend's Responder<T> structure
/// - Provides success/error status checking
/// =============================================================================

/// Standard API response envelope
/// 
/// Maps to backend's Responder structure:
/// ```csharp
/// public class Responder<T> {
///   public bool IsSuccess { get; set; }
///   public string Code { get; set; }
///   public string Message { get; set; }
///   public T Data { get; set; }
/// }
/// ```
class ApiResponse<T> {
  /// Indicates if the request was successful
  final bool isSuccess;
  
  /// Response code (usually "200" for success)
  final String? code;
  
  /// Error or status message
  final String? message;
  
  /// Response data payload
  final T? data;

  const ApiResponse({
    required this.isSuccess,
    this.code,
    this.message,
    this.data,
  });

  /// Factory constructor to create from JSON with a mapper function
  /// 
  /// [json] - The raw JSON map from API response
  /// [fromJson] - Optional function to convert data field to type T
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJson,
  }) {
    final data = json['data'];
    return ApiResponse<T>(
      isSuccess: json['isSuccess'] as bool? ?? false,
      code: json['code'] as String?,
      message: json['message'] as String?,
      data: fromJson != null && data != null ? fromJson(data) : data as T?,
    );
  }

  /// Check if response indicates an error
  bool get hasError => !isSuccess || (code != null && code != '200');

  @override
  String toString() {
    return 'ApiResponse(isSuccess: $isSuccess, code: $code, message: $message)';
  }
}
