import 'gtd_end_points.dart';

enum GtdMethod { get, post, put, patch, delete }

class GTDNetworkRequest {
  GTDNetworkRequest({
    this.type = GtdMethod.get,
    // required this.env,
    required this.enpoint,
    this.data,
    this.queryParams,
    this.headers,
    this.connectTimeout = 30,
    this.receiveTimeout = 30,
  }) {
    //Todo: add combine headers from endpoint and network headers
    headers = enpoint.env.headers;
  }

  GtdMethod type;
  final GtdEndpoint enpoint;
  final dynamic data;
  Map<String, dynamic>? queryParams;
  Map<String, String>? headers;
  int connectTimeout;
  int receiveTimeout;

  Uri buildUri() {
    queryParams?.removeWhere((key, value) => value == null);
    //Convert value to String for query
    var finalQuery = queryParams?.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      } else {
        return MapEntry(key, value.toString());
      }
    });
    Uri uri =
        Uri(scheme: enpoint.uri.scheme, host: enpoint.uri.host, path: enpoint.uri.path, queryParameters: finalQuery);
    return uri;
  }
}
