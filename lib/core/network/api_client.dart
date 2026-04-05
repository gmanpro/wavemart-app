import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

/// Dio API Client with interceptors for authentication, logging, and error handling
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Android storage options for device compatibility
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: false,
    resetOnError: true,
  );

  ApiClient({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(aOptions: _androidOptions) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          ApiConstants.headerAccept: ApiConstants.contentTypeJson,
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
        validateStatus: (status) => status! < 500,
        followRedirects: false,
      ),
    );

    _addInterceptors();
  }

  /// Add interceptors for auth, logging, and error handling
  void _addInterceptors() {
    // Auth Interceptor - Add Bearer token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _secureStorage.read(key: 'auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers[ApiConstants.headerAuthorization] =
                  '${ApiConstants.headerBearer} $token';
            }
          } catch (e) {
            // Secure storage read failed - continue without token
            // This prevents blocking requests on device key issues
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired - clear storage
            _secureStorage.deleteAll().catchError((_) {});
          }
          return handler.next(error);
        },
      ),
    );

    // Logging Interceptor - Only in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (obj) {
            log('[API] $obj', name: 'WaveMart');
          },
        ),
      );
    }
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Update base URL (for environment switching)
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Store auth token
  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  /// Clear auth token
  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
