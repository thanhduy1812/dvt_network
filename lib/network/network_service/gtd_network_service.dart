import 'package:dio/dio.dart';
import 'gtd_app_logger.dart';
import 'gtd_dio_curl_logging.dart';
import 'gtd_dio_exception.dart';
import 'gtd_network_request.dart';

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
  // Get:-----------------------------------------------------------------------
  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Post:----------------------------------------------------------------------
  Future<Response> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Put:-----------------------------------------------------------------------
  Future<Response> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Delete:--------------------------------------------------------------------
  Future<dynamic> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

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
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchAPI({
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
      return response.data;
    } on DioException catch (e) {
      NetWorkLogger.e('Trace: ${e.stackTrace} \nErrorMess: ${e.toString()}');
      GtdDioException dioException = GtdDioException.fromDioError(e);
      throw dioException;
    } catch (e) {
      rethrow;
    }
  }
}
