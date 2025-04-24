import 'package:dio/dio.dart';

/// A comprehensive error handling class for network requests
/// that standardizes error reporting across the application.
class GtdError implements Exception {
  /// Error message to display to the user
  final String message;
  
  /// HTTP status code if available
  final int? statusCode;
  
  /// Error code for categorizing errors
  final String? errorCode;
  
  /// Original error that caused this exception
  final GtdError? originalError;
  
  /// Stack trace for debugging
  final StackTrace? stackTrace;

  GtdError({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.originalError,
    this.stackTrace,
  });
  
  /// Factory constructor to create GtdError from DioException
  factory GtdError.fromDioError(DioException dioError) {
    String message = 'Unknown error occurred';
    int? statusCode;
    dynamic data;
    
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timed out';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout occurred';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout occurred';
        break;
      case DioExceptionType.badCertificate:
        message = 'Invalid SSL certificate';
        break;
      case DioExceptionType.badResponse:
        statusCode = dioError.response?.statusCode;
        data = dioError.response?.data;
        
        // Handle different HTTP error codes
        if (statusCode != null) {
          if (statusCode >= 500) {
            message = 'Server error (${statusCode})';
          } else if (statusCode == 404) {
            message = 'Resource not found (404)';
          } else if (statusCode == 401) {
            message = 'Unauthorized (401)';
          } else if (statusCode == 403) {
            message = 'Forbidden (403)';
          } else if (statusCode >= 400) {
            message = 'Client error (${statusCode})';
          } else {
            message = 'HTTP error ${statusCode}';
          }
          
          // Try to extract error message from response
          if (data != null) {
            try {
              // Check common error response formats
              if (data is Map) {
                if (data.containsKey('message')) {
                  message = data['message'];
                } else if (data.containsKey('error')) {
                  final error = data['error'];
                  if (error is String) {
                    message = error;
                  } else if (error is Map && error.containsKey('message')) {
                    message = error['message'];
                  }
                }
              }
            } catch (e) {
              // Fallback to default message if error extraction fails
            }
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error occurred';
        break;
      case DioExceptionType.unknown:
        message = dioError.message ?? 'Unknown error occurred';
        if (dioError.error is Exception) {
          message = dioError.error.toString();
        }
        break;
    }

    // Construct with extracted data
    return GtdError(
      message: message,
      statusCode: statusCode,
      stackTrace: dioError.stackTrace,
      errorCode: _extractErrorCode(dioError, statusCode),
    );
  }
  
  /// Creates a GtdError from a generic exception
  factory GtdError.fromException(dynamic exception, [StackTrace? stackTrace]) {
    return GtdError(
      message: exception.toString(),
      stackTrace: stackTrace,
    );
  }
  
  /// Creates a GtdError with a custom message
  factory GtdError.custom(String message, {
    int? statusCode,
    String? errorCode,
  }) {
    return GtdError(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }
  
  /// Creates a GtdError from another GtdError, preserving the original stacktrace
  factory GtdError.fromError(GtdError error, {
    required String message,
    required String errorCode,
  }) {
    return GtdError(
      message: message,
      errorCode: errorCode,
      originalError: error,
      stackTrace: error.stackTrace,
      statusCode: error.statusCode,
    );
  }
  
  /// Recursively gets the original error source from a chain of GtdError objects
  dynamic getOriginalErrorSource() {
    if (originalError == null) {
      return this;
    }
    return originalError!.getOriginalErrorSource();
  }
  
  /// Helper method to extract an error code from the error
  static String? _extractErrorCode(DioException dioError, int? statusCode) {
    // First try to extract error code from response data
    if (dioError.response?.data is Map) {
      final data = dioError.response?.data;
      if (data.containsKey('code')) {
        return data['code'].toString();
      } else if (data.containsKey('error_code')) {
        return data['error_code'].toString();
      }
    }
    
    // Use status code as fallback
    return statusCode?.toString();
  }
  
  /// Returns a human-readable string representation of the error
  @override
  String toString() {
    return 'GtdError: $message${statusCode != null ? ' ($statusCode)' : ''}${errorCode != null ? ' [code: $errorCode]' : ''}';
  }
  
  /// Returns a detailed diagnostic message for debugging, including stack trace
  String toDetailedString() {
    final buffer = StringBuffer();
    buffer.writeln(toString());
    
    if (originalError != null) {
      buffer.writeln('Original error: $originalError');
    }
    
    if (stackTrace != null) {
      buffer.writeln('Stack trace:');
      buffer.writeln(stackTrace);
    }
    
    return buffer.toString();
  }
} 