import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8081',
    ),
  );

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

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

      await _storage.write(
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

  Future<String?> getToken() async {
    return await _storage.read(
      key: 'token',
    );
  }

  Future<void> logout() async {
    await _storage.delete(
      key: 'token',
    );
  }
}