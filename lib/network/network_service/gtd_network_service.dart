import 'dart:io';
import 'package:dio/dio.dart';
import 'gtd_app_logger.dart';
import 'gtd_dio_curl_logging.dart';
import 'gtd_network_request.dart';
import 'gtd_error.dart';

class GtdNetworkService {
  // dio instance
  final Dio _dio = Dio();
  CancelToken cancelNetwork = CancelToken();

  late GTDNetworkRequest request;
  // injecting dio instance
  GtdNetworkService._() {
    _dio.interceptors.add(GtdDioInterceptor(printOnSuccess: true));
  }
  static final shared = GtdNetworkService._();
  // GTDDioClient() {
  // _dio
  //   ..options.baseUrl = GTDEndpoints.baseUrl
  //   ..options.headers = request.headers
  //   ..options.connectTimeout =
  //       const Duration(seconds: GTDEndpoints.connectTimeout)
  //   ..options.receiveTimeout =
  //       const Duration(seconds: GTDEndpoints.receiveTimeout)
  //   ..options.responseType = ResponseType.json
  //   ..interceptors.add(GTDDioInterceptor(printOnSuccess: true));
  // ..interceptors.add(LogInterceptor(
  //   request: true,
  //   requestHeader: true,
  //   requestBody: true,
  //   responseHeader: true,
  //   responseBody: true,
  // ));
  // }


  Future<Response> execute({
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      _dio.options.connectTimeout = Duration(seconds: request.connectTimeout);
      _dio.options.receiveTimeout = Duration(seconds: request.receiveTimeout);
      // _dio.interceptors.add(GtdDioInterceptor(printOnSuccess: true));
      _dio.options.responseType = ResponseType.json;
      _dio.options.headers = request.headers; // For remove content-lengh limit
      final Response response = await _dio.requestUri(
        request.buildUri(),
        data: request.data,
        options: Options(method: request.type.name),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      final gtdError = GtdError.fromDioError(e);
      GtdLogger.e('DioError: ${gtdError.message}\nTrace: ${gtdError.stackTrace}');
      throw gtdError;
    } catch (e, stackTrace) {
      final gtdError = GtdError.custom(
        'Unknown error occurred: ${e.toString()}',
        errorCode: 'UNKNOWN',
      );
      GtdLogger.e('UnknownError: ${gtdError.message}\nTrace: $stackTrace');
      throw gtdError;
    }
  }

  /// Upload files using multipart form data
  /// 
  /// This method handles file uploads with progress tracking
  Future<Response> uploadFiles({
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      _dio.options.connectTimeout = Duration(seconds: request.connectTimeout);
      _dio.options.receiveTimeout = Duration(seconds: request.receiveTimeout);
      _dio.options.responseType = ResponseType.json;
      _dio.options.headers = request.headers;
      
      // Create FormData from request
      final formData = await request.createFormData();
      
      final Response response = await _dio.requestUri(
        request.buildUri(),
        data: formData,
        options: Options(
          method: request.type.name,
          contentType: 'multipart/form-data',
          // Prevent dio from setting the content-type header with the boundary
          // as it will be set correctly when the request is sent
          headers: {
            'content-type': 'multipart/form-data',
          },
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress ?? _defaultSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      final gtdError = GtdError.fromDioError(e);
      GtdLogger.e('DioError: ${gtdError.message}\nTrace: ${gtdError.stackTrace}');
      throw gtdError;
    } catch (e, stackTrace) {
      final gtdError = GtdError.custom(
        'Unknown error occurred: ${e.toString()}',
        errorCode: 'UNKNOWN',
      );
      GtdLogger.e('UnknownError: ${gtdError.message}\nTrace: $stackTrace');
      throw gtdError;
    }
  }

  /// Upload a single file to the server
  /// 
  /// Simplified method for uploading a single file
  Future<Response> uploadFile({
    required File file,
    required String fieldName,
    String? fileName,
    Map<String, dynamic>? extraData,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Create a FormData instance
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName ?? file.path.split('/').last,
        ),
        ...?extraData,
      });

      _dio.options.connectTimeout = Duration(seconds: request.connectTimeout);
      _dio.options.receiveTimeout = Duration(seconds: request.receiveTimeout);
      _dio.options.responseType = ResponseType.json;
      _dio.options.headers = request.headers;

      final Response response = await _dio.requestUri(
        request.buildUri(),
        data: formData,
        options: Options(
          method: request.type.name,
          contentType: 'multipart/form-data',
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress ?? _defaultSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      final gtdError = GtdError.fromDioError(e);
      GtdLogger.e('DioError: ${gtdError.message}\nTrace: ${gtdError.stackTrace}');
      throw gtdError;
    } catch (e, stackTrace) {
      final gtdError = GtdError.custom(
        'Unknown error occurred: ${e.toString()}',
        errorCode: 'UNKNOWN',
      );
      GtdLogger.e('UnknownError: ${gtdError.message}\nTrace: $stackTrace');
      throw gtdError;
    }
  }

  /// Default progress callback that logs the upload progress
  void _defaultSendProgress(int sent, int total) {
    if (total != -1) {
      final progress = (sent / total * 100).toStringAsFixed(2);
      GtdLogger.i('Upload progress: $progress%');
    }
  }
}
