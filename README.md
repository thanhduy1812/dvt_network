<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# VNLook Network Package

A Flutter package for simplified API communication using Dio HTTP client.

## Features

- Easy API request configuration
- Built-in environment management
- Support for various HTTP methods
- File upload capabilities
- Progress tracking
- Structured error handling

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  gtd_network: ^1.0.5
```

## Usage

### Basic Setup

1. Create an environment for your API:

```dart
final environment = BaseEnvironment(
  baseUrl: 'api.example.com',  // Base URL without protocol
  platformPath: 'api/v1',      // Path prefix for all endpoints
  headers: {                   // Default headers
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
);
```

2. Create an endpoint for your request:

```dart
final endpoint = GtdEndpoint(
  env: environment,
  path: 'users',  // This will be appended to the platformPath
);
```

3. Configure a network request:

```dart
final networkService = GtdNetworkService.shared;
networkService.request = GTDNetworkRequest(
  type: GtdMethod.get,       // HTTP method
  enpoint: endpoint,
  queryParams: {             // Optional query parameters
    'page': 1,
    'limit': 10,
  },
  data: {                    // Optional request body for POST/PUT
    'name': 'John Doe',
    'email': 'john@example.com',
  },
);
```

4. Execute the request:

```dart
try {
  final response = await networkService.execute();
  print('Status code: ${response.statusCode}');
  print('Response data: ${response.data}');
} on DioException catch (e) {
  print('Request failed: ${e.message}');
}
```

### Example: GET Request

```dart
// Create environment and endpoint
final environment = BaseEnvironment(
  baseUrl: 'jsonplaceholder.typicode.com',
  platformPath: '',
  headers: {'Accept': 'application/json'},
);
final endpoint = GtdEndpoint(env: environment, path: 'posts');

// Configure request
final networkService = GtdNetworkService.shared;
networkService.request = GTDNetworkRequest(
  type: GtdMethod.get,
  enpoint: endpoint,
  queryParams: {'userId': 1},
);

// Execute
try {
  final response = await networkService.execute();
  print('GET request successful: ${response.statusCode}');
  print('Data: ${response.data}');
} catch (e) {
  final gtdError = e as GtdError;
  print('GET request failed: ${gtdError.message}');
}
```

### Example: GET Request with Path Parameters

```dart
// Create environment and endpoint
final environment = BaseEnvironment(
  baseUrl: 'jsonplaceholder.typicode.com',
  platformPath: '',
  headers: {'Accept': 'application/json'},
);

// Getting a specific post by ID
final postId = 1;
final endpoint = GtdEndpoint(env: environment, path: 'posts/$postId');

// Configure request
final networkService = GtdNetworkService.shared;
networkService.request = GTDNetworkRequest(
  type: GtdMethod.get,
  enpoint: endpoint,
);

// Execute
try {
  final response = await networkService.execute();
  print('GET request successful: ${response.statusCode}');
  print('Post data: ${response.data}');
  // Access specific fields
  print('Title: ${response.data['title']}');
  print('Body: ${response.data['body']}');
} catch (e) {
  final gtdError = e as GtdError;
  print('GET request failed: ${gtdError.message}');
}
```

### Example: File Upload

```dart
// Create a file to upload
final file = File('path/to/your/file.jpg');

// Configure environment and endpoint
final environment = BaseEnvironment(
  baseUrl: 'api.example.com',
  platformPath: 'api/v1',
  headers: {'Accept': 'application/json'},
);
final endpoint = GtdEndpoint(env: environment, path: 'upload');

// Configure request
final networkService = GtdNetworkService.shared;
networkService.request = GTDNetworkRequest(
  type: GtdMethod.post,
  enpoint: endpoint,
  data: {'description': 'Profile picture'},
);

// Upload file
try {
  final response = await networkService.uploadFile(
    file: file,
    fieldName: 'image',
    onSendProgress: (int sent, int total) {
      final progress = (sent / total * 100).toStringAsFixed(2);
      print('Upload progress: $progress%');
    },
  );
  print('Upload successful: ${response.statusCode}');
  print('Response: ${response.data}');
} catch (e) {
  final gtdError = e as GtdError;
  print('Upload failed: ${gtdError.message}');
}
```

## Advanced Usage

### Authentication

```dart
// Add authentication token to all requests
environment.headers['Authorization'] = 'Bearer YOUR_TOKEN_HERE';
```

### Customizing Timeout

```dart
// Customize timeout settings
networkService.connectTimeout = const Duration(seconds: 10);
networkService.receiveTimeout = const Duration(seconds: 30);
```

### Using a Mock API for Testing

```dart
final testEnvironment = BaseEnvironment(
  baseUrl: 'localhost:8080',  // Point to your mock server
  platformPath: 'mock/api',
  headers: {'Accept': 'application/json'},
);
```

### Standardized Error Handling

The package provides a standardized way to handle errors with the `GtdError` class. All network service methods will only throw `GtdError` exceptions, making error handling consistent across the application:

```dart
try {
  final response = await networkService.execute();
  return response.data;
} catch (e) {
  // All exceptions from networkService are GtdError
  final gtdError = e as GtdError;
  
  // You can access additional properties
  print('Status code: ${gtdError.statusCode}');
  print('Error message: ${gtdError.message}');
  print('Stack trace: ${gtdError.stackTrace}');
  
  // You can check for specific errors
  if (gtdError.statusCode == 401) {
    // Handle authentication errors
  } else if (gtdError.errorCode == 'NETWORK_ERROR') {
    // Handle network connectivity issues
  }
  
  // Rethrow or handle the error
  throw gtdError;
}
```

#### Error Properties

The `GtdError` class provides these properties:

- `message`: Human-readable error message
- `statusCode`: HTTP status code if available
- `errorCode`: Custom error code for categorization
- `originalError`: Original error that caused this exception, which can be another GtdError
- `stackTrace`: Full stack trace for debugging

#### Error Factory Methods

```dart
// Create from DioException (used internally)
final error1 = GtdError.fromDioError(dioException);

// Create from any exception
final error2 = GtdError.fromException(exception, stackTrace);

// Create with custom message
final error3 = GtdError.custom(
  'Custom error message',
  statusCode: 400,
  errorCode: 'VALIDATION_FAILED',
);

// Create from another GtdError
final error4 = GtdError.fromError(
  existingError,
  message: 'More specific error message',
  errorCode: 'SPECIFIC_ERROR_CODE',
);
```

#### Getting the Root Error

You can use the `getOriginalErrorSource()` method to get the root cause of errors:

```dart
final rootCause = gtdError.getOriginalErrorSource();
print('Root cause: $rootCause');
```

#### Detailed Logging

For debugging, you can get a detailed error report:

```dart
final error = GtdError.fromDioError(dioException);
print(error.toDetailedString());
```

This will output:
```
GtdError: Resource not found (404) [code: 404]
Original error: DioException [...]
Stack trace:
#0 ...
```

### Creating Resource Modules

You can organize your API calls into dedicated resource modules following this structure:

```
user_resource/
├── api/
│   └── user_resource_api.dart
├── models/
│   ├── request/
│   │   └── gtd_user_profile_rq.dart
│   └── response/
│       ├── gtd_user_detail_rs.dart
│       └── gtd_user_list_rs.dart
├── gtd_user_endpoint.dart
└── user_resource.dart
```

1. Create endpoints in a dedicated class:

```dart
// gtd_user_endpoint.dart
class GtdUserEndpoint extends GtdEndpoint {
  GtdUserEndpoint({required super.env, required super.path});
  
  // Define API paths as constants
  static const String kGetUserDetail = '/api/users/profile';
  static const String kGetUserList = '/api/users/list';

  // Create factory methods for each endpoint
  static GtdEndpoint getUserDetail(GTDEnvType envType, String userId) {
    const path = kGetUserDetail;
    return GtdEndpoint(env: GtdEnvironment(env: envType), path: "$path/$userId");
  }

  static GtdEndpoint getUserList(GTDEnvType envType) {
    const path = kGetUserList;
    return GtdEndpoint(env: GtdEnvironment(env: envType), path: path);
  }
}
```

2. Create request/response models:

```dart
// models/request/gtd_user_profile_rq.dart
class GtdUserProfileRq {
  String userId;
  bool includeSettings;
  bool includePreferences;
  
  // Constructor, toMap(), fromMap(), etc.
  
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'includeSettings': includeSettings,
      // Other properties...
    };
  }
}
```

3. Implement the API client:

```dart
// api/user_resource_api.dart
class UserResourceApi {
  GtdNetworkService networkService = GtdNetworkService.shared;
  GTDEnvType envType = AppConst.shared.envType;

  UserResourceApi._();
  static final shared = UserResourceApi._();

  Future<GtdUserDetail> getUserDetailById(String userId) async {
    try {
      final networkRequest = GTDNetworkRequest(
          type: GtdMethod.get, 
          enpoint: GtdUserEndpoint.getUserDetail(envType, userId)
      );
      networkService.request = networkRequest;
      final response = await networkService.execute();
      GtdUserDetailRs userDetailRs = JsonParser.jsonToModel(
        GtdUserDetailRs.fromJson, 
        response.data
      );
      
      if ((userDetailRs.errors ?? []).isNotEmpty) {
        throw GtdApiError.fromErrorConstant(GtdErrorConstant.unknown);
      }
      return userDetailRs.result ?? GtdUserDetail();
    } catch (e) {
      // All errors from networkService are GtdError
      throw e;
    }
  }
  
  // Other API methods...
}
```

4. Create an export file:

```dart
// user_resource.dart
export 'api/user_resource_api.dart';
export 'gtd_user_endpoint.dart';
export 'models/response/gtd_user_detail_rs.dart';
```

### Example: Using a Resource Module

```dart
// Import the resource module
import 'package:your_package/network/user_resource/user_resource.dart';

// Usage in your application
Future<void> fetchUserDetails() async {
  try {
    // Use the API client
    final userApi = UserResourceApi.shared;
    final userId = "user123";
    
    // Call the API method
    final userDetail = await userApi.getUserDetailById(userId);
    
    // Process the results
    print('User name: ${userDetail.fullName}');
    print('Email: ${userDetail.email}');
    // Process other properties...
  } catch (e) {
    print('Error fetching user details: $e');
  }
}

// Example with request model
Future<void> searchUsers() async {
  try {
    // Create the request model
    final request = GtdUserSearchRq(
      searchTerm: "john",
      pageSize: 20,
      pageNumber: 1,
      includeSuspended: false,
    );
    
    // Call the API with the request model
    final userApi = UserResourceApi.shared;
    final users = await userApi.searchUsers(request);
    
    // Process the results
    print('Found ${users.length} users');
    for (var user in users) {
      print('User: ${user.fullName} - ${user.email}');
    }
  } catch (e) {
    print('Error searching users: $e');
  }
}
```

## Complete Example

For a complete working example including both GET requests and file uploads, see the examples in the test directory:

- `test/api_test_example.dart` - Main example class with implementation
- `test/run_api_test.dart` - Runner for the API example
- `test/run_api_test_simple.dart` - Simple direct implementation using Dio

## License

This project is licensed under the MIT License.