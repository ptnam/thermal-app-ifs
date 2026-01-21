/// =============================================================================
/// File: failures.dart
/// Description: Domain layer failure types for error handling
/// 
/// Purpose:
/// - Defines typed failures for business logic errors
/// - Provides consistent error handling across the domain layer
/// =============================================================================

import 'package:equatable/equatable.dart';

/// Base class for all failures in the domain layer.
/// 
/// Failures represent recoverable errors that can be displayed to users
/// or handled gracefully by the application.
abstract class Failure extends Equatable {
  /// Human-readable error message.
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Represents a network connectivity failure.
/// 
/// Use when there's no internet connection or the server is unreachable.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

/// Represents a server-side error.
/// 
/// Use for 5xx HTTP errors or other server failures.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Represents an authentication failure (401).
/// 
/// Use when the user's session has expired or credentials are invalid.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

/// Represents a permission/authorization failure (403).
/// 
/// Use when the user doesn't have permission to access a resource.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Access forbidden']);
}

/// Represents a "not found" failure (404).
/// 
/// Use when the requested resource doesn't exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Represents a validation failure.
/// 
/// Use for client-side validation errors before making API calls.
class ValidationFailure extends Failure {
  /// Map of field names to error messages.
  final Map<String, String>? fieldErrors;

  const ValidationFailure([
    super.message = 'Validation error',
    this.fieldErrors,
  ]);

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Represents a cache-related failure.
/// 
/// Use when local storage operations fail.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Represents a timeout failure.
/// 
/// Use when a request exceeds the allowed time limit.
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

/// Represents a cancellation (user-initiated abort).
/// 
/// Use when the user cancels an ongoing operation.
class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Operation cancelled']);
}
