import 'package:dio/dio.dart';
import '../network_service/gtd_end_points.dart';
import '../network_service/gtd_network_request.dart';
import '../network_service/gtd_network_service.dart';
import '../network_service/base_environment.dart';
import '../network_service/gtd_error.dart';

/// Example service showing how to use the GtdError for error handling
class ExampleApiService {
  final GtdNetworkService networkService = GtdNetworkService.shared;
  
  ExampleApiService._();
  static final shared = ExampleApiService._();
  
  /// Example of GET request with proper error handling
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      // Setup environment and endpoint
      final environment = BaseEnvironment(
        baseUrl: 'api.example.com',
        platformPath: 'api/v1',
        headers: {'Accept': 'application/json'},
      );
      final endpoint = GtdEndpoint(env: environment, path: 'users/$userId');
      
      // Configure request
      final networkRequest = GTDNetworkRequest(
        type: GtdMethod.get,
        enpoint: endpoint,
      );
      networkService.request = networkRequest;
      
      // Execute request
      final response = await networkService.execute();
      return response.data;
    } on DioException catch (e) {
      // Transform DioException to our standardized GtdError
      final gtdError = GtdError.fromDioError(e);
      
      // Log the detailed error for developers
      _logError(gtdError);
      
      // You can handle specific error codes here
      if (gtdError.statusCode == 401) {
        // Handle authentication error
        // e.g., refresh token or redirect to login
      }
      
      // Rethrow as our standardized error
      throw gtdError;
    } catch (e, stackTrace) {
      // Handle other exceptions
      final gtdError = GtdError.fromException(e, stackTrace);
      _logError(gtdError);
      throw gtdError;
    }
  }
  
  /// Example of POST request with error handling
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final environment = BaseEnvironment(
        baseUrl: 'api.example.com',
        platformPath: 'api/v1',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      final endpoint = GtdEndpoint(env: environment, path: 'users');
      
      final networkRequest = GTDNetworkRequest(
        type: GtdMethod.post,
        enpoint: endpoint,
        data: userData,
      );
      networkService.request = networkRequest;
      
      final response = await networkService.execute();
      return response.data;
    } on DioException catch (e) {
      final gtdError = GtdError.fromDioError(e);
      
      // Example of custom error handling based on status code
      if (gtdError.statusCode == 422) {
        // Handle validation errors
        final validationErrors = _extractValidationErrors(e.response?.data);
        throw GtdError.custom(
          'Validation failed',
          statusCode: gtdError.statusCode,
          errorCode: 'VALIDATION_ERROR',
        );
      }
      
      _logError(gtdError);
      throw gtdError;
    } catch (e, stackTrace) {
      final gtdError = GtdError.fromException(e, stackTrace);
      _logError(gtdError);
      throw gtdError;
    }
  }
  
  /// Helper method to log errors
  void _logError(GtdError error) {
    // In a real app, use a proper logging system
    print('ERROR: ${error.toDetailedString()}');
  }
  
  /// Helper method to extract validation errors from response
  Map<String, List<String>> _extractValidationErrors(dynamic data) {
    final result = <String, List<String>>{};
    
    if (data is Map && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map) {
        errors.forEach((key, value) {
          if (value is List) {
            result[key] = List<String>.from(value.map((e) => e.toString()));
          } else {
            result[key] = [value.toString()];
          }
        });
      }
    }
    
    return result;
  }
}

/// Example of how to use the API service with error handling
void exampleUsage() async {
  final apiService = ExampleApiService.shared;
  
  try {
    // Fetch user profile
    final userProfile = await apiService.fetchUserProfile('user123');
    print('User profile: $userProfile');
    
    // Create a new user
    final newUser = await apiService.createUser({
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': 'securepassword',
    });
    print('New user created: $newUser');
  } on GtdError catch (error) {
    // Handle specific error codes
    if (error.statusCode == 401) {
      print('Authentication required. Please login again.');
    } else if (error.errorCode == 'VALIDATION_ERROR') {
      print('Please fix the following errors:');
      print('Validation failed');
    } else {
      // Generic error handling
      print('Error: ${error.message}');
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
} 