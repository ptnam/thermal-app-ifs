/// Generic API response wrapper for area endpoints
class AreaApiResponse<T> {
  final bool isSuccess;
  final String code;
  final String? name;
  final String? message;
  final T? data;

  const AreaApiResponse({
    required this.isSuccess,
    required this.code,
    this.name,
    this.message,
    this.data,
  });

  factory AreaApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return AreaApiResponse<T>(
      isSuccess: json['isSuccess'] as bool? ?? false,
      code: json['code'] as String? ?? '',
      name: json['name'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'isSuccess': isSuccess,
    'code': code,
    'name': name,
    'message': message,
    'data': data,
  };

  @override
  String toString() => 'AreaApiResponse(isSuccess: $isSuccess, code: $code)';
}
