import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  print('Starting simple API tests...');
  print('===========================');
  
  // Setup Dio instance
  final dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {'Accept': 'application/json'},
  ));
  
  // Test GET request
  print('\n1. Testing GET API:');
  print('-----------------');
  try {
    final response = await dio.get('/posts', queryParameters: {'userId': 1});
    print('GET request successful: ${response.statusCode}');
    print('Number of items received: ${response.data.length}');
    print('First item: ${response.data[0]}');
  } catch (e) {
    print('GET test failed: $e');
  }
  
  // Test file upload
  print('\n2. Testing File Upload:');
  print('---------------------');
  try {
    // Create a test file
    final tempDir = await Directory.systemTemp.createTemp('test_api_');
    final testFile = File('${tempDir.path}/test_file.txt');
    await testFile.writeAsString('This is a test file for upload testing - ${DateTime.now()}');
    print('Created test file at: ${testFile.path}');
    
    // Create form data
    final formData = FormData.fromMap({
      'description': 'Test file upload',
      'timestamp': DateTime.now().toIso8601String(),
      'file': await MultipartFile.fromFile(
        testFile.path,
        filename: 'test_file.txt',
      ),
    });
    
    // Upload to httpbin for testing
    final uploadDio = Dio(BaseOptions(
      baseUrl: 'https://httpbin.org',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    
    final uploadResponse = await uploadDio.post(
      '/post',
      data: formData,
      onSendProgress: (int sent, int total) {
        final progress = (sent / total * 100).toStringAsFixed(2);
        print('Upload progress: $progress%');
      },
    );
    
    print('Upload test completed successfully: ${uploadResponse.statusCode}');
    print('Response data: ${uploadResponse.data}');
    
    // Clean up
    await tempDir.delete(recursive: true);
    print('Test file cleaned up');
  } catch (e) {
    print('Upload test failed: $e');
  }
  
  print('\nSimple API tests completed.');
} 