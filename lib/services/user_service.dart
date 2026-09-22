import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/user_details.dart';
import 'api_client.dart';

class UserService {
  final Dio _dio = ApiClient.instance.dio;

  Future<double> getBalance() async {
    debugPrint('BALANCE REQUEST');

    try {
      final response = await _dio.get(
        '/users/balance',
        options: Options(
          responseType: ResponseType.plain,
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

  /// Fetches the signed-in user's profile, cards and balance in one
  /// call. Mirrors Angular's `UserService.getUserDetails()`.
  Future<UserDetails> getUserDetails() async {
    final response = await _dio.get('/users/user-details');

    return UserDetails.fromJson(response.data as Map<String, dynamic>);
  }

  /// Patches one or more of the user's editable fields (email,
  /// firstName, lastName, phoneNumber). Mirrors Angular's
  /// `UserService.updateUserDetails()`.
  Future<String> updateUserDetails({
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};

    if (email != null) body['email'] = email;
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;

    final response = await _dio.patch(
      '/users/user-details',
      data: body,
      options: Options(responseType: ResponseType.plain),
    );

    return response.data?.toString() ?? '';
  }

  /// Mirrors Angular's `UserService.resetPassword()` (a near-duplicate
  /// of `AuthService.resetPassword()` in the original codebase).
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
      options: Options(responseType: ResponseType.plain),
    );

    return response.data?.toString() ?? '';
  }

  Future<String> deposit(
    double amount,
    String description,
  ) async {
    final response = await _dio.post(
      '/users/deposit',
      queryParameters: {
        'Amount': amount,
        'Description': description,
      },
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    return response.data?.toString() ?? '';
  }

  Future<String> withdraw(
    double amount,
    String description,
  ) async {
    final response = await _dio.post(
      '/users/withdraw',
      queryParameters: {
        'Amount': amount,
        'Description': description,
      },
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    return response.data?.toString() ?? '';
  }

  Future<String> transferMoney(
    String phoneNumber,
    double amount,
  ) async {
    final encodedPhone =
        Uri.encodeComponent(phoneNumber.trim());

    final response = await _dio.post(
      '/users/transfer/$encodedPhone',
      queryParameters: {
        'amount': amount,
      },
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    return response.data?.toString() ?? '';
  }
}
