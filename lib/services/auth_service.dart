import 'package:dio/dio.dart';

import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        queryParameters: {
          'Email': email,
          'Password': password,
        },
        options: Options(
          responseType: ResponseType.plain,
        ),
      );

      final token = response.data.toString().trim();

      if (token.isEmpty) {
        return false;
      }

      await kSecureStorage.write(
        key: 'token',
        value: token,
      );

      return true;
    } on DioException catch (e) {
      print('LOGIN ERROR');
      print('Status: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      print('Message: ${e.message}');

      rethrow;
    }
  }

  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String dateOfBirth,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        queryParameters: {
          'Password': password,
          'ConfirmPassword': confirmPassword,
          'Email': email,
          'FirstName': firstName,
          'LastName': lastName,
          'PhoneNumber': phoneNumber,
          'DateOfBirth': dateOfBirth,
        },
        options: Options(
          responseType: ResponseType.plain,
        ),
      );

      return response.data?.toString() ?? '';
    } on DioException catch (e) {
      print('REGISTER ERROR');
      print('Status: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      print('Message: ${e.message}');

      rethrow;
    }
  }

  /// Resets the password for an account the user is *not* currently
  /// signed into (they supply their current password by hand). Mirrors
  /// Angular's `AuthService.resetPassword()`, used by the standalone
  /// "Reset password" screen reachable from the login page.
  Future<String> resetPassword({
    required String email,
    required String password,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _dio.patch(
      '/resetpassword',
      queryParameters: {
        'email': email,
        'password': password,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    return response.data?.toString() ?? '';
  }

  Future<String?> getToken() async {
    return await kSecureStorage.read(
      key: 'token',
    );
  }

  Future<void> logout() async {
    await kSecureStorage.delete(
      key: 'token',
    );
  }
}
