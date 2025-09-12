import 'package:dio/dio.dart';
import 'package:pavo_flutter/core/constants/app_constants.dart';
import 'package:pavo_flutter/core/logging/app_logger.dart';
import 'package:pavo_flutter/core/logging/log_mixin.dart';

abstract class BaseApiService with LogMixin {
  late final Dio dio;
  final String baseUrl;
  final String? apiKey;

  BaseApiService({
    required this.baseUrl,
    this.apiKey,
  }) {
    log.info('Initializing API service', data: {
      'baseUrl': baseUrl,
      'hasApiKey': apiKey != null,
    });
    
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: apiKey != null ? {'X-API-Key': apiKey} : {},
      ),
    );
    
    // Add custom logging interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        logApiCall(
          options.path,
          method: options.method,
          params: {
            'headers': options.headers.keys.toList(),
            'queryParams': options.queryParameters,
            if (options.data != null) 'hasBody': true,
          },
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        logApiResponse(
          response.requestOptions.path,
          statusCode: response.statusCode,
          data: response.data,
        );
        handler.next(response);
      },
      onError: (error, handler) {
        log.error(
          'API Error: ${error.requestOptions.path}',
          data: {
            'statusCode': error.response?.statusCode,
            'message': error.message,
            'type': error.type.toString(),
          },
          error: error,
        );
        handler.next(error);
      },
    ));
  }

  Future<T> handleRequest<T>(Future<Response> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${error.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error. Please check your connection.');
    }
  }
}