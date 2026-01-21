import 'api_error.dart';

class ApiResult<T> {
  final T? data;
  final ApiError? error;

  const ApiResult._({this.data, this.error});

  bool get isSuccess => error == null;

  static ApiResult<T> success<T>([T? data]) => ApiResult<T>._(data: data);

  static ApiResult<T> failure<T>(ApiError error) =>
      ApiResult<T>._(error: error);

  R fold<R>({
    required R Function(ApiError error) onFailure,
    required R Function(T? data) onSuccess,
  }) {
    if (isSuccess) {
      return onSuccess(data);
    }
    return onFailure(error!);
  }
}


