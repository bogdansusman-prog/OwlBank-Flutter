import 'package:dio/dio.dart';

import '../models/card.dart';
import 'api_client.dart';

/// Talks to the `/api/users/*-cards` endpoints. Mirrors Angular's
/// `CardService` in `services/card.ts`. The Authorization header is
/// attached automatically by [ApiClient]'s interceptor.
class CardService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<CardResponse>> getAllCards() async {
    final response = await _dio.get('/users/get-all-cards');

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map((e) => CardResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> addCard() async {
    final response = await _dio.post(
      '/users/add-cards',
      options: Options(responseType: ResponseType.plain),
    );

    return response.data?.toString() ?? '';
  }

  Future<String> deleteCard(String cardId) async {
    final response = await _dio.post(
      '/users/delete-cards',
      queryParameters: {'cardId': cardId},
      options: Options(responseType: ResponseType.plain),
    );

    return response.data?.toString() ?? '';
  }

  Future<void> blockCard(String cardId) async {
    await _dio.patch('/users/blocked-cards/$cardId');
  }

  Future<void> activateCard(String cardId) async {
    await _dio.patch('/users/activate-cards/$cardId');
  }
}
