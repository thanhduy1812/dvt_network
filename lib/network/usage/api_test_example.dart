import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../gtd_network.dart';

class ApiTestExample {
  // Create a test environment
  static BaseEnvironment createTestEnvironment() {
    return BaseEnvironment(
      baseUrl: 'jsonplaceholder.typicode.com', // Test API
      platformPath: '', // No platform path for this API
      headers: {
        'Accept': 'application/json',
      },
    );
  }

  /// Test GET API request
  static Future<dynamic> testGetRequest() async {
    final environment = createTestEnvironment();
    final endpoint = GtdEndpoint(env: environment, path: 'posts');
    
    // Configure the network service with a GET request
    final networkService = GtdNetworkService.shared;
    networkService.request = GTDNetworkRequest(
      type: GtdMethod.get,
      enpoint: endpoint,
      queryParams: {
        'userId': 1, // Optional filter
      },
    );
    
    try {
      // Execute the GET request
      final response = await networkService.execute();
      
      print('GET request successful: ${response.statusCode}');
      print('Response data (first item): ${response.data[0]}');
      return response.data;
    } on DioException catch (e) {
      print('GET request failed: ${e.message}');
      rethrow;
    }
  }

  /// Test file upload to a public test API
  static Future<dynamic> testFileUpload(File file) async {
    // Use httpbin.org as it accepts file uploads for testing
    final environment = BaseEnvironment(
      baseUrl: 'httpbin.org',
      platformPath: '',
      headers: {
        'Accept': 'application/json',
      },
    );
    
    final endpoint = GtdEndpoint(env: environment, path: 'post');
    
    // Configure the network service
    final networkService = GtdNetworkService.shared;
    networkService.request = GTDNetworkRequest(
      type: GtdMethod.post,
      enpoint: endpoint,
      data: {
        'description': 'Test file upload',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    try {
      final response = await networkService.uploadFile(
        file: file,
        fieldName: 'file',
        onSendProgress: (int sent, int total) {
          final progress = (sent / total * 100).toStringAsFixed(2);
          print('Upload progress: $progress%');
        },
      );
      
      print('Upload test successful: ${response.statusCode}');
      print('Response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('Upload test failed: ${e.message}');
      rethrow;
    }
  }
}

/// Widget to demonstrate API testing in a Flutter app
class ApiTestWidget extends StatefulWidget {
  const ApiTestWidget({Key? key}) : super(key: key);

  @override
  _ApiTestWidgetState createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  String _getResult = 'No results yet';
  String _uploadResult = 'No upload yet';
  bool _isLoading = false;

  Future<void> _testGetApi() async {
    setState(() {
      _isLoading = true;
      _getResult = 'Loading...';
    });

    try {
      final result = await ApiTestExample.testGetRequest();
      setState(() {
        _getResult = 'Success! First item: ${result[0]['title']}';
      });
    } catch (e) {
      setState(() {
        _getResult = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUploadApi() async {
    setState(() {
      _isLoading = true;
      _uploadResult = 'Preparing upload...';
    });

    try {
      // For testing purposes only - create a temporary test file
      final tempDir = await Directory.systemTemp.createTemp('test_api_');
      final testFile = File('${tempDir.path}/test_file.txt');
      await testFile.writeAsString('This is a test file for upload testing');
      
      final result = await ApiTestExample.testFileUpload(testFile);
      setState(() {
        _uploadResult = 'Upload success! Response: ${result['files']}';
      });
      
      // Clean up
      await tempDir.delete(recursive: true);
    } catch (e) {
      setState(() {
        _uploadResult = 'Upload error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetApi,
              child: const Text('Test GET API'),
            ),
            const SizedBox(height: 16),
            Text(
              'GET Result:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(_getResult),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _testUploadApi,
              child: const Text('Test File Upload'),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload Result:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(_uploadResult),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
} 