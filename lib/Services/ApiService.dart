
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
        String errorMessage = 'Failed to load data: ${response.statusCode}';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Extract error message from API response if available
      String errorMessage = 'Failed to execute GET request';
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          errorMessage = data['message'];
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
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
        String errorMessage = 'Failed to post data: ${response.statusCode}';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Extract error message from API response if available
      String errorMessage = 'Failed to execute POST request';
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          errorMessage = data['message'];
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
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
        String errorMessage = 'Failed to put data: ${response.statusCode}';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Extract error message from API response if available
      String errorMessage = 'Failed to execute PUT request';
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          errorMessage = data['message'];
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
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
        String errorMessage = 'Failed to delete resource: ${response.statusCode}';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Extract error message from API response if available
      String errorMessage = 'Failed to execute DELETE request';
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          errorMessage = data['message'];
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
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
        String errorMessage = 'Failed to upload file: ${response.statusCode}';
        if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          }
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Extract error message from API response if available
      String errorMessage = 'Failed to execute multipart POST request';
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          errorMessage = data['message'];
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    }
  }
}

