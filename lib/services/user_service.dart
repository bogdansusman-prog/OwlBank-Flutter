import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8081',
    ),
  );

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<double> getBalance() async {
    final token = await _storage.read(
      key: 'token',
    );

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'No authentication token found.',
      );
    }

    final cleanToken = token.trim();

    debugPrint('BALANCE REQUEST');
    debugPrint('Token exists: true');
    debugPrint(
      'Token length: ${cleanToken.length}',
    );

    try {
      final response = await _dio.get(
        '/users/balance',
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Authorization': 'Bearer $cleanToken',
          },
        ),
      );

      debugPrint(
        'BALANCE STATUS: ${response.statusCode}',
      );

      debugPrint(
        'BALANCE RESPONSE: ${response.data}',
      );

      if (response.statusCode == 204 ||
          response.data == null ||
          response.data.toString().trim().isEmpty) {
        return 0.0;
      }

      final balanceText =
          response.data.toString().trim();

      return double.parse(balanceText);
    } on DioException catch (e) {
      debugPrint('BALANCE ERROR');
      debugPrint(
        'Status: ${e.response?.statusCode}',
      );
      debugPrint(
        'Response: ${e.response?.data}',
      );
      debugPrint(
        'Message: ${e.message}',
      );

      rethrow;
    }
  }
}