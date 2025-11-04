
import 'package:dio/dio.dart';



abstract class APIService {
  final String baseUrl;
  final String authToken;
  APIService(this.baseUrl, this.authToken, );

  Future<R> get<R>({
    required String path,
    required R Function(dynamic json) fromJson,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  });

  Future<R> post<R>({
    required String path,
    required dynamic body,
    required R Function(dynamic json) fromJson,
    Map<String, String>? headers,
  });

  Future<R> put<R>({
    required String path,
    required dynamic body,
    required R Function(dynamic json) fromJson,
    Map<String, String>? headers,
  });

  Future<R> delete<R>({
    required String path,
    required R Function(dynamic json) fromJson,
    dynamic body, // Added optional body for DELETE requests
    Map<String, String>? headers,
  });

  Future<R> postMultipart<R>({
    required String path,
    required FormData formData,
    required R Function(dynamic json) fromJson,
    Map<String, String>? headers,
  });
}

class APIServiceNodeJS extends APIService {
  final Dio _dio = Dio();

  APIServiceNodeJS(super.baseUrl, super.authToken) {
    _dio.options.baseUrl = baseUrl;

    _dio.options.headers['Content-Type'] = 'application/json; charset=UTF-8';

    if (authToken.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $authToken';
    }
    // ---------------------------------------------
  }

  Options _getOptions(Map<String, String>? customHeaders) {
    return Options(headers: {
      ..._dio.options.headers,
      ...?customHeaders,
    });
  }

  /// Extract detailed error message from DioException
  String _extractErrorMessage(DioException e, {String defaultMessage = 'Request failed'}) {
    // Priority 1: Check response data for backend error messages
    if (e.response?.data != null) {
      try {
        final data = e.response!.data;
        
        // Handle JSON response
        if (data is Map<String, dynamic>) {
          // Check for 'message' field (most common)
          if (data.containsKey('message') && data['message'] != null) {
            return data['message'].toString();
          }
          
          // Check for 'error' field
          if (data.containsKey('error') && data['error'] != null) {
            final error = data['error'];
            if (error is String) {
              return error;
            } else if (error is Map && error.containsKey('message')) {
              return error['message'].toString();
            }
          }
          
          // Check for 'errors' array (validation errors)
          if (data.containsKey('errors') && data['errors'] is List) {
            final errors = data['errors'] as List;
            if (errors.isNotEmpty) {
              if (errors.first is Map && errors.first.containsKey('msg')) {
                return errors.first['msg'].toString();
              }
              return errors.first.toString();
            }
          }
          
          // Check for 'detail' field
          if (data.containsKey('detail')) {
            return data['detail'].toString();
          }
        }
        
        // Handle string response
        if (data is String && data.isNotEmpty) {
          return data;
        }
      } catch (_) {
        // Continue to fallback options
      }
    }
    
    // Priority 2: Check HTTP status code
    if (e.response?.statusCode != null) {
      final statusCode = e.response!.statusCode!;
      switch (statusCode) {
        case 400:
          return 'Bad Request: ${e.response?.statusMessage ?? defaultMessage}';
        case 401:
          return 'Unauthorized: Please login again';
        case 403:
          return 'Forbidden: You don\'t have permission to access this resource';
        case 404:
          return 'Not Found: The requested resource was not found';
        case 409:
          return 'Conflict: ${e.response?.statusMessage ?? 'Resource already exists'}';
        case 422:
          return 'Validation Error: ${e.response?.statusMessage ?? 'Invalid input data'}';
        case 429:
          return 'Too Many Requests: Please try again later';
        case 500:
          return 'Server Error: Something went wrong on the server';
        case 502:
          return 'Bad Gateway: Server is temporarily unavailable';
        case 503:
          return 'Service Unavailable: Server is under maintenance';
        default:
          return 'HTTP $statusCode: ${e.response?.statusMessage ?? defaultMessage}';
      }
    }
    
    // Priority 3: Check DioException type
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout: Please check your internet connection';
      case DioExceptionType.sendTimeout:
        return 'Send timeout: Request took too long to send';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout: Server took too long to respond';
      case DioExceptionType.badCertificate:
        return 'Security Error: Invalid SSL certificate';
      case DioExceptionType.connectionError:
        return 'Connection Error: Unable to connect to server';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        break;
    }
    
    // Priority 4: Use Dio's error message
    if (e.message != null && e.message!.isNotEmpty) {
      return e.message!;
    }
    
    // Fallback
    return defaultMessage;
  }

  @override
  Future<R> get<R>({
    required String path,
    required R Function(dynamic json) fromJson,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.request(
        path,
        queryParameters: queryParams,
        options: _getOptions(headers).copyWith(
        method: "GET")
      );

      if (response.statusCode == 200) {
        return fromJson(response.data["data"]);
      } else {
        // Extract error message from API response
        String errorMessage = 'Failed to load data';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (data.containsKey('error')) {
            errorMessage = data['error'].toString();
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e, defaultMessage: 'Failed to fetch data');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<R> post<R>({
    required String path,
    required dynamic body,
    required R Function(dynamic json) fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
        options: _getOptions(headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return fromJson(response.data);
      } else {
        // Extract error message from API response
        String errorMessage = 'Failed to post data';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (data.containsKey('error')) {
            errorMessage = data['error'].toString();
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e, defaultMessage: 'Failed to send data');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<R> put<R>({
    required String path,
    required dynamic body,
    required R Function(dynamic json) fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: body,
        options: _getOptions(headers),
      );

      if (response.statusCode == 200) {
        return fromJson(response.data);
      } else {
        // Extract error message from API response
        String errorMessage = 'Failed to update data';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (data.containsKey('error')) {
            errorMessage = data['error'].toString();
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e, defaultMessage: 'Failed to update data');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<R> delete<R>({
    required String path,
    required R Function(dynamic json) fromJson,
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: body, // Pass the optional body to Dio
        options: _getOptions(headers),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.data != null && response.data.toString().isNotEmpty) {
          return fromJson(response.data);
        }
        return fromJson(null);
      } else {
        // Extract error message from API response
        String errorMessage = 'Failed to delete resource';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (data.containsKey('error')) {
            errorMessage = data['error'].toString();
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e, defaultMessage: 'Failed to delete resource');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<R> postMultipart<R>({
    required String path,
    required FormData formData,
    required R Function(dynamic json) fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: _getOptions(headers).copyWith(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return fromJson(response.data);
      } else {
        // Extract error message from API response
        String errorMessage = 'Failed to upload file';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (data.containsKey('error')) {
            errorMessage = data['error'].toString();
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e, defaultMessage: 'Failed to upload file');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}

