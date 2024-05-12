import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'gtd_app_logger.dart';

class GtdDioInterceptor extends Interceptor {
  final bool? printOnSuccess;
  final bool convertFormData;

  GtdDioInterceptor({this.printOnSuccess, this.convertFormData = true});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    NetWorkLogger.e('Error: $err \n ${err.response}');
    _renderCurlRepresentation(err.requestOptions);

    return handler.next(err); //continue
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (printOnSuccess != null && printOnSuccess == true) {
      _renderCurlRepresentation(response.requestOptions);
    }

    // MARK: remove comment
    NetWorkLogger.i('RESPONSE:--------------------------');
    NetWorkLogger.i(
        'RESPONSE:${response.requestOptions.method} ${response.statusCode} \n ${response.requestOptions.uri}');
    // logJson(tag: "APICall", json: response.data);

    NetWorkLogger.d(response.toString());

    // logJson(tag: "RESPONSE: ", json: response.data as Object);

    return handler.next(response); //continue
  }

  void _renderCurlRepresentation(RequestOptions requestOptions) {
    // add a breakpoint here so all errors can break
    try {
      // MARK: remove comment
      NetWorkLogger.i('REQUEST:${requestOptions.method}--------------------------');
      NetWorkLogger.i(_cURLRepresentation(requestOptions));
    } catch (err) {
      log('unable to create a CURL representation of the requestOptions');
    }
  }

  String _cURLRepresentation(RequestOptions options) {
    List<String> components = ['curl -i'];
    if (options.method.toUpperCase() != 'GET') {
      components.add('-X ${options.method}');
    }

    options.headers.forEach((k, v) {
      if (k != 'Cookie') {
        components.add('-H "$k: $v"');
      }
    });

    if (options.data != null) {
      // FormData can't be JSON-serialized, so keep only their fields attributes
      if (options.data is FormData && convertFormData == true) {
        options.data = Map.fromEntries(options.data.fields);
      }

      final data = json.encode(options.data).replaceAll('"', '\\"');
      components.add('-d "$data"');
    }

    components.add('"${options.uri.toString()}"');

    return components.join(' \\\n\t');
  }

  void logJson({String tag = "", dynamic json}) {
    // final jsonString = json.encode(json);
    const encoder = JsonEncoder.withIndent('  ');
    final prettyString = encoder.convert(json);
    NetWorkLogger.d('$tag\n $prettyString');
  }

  String prettyJson(dynamic json) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyString = encoder.convert(json);
    return prettyString;
  }
}
