# VNLook Network Package: Best Practices

This document outlines the recommended practices and structure for working with the VNL Network package.

## Directory Structure

Follow this structure when creating new API resource modules:

```
resource_name/
├── api/
│   └── resource_name_api.dart
├── models/
│   ├── request/
│   │   └── model_request.dart
│   └── response/
│       └── model_response.dart
├── resource_name_endpoint.dart
└── resource_name.dart (exports)
```

## Naming Conventions

- **Endpoints**: `GtdResourceNameEndpoint`
- **API Classes**: `ResourceNameApi`
- **Request Models**: `GtdModelNameRq`
- **Response Models**: `GtdModelNameRs`
- **API Path Constants**: Use `kResourceName` format

## Code Structure Guidelines

### 1. Endpoint Class

- Create a class that extends `GtdEndpoint`
- Define API paths as constants
- Create static factory methods for each endpoint
- Include parameters in the path when needed

```dart
class GtdUserEndpoint extends GtdEndpoint {
  GtdUserEndpoint({required super.env, required super.path});
  
  static const String kGetUserProfile = '/api/users/profile';
  static const String kGetUserById = '/api/users';
  
  static GtdEndpoint getUserProfile(GTDEnvType envType) {
    return GtdEndpoint(env: GtdEnvironment(env: envType), path: kGetUserProfile);
  }
  
  static GtdEndpoint getUserById(GTDEnvType envType, String userId) {
    return GtdEndpoint(env: GtdEnvironment(env: envType), path: "$kGetUserById/$userId");
  }
}
```

### 2. Request and Response Models

- Create properly typed request models with `toMap()` method
- Create response models with `fromJson()` factory method
- Include proper null handling
- Make immutable models when possible

```dart
class GtdUserProfileRq {
  final String userId;
  final bool includeDetails;
  
  GtdUserProfileRq({required this.userId, this.includeDetails = false});
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'includeDetails': includeDetails,
    };
  }
}
```

### 3. API Client

- Use a singleton pattern with private constructor
- Centralize error handling
- Return properly typed responses
- Document public methods

```dart
class UserApi {
  final GtdNetworkService networkService = GtdNetworkService.shared;
  final GTDEnvType envType = AppConst.shared.envType;

  UserApi._();
  static final shared = UserApi._();
  
  /// Fetches user profile information
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final networkRequest = GTDNetworkRequest(
        type: GtdMethod.get,
        enpoint: GtdUserEndpoint.getUserProfile(envType),
        queryParams: {'userId': userId},
      );
      networkService.request = networkRequest;
      final response = await networkService.execute();
      
      final profileResponse = UserProfileResponse.fromJson(response.data);
      return profileResponse.result;
    } catch (e) {
      // e is already a GtdError
      // Handle or rethrow as needed
      throw e;
    }
  }
}
```

### 4. Export File

- Export all necessary files for external use
- Don't export internal implementation details

```dart
// resource_name.dart
export 'api/resource_name_api.dart';
export 'resource_name_endpoint.dart';
export 'models/response/model_response.dart';
// Don't export internal models or utilities
```

## Error Handling

- Create custom error classes extending from a base error class
- Include proper error information (code, message)
- Handle both network and business logic errors
- Use consistent error handling across modules

### Using GtdError

Always use `GtdError` to standardize error handling across the application. The network service only throws `GtdError` exceptions, making error handling consistent:

```dart
try {
  // API call
} catch (e) {
  // e is already a GtdError
  // Handle or rethrow as needed
  throw e;
}
```

### Error Handling Patterns

#### 1. Basic Error Handling

```dart
Future<T> apiCall<T>() async {
  try {
    // API request using networkService
    return result;
  } catch (e) {
    final gtdError = e as GtdError;
    // Log error
    _logError(gtdError);
    throw gtdError;
  }
}
```

#### 2. Status Code Handling

Handle different status codes appropriately:

```dart
try {
  // API request using networkService
} catch (e) {
  final error = e as GtdError;
  
  // Handle specific status codes
  switch (error.statusCode) {
    case 401:
      // Handle unauthorized
      refreshToken();
      break;
    case 403:
      // Handle forbidden
      break;
    case 404:
      // Handle not found
      break;
    case >= 500:
      // Handle server errors
      break;
  }
  
  throw error;
}
```

#### 3. Error Handling in Repositories

In repositories, transform API errors into domain-specific errors:

```dart
try {
  return await apiService.fetchData();
} catch (e) {
  final error = e as GtdError;
  if (error.statusCode == 404) {
    throw ResourceNotFoundException('The resource was not found');
  } else if (error.statusCode == 401) {
    throw AuthenticationException('Not authenticated');
  }
  throw DomainException(error.message);
}
```

#### 4. Logging Errors

Always log detailed errors for debugging:

```dart
void logError(GtdError error) {
  // Use structured logging
  Logger.error(
    'API Error',
    extra: {
      'statusCode': error.statusCode,
      'errorCode': error.errorCode,
      'message': error.message,
    },
    stackTrace: error.stackTrace,
  );
}
```

### Business Logic Errors

Create custom errors for business logic:

```dart
// For validation errors
throw GtdError.custom(
  'Validation failed',
  statusCode: 422,
  errorCode: 'VALIDATION_ERROR',
);
```

## Testing

- Create mock endpoints for testing
- Test error scenarios
- Use Dio interceptors for mocking responses when needed

## Security Considerations

- Don't hardcode sensitive data in endpoints
- Don't log sensitive information
- Use HTTPS for all endpoints
- Add appropriate headers for authentication 