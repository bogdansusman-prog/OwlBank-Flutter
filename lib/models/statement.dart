/// One statement line, as returned by `GET /api/users/statement`.
/// Mirrors Angular's `StatementResponse` interface in
/// `services/statement.ts`.
class StatementResponse {
  final String id;
  final String userId;
  final String timeStamp;
  final double? receivedAmount;
  final double? spentAmount;
  final String description;
  final double transferAmount;

  /// 0 = deposit, 2 = withdrawal, anything else = transfer. Mirrors the
  /// numeric mapping in Angular's `Statements.mapTransaction()`.
  final int type;

  const StatementResponse({
    required this.id,
    required this.userId,
    required this.timeStamp,
    required this.description,
    required this.transferAmount,
    required this.type,
    this.receivedAmount,
    this.spentAmount,
  });

  factory StatementResponse.fromJson(Map<String, dynamic> json) {
    return StatementResponse(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      timeStamp: json['timeStamp']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      transferAmount: (json['transferAmount'] as num?)?.toDouble() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 1,
      receivedAmount: (json['receivedAmount'] as num?)?.toDouble(),
      spentAmount: (json['spentAmount'] as num?)?.toDouble(),
    );
  }
}

enum StatementTransactionType { deposit, withdrawal, transfer }

/// The flattened, display-ready shape the Statements screen renders,
/// derived from [StatementResponse]. Mirrors Angular's internal
/// `StatementTransaction` interface in `statements.ts`.
class StatementTransaction {
  final String id;
  final String date;
  final String description;
  final StatementTransactionType type;
  final double amount;

  const StatementTransaction({
    required this.id,
    required this.date,
    required this.description,
    required this.type,
    required this.amount,
  });

  factory StatementTransaction.fromResponse(StatementResponse item) {
    final StatementTransactionType type;

    if (item.type == 0) {
      type = StatementTransactionType.deposit;
    } else if (item.type == 2) {
      type = StatementTransactionType.withdrawal;
    } else {
      type = StatementTransactionType.transfer;
    }

    double amount;

    if (item.receivedAmount != null && item.receivedAmount != 0) {
      amount = item.receivedAmount!.abs();
    } else if (item.spentAmount != null && item.spentAmount != 0) {
      amount = -item.spentAmount!.abs();
    } else {
      amount = item.transferAmount;
    }

    return StatementTransaction(
      id: item.id,
      date: item.timeStamp,
      description: item.description,
      type: type,
      amount: amount,
    );
  }
}
