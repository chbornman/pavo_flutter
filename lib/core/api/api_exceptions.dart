class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException({String? message})
      : super(message: message ?? 'Network connection error');
}

class AuthenticationException extends ApiException {
  AuthenticationException({String? message})
      : super(
          message: message ?? 'Authentication failed',
          statusCode: 401,
        );
}

class ServerException extends ApiException {
  ServerException({String? message, int? statusCode})
      : super(
          message: message ?? 'Server error occurred',
          statusCode: statusCode ?? 500,
        );
}

class ValidationException extends ApiException {
  ValidationException({String? message})
      : super(
          message: message ?? 'Validation error',
          statusCode: 400,
        );
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
          message: message ?? 'Resource not found',
          statusCode: 404,
        );
}