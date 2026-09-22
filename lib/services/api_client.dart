import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Base URL for the OwlBank backend, reached through the local proxy
/// server (proxy-server.js) that adds CORS headers. Mirrors the Angular
/// app's `src/proxy.conf.json`, which forwards `/api/**` to the same
/// backend during development.
const String kApiBaseUrl = 'http://localhost:8081';

/// Shared secure storage instance for the auth token, used across all
/// services so there is a single source of truth for the session.
const FlutterSecureStorage kSecureStorage = FlutterSecureStorage();

/// A single Dio instance shared by every service, with an interceptor
/// that automatically attaches the `Authorization: Bearer <token>`
/// header to every outgoing request when a token is stored.
///
/// This mirrors Angular's `auth.interceptor.ts`, which reads the token
/// from `localStorage` and clones each request with the header set.
class ApiClient {
  ApiClient._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await kSecureStorage.read(key: 'token');

          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }

          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
    ),
  );

  Dio get dio => _dio;
}
