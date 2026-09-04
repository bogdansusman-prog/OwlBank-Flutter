enum HomeTransactionType {
  deposit,
  withdrawal,
  transfer,
}

class HomeTransaction {
  final String id;
  final HomeTransactionType type;
  final String description;
  final double amount;
  final String date;

  const HomeTransaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
  });
}