import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  late final AppLogger _logger;
  final String baseUrl;
  final Map<String, String>? defaultHeaders;

  ApiClient({
    required this.baseUrl,
    this.defaultHeaders,
    AppLogger? appLogger,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    _logger = appLogger ?? logger.forService('ApiClient');
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        headers: defaultHeaders ?? {},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.debug('Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.debug('Response: ${response.statusCode} ${response.realUri}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.error('Error: ${error.message}', error: error.error);
          handler.next(error);
        },
      ),
    );
  }

  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  T _handleResponse<T>(Response response) {
    if (response.statusCode == null) {
      throw NetworkException(message: 'No response from server');
    }

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data as T;
    }

    switch (response.statusCode) {
      case 401:
        throw AuthenticationException(
          message: response.data?['message'] ?? 'Authentication failed',
        );
      case 404:
        throw NotFoundException(
          message: response.data?['message'] ?? 'Resource not found',
        );
      case 400:
        throw ValidationException(
          message: response.data?['message'] ?? 'Invalid request',
        );
      default:
        throw ServerException(
          message: response.data?['message'] ?? 'Server error',
          statusCode: response.statusCode,
        );
    }
  }

  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException(message: 'Connection timeout');
        case DioExceptionType.connectionError:
          return NetworkException(message: 'Connection error');
        case DioExceptionType.cancel:
          return ApiException(message: 'Request cancelled');
        default:
          if (error.response != null) {
            return _handleResponse(error.response!);
          }
          return ApiException(
            message: error.message ?? 'Unknown error occurred',
            originalError: error,
          );
      }
    }
    return ApiException(
      message: 'Unexpected error occurred',
      originalError: error,
    );
  }
}