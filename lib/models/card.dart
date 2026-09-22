/// A full card record, as returned by `GET /api/users/get-all-cards`.
/// Mirrors Angular's `CardResponse` interface in `services/card.ts`.
class CardResponse {
  final String id;
  final String firstName;
  final String lastName;

  /// Formatted as `MM/YY` once processed through
  /// [AccountScreen formatting]; the raw ISO value comes from the API.
  String expirationDate;

  final String cvv;

  /// Formatted with a space every 4 digits once processed; the raw
  /// digits-only value comes from the API.
  String cardNumber;

  final String userId;
  bool isBlocked;
  final bool isActive;

  CardResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.expirationDate,
    required this.cvv,
    required this.cardNumber,
    required this.userId,
    required this.isBlocked,
    required this.isActive,
  });

  factory CardResponse.fromJson(Map<String, dynamic> json) {
    return CardResponse(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      expirationDate: json['expirationDate']?.toString() ?? '',
      cvv: json['cvv']?.toString() ?? '',
      cardNumber: json['cardNumber']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      isBlocked: json['isBlocked'] == true,
      isActive: json['isActive'] == true,
    );
  }
}
