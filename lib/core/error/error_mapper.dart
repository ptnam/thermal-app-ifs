import 'failure.dart';

class ErrorMapper {
  static String mapErrorToUserMessage(Object error) {
    if (error is String) {
      return _sanitizeMessage(error);
    }
    
    final errorStr = error.toString().toLowerCase();
    
    // Network errors
    if (errorStr.contains('socket') || errorStr.contains('connection refused')) {
      return 'Unable to connect to server. Please check your network connection.';
    }
    
    if (errorStr.contains('timeout')) {
      return 'The server is taking too long to respond. Please try again.';
    }
    
    if (errorStr.contains('handshake') || errorStr.contains('ssl') || errorStr.contains('certificate')) {
      return 'Secure connection failed. Please try again.';
    }
    
    // Auth errors
    if (errorStr.contains('unauthorized') || errorStr.contains('403')) {
      return 'You do not have permission to perform this action.';
    }
    
    if (errorStr.contains('invalid credentials') || errorStr.contains('wrong password')) {
      return 'Invalid username or password.';
    }
    
    if (errorStr.contains('user not found') || errorStr.contains('not exist')) {
      return 'User account not found.';
    }
    
    // Server errors
    if (errorStr.contains('500') || errorStr.contains('internal server error')) {
      return 'Server encountered an error. Please try again later.';
    }
    
    if (errorStr.contains('503') || errorStr.contains('service unavailable')) {
      return 'Service is temporarily unavailable. Please try again later.';
    }
    
    // Validation errors
    if (errorStr.contains('400') || errorStr.contains('bad request')) {
      return 'Invalid input. Please check and try again.';
    }
    
    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'Resource not found.';
    }
    
    if (errorStr.contains('409') || errorStr.contains('conflict')) {
      return 'Resource already exists or is in conflict.';
    }
    
    // Fallback
    return 'An unexpected error occurred. Please try again.';
  }
  
  /// Sanitize error message to remove technical details
  static String _sanitizeMessage(String message) {
    // Remove file paths
    message = message.replaceAll(RegExp(r'[a-zA-Z]:\\[^\s]+'), 'file_path_removed');
    message = message.replaceAll(RegExp(r'/[^\s]+'), 'file_path_removed');
    
    // Remove IP addresses and internal URLs
    message = message.replaceAll(RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'), 'internal_ip_removed');
    message = message.replaceAll(RegExp(r'localhost[^\s]*'), 'localhost_removed');
    
    // Remove stack traces
    message = message.replaceAll(RegExp(r'at\s+\w+\.\w+\([^)]*\)', multiLine: true), '');
    
    return message.isEmpty ? 'An error occurred' : message;
  }
  
  /// Check if error is retryable
  static bool isRetryable(Object error) {
    final errorStr = error.toString().toLowerCase();
    
    // Retryable network errors
    if (errorStr.contains('timeout')) return true;
    if (errorStr.contains('connection refused')) return true;
    if (errorStr.contains('connection reset')) return true;
    if (errorStr.contains('503')) return true;
    if (errorStr.contains('504')) return true;
    
    return false;
  }

  /// Map exception to domain Failure object
  static Failure mapException(Object exception) {
    final userMessage = mapErrorToUserMessage(exception);
    
    final exceptionStr = exception.toString().toLowerCase();
    
    // Determine failure type
    if (exceptionStr.contains('socket') || 
        exceptionStr.contains('connection') ||
        exceptionStr.contains('timeout')) {
      return NetworkFailure(
        message: userMessage,
        originalException: exception,
      );
    }
    
    if (exceptionStr.contains('401') || 
        exceptionStr.contains('unauthorized')) {
      return AuthFailure(
        message: userMessage,
        originalException: exception,
      );
    }
    
    if (exceptionStr.contains('400') || 
        exceptionStr.contains('parsing') ||
        exceptionStr.contains('format')) {
      return ParsingFailure(
        message: userMessage,
        originalException: exception,
      );
    }
    
    if (exceptionStr.contains('5') || 
        exceptionStr.contains('server')) {
      return ServerFailure(
        message: userMessage,
        originalException: exception,
      );
    }
    
    // Default to generic failure
    return GenericFailure(
      message: userMessage,
      originalException: exception,
    );
  }
}
