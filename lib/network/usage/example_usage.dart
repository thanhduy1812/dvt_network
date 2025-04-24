import 'dart:io';
import 'package:dio/dio.dart';
import '../network_service/gtd_end_points.dart';
import '../network_service/gtd_network_request.dart';
import '../network_service/gtd_network_service.dart';
import '../network_service/base_environment.dart';

class FileUploadExample {
  // Example of creating a custom environment
  static BaseEnvironment createEnvironment() {
    return BaseEnvironment(
      baseUrl: 'api.example.com',
      platformPath: 'api/v1/',
      headers: {
        'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
        'Accept': 'application/json',
      },
    );
  }

  /// Example 1: Upload a single file using the uploadFile method
  static Future<void> uploadSingleFile(File file) async {
    final environment = createEnvironment();
    final endpoint = GtdEndpoint(env: environment, path: 'upload');
    
    // Configure the network service
    final networkService = GtdNetworkService.shared;
    networkService.request = GTDNetworkRequest(
      type: GtdMethod.post,
      enpoint: endpoint,
      data: {
        'description': 'File uploaded from Flutter app',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    try {
      final response = await networkService.uploadFile(
        file: file,
        fieldName: 'file',
        extraData: {
          'type': 'profile_image',
        },
        onSendProgress: (int sent, int total) {
          final progress = (sent / total * 100).toStringAsFixed(2);
          print('Upload progress: $progress%');
        },
      );
      
      print('Upload successful: ${response.statusCode}');
      print('Response data: ${response.data}');
    } on DioException catch (e) {
      print('Upload failed: ${e.message}');
    }
  }

  /// Example 2: Upload multiple files using the more flexible approach
  static Future<void> uploadMultipleFiles(List<File> files, File document) async {
    final environment = createEnvironment();
    final endpoint = GtdEndpoint(env: environment, path: 'upload-multiple');
    
    // Create a network request with file information
    final request = GTDNetworkRequest(
      type: GtdMethod.post,
      enpoint: endpoint,
      data: {
        'description': 'Multiple files upload',
        'count': files.length + 1, // Total files being uploaded
      },
      files: {
        'images': files, // List of image files
        'document': document, // Single document file
      },
    );
    
    // Configure the network service
    final networkService = GtdNetworkService.shared;
    networkService.request = request;
    
    try {
      final response = await networkService.uploadFiles(
        onSendProgress: (int sent, int total) {
          final progress = (sent / total * 100).toStringAsFixed(2);
          print('Multiple files upload progress: $progress%');
        },
      );
      
      print('Multiple files upload successful: ${response.statusCode}');
      print('Response data: ${response.data}');
    } on DioException catch (e) {
      print('Multiple files upload failed: ${e.message}');
    }
  }

  /// Example 3: Upload a file with bytes directly
  static Future<void> uploadFileFromBytes(List<int> fileBytes, String fileName) async {
    final environment = createEnvironment();
    final endpoint = GtdEndpoint(env: environment, path: 'upload-bytes');
    
    // Create a MultipartFile from bytes
    final multipartFile = MultipartFile.fromBytes(
      fileBytes,
      filename: fileName,
    );
    
    // Create a network request
    final request = GTDNetworkRequest(
      type: GtdMethod.post,
      enpoint: endpoint,
      data: {
        'description': 'File uploaded from bytes',
      },
      files: {
        'file': multipartFile,
      },
    );
    
    // Configure the network service
    final networkService = GtdNetworkService.shared;
    networkService.request = request;
    
    try {
      final response = await networkService.uploadFiles();
      
      print('Bytes upload successful: ${response.statusCode}');
      print('Response data: ${response.data}');
    } on DioException catch (e) {
      print('Bytes upload failed: ${e.message}');
    }
  }
} 