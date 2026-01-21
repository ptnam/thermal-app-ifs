import 'package:flutter/foundation.dart';

/// Logger service with sensitive data redaction
class AppLogger {
  static const String _tokenMask = '***TOKEN_REDACTED***';
  static const String _passwordMask = '***PASSWORD_REDACTED***';
  
  final String tag;
  final bool enableLogging;
  final bool enableLogBody;
  
  AppLogger({
    required this.tag,
    this.enableLogging = true,
    this.enableLogBody = true,
  });
  
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (!enableLogging) return;
    if (kDebugMode) {
      debugPrint('[$tag] DEBUG: ${_redactMessage(message)}');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  StackTrace: $stackTrace');
    }
  }
  
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    if (!enableLogging) return;
    if (kDebugMode) {
      debugPrint('[$tag] INFO: ${_redactMessage(message)}');
      if (error != null) debugPrint('  Error: $error');
    }
  }
  
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (!enableLogging) return;
    if (kDebugMode) {
      debugPrint('[$tag] WARNING: ${_redactMessage(message)}');
      if (error != null) debugPrint('  Error: $error');
    }
  }
  
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[$tag] ERROR: ${_redactMessage(message)}');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  StackTrace: $stackTrace');
    }
  }
  
  /// Redact sensitive data from log messages
  String _redactMessage(String message) {
    String result = message;
    
    // Redact JWT tokens - simple check
    if (result.contains('eyJ')) {
      result = result.replaceAll(
        RegExp(r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+'),
        _tokenMask,
      );
    }
    
    // Redact passwords - simple string replacement
    if (result.toLowerCase().contains('password')) {
      result = result.replaceAll(
        RegExp(r'password.*?:\s*\w+', caseSensitive: false),
        'password: $_passwordMask',
      );
    }
    
    // Redact Authorization headers
    if (result.contains('Authorization')) {
      result = result.replaceAll(
        RegExp(r'Authorization.*?:\s*Bearer\s+\w+', caseSensitive: false),
        'Authorization: Bearer $_tokenMask',
      );
    }
    
    return result;
  }
  
  /// Log HTTP request (with redaction)
  void logRequest({
    required String method,
    required String path,
    Map<String, dynamic>? headers,
    Object? body,
  }) {
    if (!enableLogging) return;
    if (kDebugMode) {
      debugPrint('[$tag] REQUEST: $method $path');
      if (enableLogBody && headers != null) {
        final headersLog = _redactHeaders(headers);
        debugPrint('  Headers: $headersLog');
      }
      if (enableLogBody && body != null) {
        debugPrint('  Body: ${_redactMessage(body.toString())}');
      }
    }
  }
  
  /// Log HTTP response (with redaction)
  void logResponse({
    required String method,
    required String path,
    required int statusCode,
    Object? body,
  }) {
    if (!enableLogging) return;
    if (kDebugMode) {
      debugPrint('[$tag] RESPONSE: $method $path - Status: $statusCode');
      if (enableLogBody && body != null) {
        debugPrint('  Body: ${_redactMessage(body.toString())}');
      }
    }
  }
  
  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final redacted = Map<String, dynamic>.from(headers);
    
    redacted.updateAll((key, value) {
      if (key.toLowerCase() == 'authorization' && value is String) {
        return 'Bearer $_tokenMask';
      }
      return value;
    });
    
    return redacted;
  }
}
