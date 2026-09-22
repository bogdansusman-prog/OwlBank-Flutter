import 'package:dio/dio.dart';

import '../models/transaction_response.dart';
import 'api_client.dart';

/// Talks to `/api/users/transactions`. Mirrors Angular's
/// `TransactionService` in `services/transaction.ts`.
class TransactionService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<TransactionResponse>> getTransactions() async {
    final response = await _dio.get('/users/transactions');

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map((e) => TransactionResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
