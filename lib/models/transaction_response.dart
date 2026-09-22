/// One transaction, as returned by `GET /api/users/transactions`.
/// Mirrors Angular's `Transaction` interface in `services/transaction.ts`.
///
/// This is the raw API shape used by [TransactionService]; the Home
/// screen's own display model (`HomeTransaction` in `models/transaction.dart`)
/// is derived from it.
class TransactionResponse {
  final String id;
  final double amount;
  final String description;
  final String type;
  final String date;

  const TransactionResponse({
    required this.id,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}
