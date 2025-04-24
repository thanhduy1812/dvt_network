import 'dart:io';
import 'api_test_example.dart';

void main() async {
  print('Starting API tests...');
  print('======================');
  
  // Test GET API
  print('\n1. Testing GET API:');
  print('-----------------');
  try {
    final getResult = await ApiTestExample.testGetRequest();
    print('GET test completed successfully');
    print('Number of items received: ${getResult.length}');
    print('First item: ${getResult[0]}');
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
    
    // Upload the file
    final uploadResult = await ApiTestExample.testFileUpload(testFile);
    print('Upload test completed successfully');
    print('Response data: $uploadResult');
    
    // Clean up
    await tempDir.delete(recursive: true);
    print('Test file cleaned up');
  } catch (e) {
    print('Upload test failed: $e');
  }
  
  print('\nAPI tests completed.');
} 