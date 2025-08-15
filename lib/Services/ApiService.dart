
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_ease/controller/userManagment/JWTController.dart';
import 'package:tour_ease/model/userManagment/user.dart';



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
}

class APIServiceNodeJS extends APIService {
  final Dio _dio = Dio();

  APIServiceNodeJS(super.baseUrl, super.authToken) {
    _dio.options.baseUrl = baseUrl;

    // --- SET YOUR APP-WIDE DEFAULT HEADERS HERE ---
    _dio.options.headers['Content-Type'] = 'application/json; charset=UTF-8';

    if (authToken != null) {
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
      print(response.toString());

      if (response.statusCode == 200) {
        return fromJson(response.data["data"]);
      } else {
        print(response);

        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to execute GEasdfsdT request: ${e.message}');
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
        print(response);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to post data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to execute POST request: $e');
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
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to put data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to execute PUT request: $e');
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
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to delete resource: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to execute DELETE request: $e');
    }
  }
}

