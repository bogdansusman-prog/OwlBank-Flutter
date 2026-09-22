import 'package:dio/dio.dart';

import '../models/statement.dart';
import 'api_client.dart';

/// Talks to `/api/users/statement`. Mirrors Angular's `StatementService`
/// in `services/statement.ts`.
class StatementService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<StatementResponse>> getStatement(
    String startDate,
    String endDate,
  ) async {
    final response = await _dio.get(
      '/users/statement',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map((e) => StatementResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
