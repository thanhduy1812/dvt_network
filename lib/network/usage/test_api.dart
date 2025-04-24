import 'dart:io';
import '../network_service/base_environment.dart';
import '../network_service/gtd_end_points.dart';
import '../network_service/gtd_network_request.dart';
import '../network_service/gtd_network_service.dart';
import '../network_service/gtd_error.dart';
import '../network_service/gtd_app_logger.dart';

/// Test class for demonstrating API functionality
class ApiTester {
  /// Test GET request to a public API
  static Future<void> testGetRequest() async {
    try {
      // Setup environment for JSONPlaceholder API (public test API)
      GtdLogger.i('Setting up GET request environment...');
      final environment = BaseEnvironment(
        baseUrl: 'jsonplaceholder.typicode.com',
        platformPath: '',
        headers: {'Accept': 'application/json'},
      );
      
      // Create an endpoint for posts
      final endpoint = GtdEndpoint(env: environment, path: 'posts');
      
      // Configure request with query parameters
      final networkService = GtdNetworkService.shared;
      networkService.request = GTDNetworkRequest(
        type: GtdMethod.get,
        enpoint: endpoint,
        queryParams: {'userId': 1},
      );
      
      // Execute request
      GtdLogger.i('Executing GET request...');
      final response = await networkService.execute();
      
      // Process response
      GtdLogger.i('GET request successful: ${response.statusCode}');
      GtdLogger.i('Number of items: ${response.data.length}');
      GtdLogger.i('First item title: ${response.data[0]['title']}');
      
      return response.data;
    } catch (e) {
      // All errors from networkService are GtdError
      final gtdError = e as GtdError;
      GtdLogger.e('GET request failed: ${gtdError.message}');
      GtdLogger.e('Error code: ${gtdError.errorCode}');
      GtdLogger.e('Status code: ${gtdError.statusCode}');
      
      rethrow;
    }
  }
  
  /// Test file upload to httpbin.org (test service)
  static Future<void> testFileUpload() async {
    try {
      // Create a temporary file to upload
      GtdLogger.i('Creating temporary file for upload...');
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_upload.txt');
      await tempFile.writeAsString('This is a test file for upload.');
      GtdLogger.i('Temporary file created at: ${tempFile.path}');
      
      // Setup environment for httpbin.org (public test API)
      final environment = BaseEnvironment(
        baseUrl: 'httpbin.org',
        platformPath: '',
        headers: {'Accept': 'application/json'},
      );
      
      // Create endpoint for file upload
      final endpoint = GtdEndpoint(env: environment, path: 'post');
      
      // Configure request
      final networkService = GtdNetworkService.shared;
      networkService.request = GTDNetworkRequest(
        type: GtdMethod.post,
        enpoint: endpoint,
        data: {'description': 'Test file upload'},
      );
      
      // Upload file with progress tracking
      GtdLogger.i('Starting file upload...');
      final response = await networkService.uploadFile(
        file: tempFile,
        fieldName: 'file',
        onSendProgress: (int sent, int total) {
          final progress = (sent / total * 100).toStringAsFixed(2);
          GtdLogger.i('Upload progress: $progress%');
        },
      );
      
      // Process response
      GtdLogger.i('Upload successful: ${response.statusCode}');
      GtdLogger.i('Response contains form data: ${response.data.containsKey('form')}');
      GtdLogger.i('Response contains files: ${response.data.containsKey('files')}');
      
      // Clean up the temporary file
      await tempFile.delete();
      GtdLogger.i('Temporary file deleted');
      
      return response.data;
    } catch (e) {
      // All errors from networkService are GtdError
      final gtdError = e as GtdError;
      GtdLogger.e('File upload failed: ${gtdError.message}');
      GtdLogger.e('Error code: ${gtdError.errorCode}');
      GtdLogger.e('Status code: ${gtdError.statusCode}');
      
      rethrow;
    }
  }
  
  /// Run all tests
  static Future<void> runAllTests() async {
    GtdLogger.i('=== Starting API Tests ===');
    
    try {
      GtdLogger.i('--- Testing GET Request ---');
      await testGetRequest();
      
      GtdLogger.i('--- Testing File Upload ---');
      await testFileUpload();
      
      GtdLogger.i('=== All Tests Completed Successfully ===');
    } catch (e) {
      GtdLogger.e('=== Test Failed: $e ===');
    }
  }
}

/// Main function to run the tests
Future<void> main() async {
  GtdLogger.i('Starting API test execution');
  await ApiTester.runAllTests();
} 