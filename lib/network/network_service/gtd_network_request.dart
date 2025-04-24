import 'dart:io';
import 'package:dio/dio.dart';
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
    this.files,
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
  /// Key-value pairs for multipart files, where key is the form field name
  /// and value is either a File, List<int>, or MultipartFile
  Map<String, dynamic>? files;

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
    Uri uri = Uri(
        scheme: enpoint.uri.scheme,
        host: enpoint.uri.host,
        path: enpoint.uri.path,
        queryParameters: finalQuery);
    return uri;
  }

  /// Creates a FormData object from the request data and files
  Future<FormData> createFormData() async {
    if (files == null || files!.isEmpty) {
      // If no files, just use the data
      return FormData.fromMap(data ?? {});
    }

    // Start with the regular data
    Map<String, dynamic> formMap = {...(data ?? {})};

    // Add files
    for (var entry in files!.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is File) {
        // Convert File to MultipartFile
        formMap[key] = await MultipartFile.fromFile(
          value.path,
          filename: value.path.split('/').last,
        );
      } else if (value is List<int>) {
        // Convert bytes to MultipartFile
        formMap[key] = MultipartFile.fromBytes(
          value,
          filename: 'file_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else if (value is MultipartFile) {
        // Already a MultipartFile
        formMap[key] = value;
      } else if (value is List) {
        // Handle list of files
        formMap[key] = await _handleFileList(value);
      }
    }

    return FormData.fromMap(formMap);
  }

  Future<List<MultipartFile>> _handleFileList(List fileList) async {
    List<MultipartFile> multipartFiles = [];

    for (var file in fileList) {
      if (file is File) {
        // Convert File to MultipartFile
        multipartFiles.add(await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ));
      } else if (file is List<int>) {
        // Convert bytes to MultipartFile
        multipartFiles.add(MultipartFile.fromBytes(
          file,
          filename: 'file_${DateTime.now().millisecondsSinceEpoch}',
        ));
      } else if (file is MultipartFile) {
        // Already a MultipartFile
        multipartFiles.add(file);
      }
    }

    return multipartFiles;
  }
}
