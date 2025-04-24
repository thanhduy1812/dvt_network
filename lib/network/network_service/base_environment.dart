class BaseEnvironment {
  final String baseUrl;
  final String platformPath;
  final Map<String, String> headers;
  
  BaseEnvironment({
    required this.baseUrl,
    required this.platformPath,
    required this.headers,
  });
}
