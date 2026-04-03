import 'package:dio/dio.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() => 'ApiException: $message (Code: $code, Status: $statusCode)';
}

/// Network exception
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Unauthorized exception (401)
class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([this.message = 'Session expired']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Server error exception (5xx)
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}

/// Parse Dio exceptions into custom exceptions
class ApiErrorHandler {
  static Exception handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException('Connection timeout');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = _extractErrorMessage(error.response?.data);

          if (statusCode == 401) {
            return const UnauthorizedException();
          }

          if (statusCode != null && statusCode >= 500) {
            return const ServerException();
          }

          return ApiException(
            message: message ?? 'Request failed',
            statusCode: statusCode,
          );

        case DioExceptionType.cancel:
          return const ApiException(message: 'Request cancelled');

        case DioExceptionType.connectionError:
          return const NetworkException('No internet connection');

        default:
          return ApiException(message: error.message ?? 'Unknown error occurred');
      }
    }

    return ApiException(message: error.toString());
  }

  /// Extract error message from response data
  static String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Try common error message keys
      return data['message'] ??
          data['error'] ??
          data['errors']?.toString() ??
          data['detail']?.toString();
    }

    return data?.toString();
  }
}
