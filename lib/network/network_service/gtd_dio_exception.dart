import 'package:dio/dio.dart';
import 'gtd_app_logger.dart';

class GtdDioException implements Exception {
  late String message;
  late String code;
  late String status;
  late String stackTrace;

  GtdDioException.fromError({this.message = "Unknown Error", this.code = "UNKNOWN", this.stackTrace = ''});

  GtdDioException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.unknown:
        if (dioError.message?.contains("SocketException") ?? false) {
          message = 'No Internet';
          break;
        }
        message = "Unexpected error occurred";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String _handleError(int? statusCode, dynamic error) {
    try {
      String? errorMessage = error['error']['message'];
      if (errorMessage != null && errorMessage.isNotEmpty) {
        return errorMessage;
      }
    } catch (e) {
      NetWorkLogger.e(e.toString());
    }

    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return error['message'];
      case 417:
        return "ExpiredToken";
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message;
}
