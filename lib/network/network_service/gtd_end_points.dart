import 'base_environment.dart';

class GtdEndpoint {
  // GTDEndpoints._();

  // // base url
  // static const String baseUrl = "https://uat-api.gotadi.com";

  // // recieveTimeout
  // static const int receiveTimeout = 30;

  // // connectTimeout
  // static const int connectTimeout = 30;

  BaseEnvironment env;
  String path;
  Map<String, dynamic>? params;
  late Uri uri;
  GtdEndpoint({required this.env, required this.path}) {
    uri = Uri(
        scheme: "https", host: env.baseUrl, path: '/${env.platformPath}$path');
  }
}
