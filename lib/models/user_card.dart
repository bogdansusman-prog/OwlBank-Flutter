/// A summary of one of the user's cards, as embedded inside
/// [UserDetails]. Mirrors Angular's `UserCard` interface in
/// `services/user.ts`.
class UserCard {
  final String firstName;
  final String lastName;
  final String lastFourDigitsCardNumber;
  final String cardId;
  final bool isBlocked;

  const UserCard({
    required this.firstName,
    required this.lastName,
    required this.lastFourDigitsCardNumber,
    required this.cardId,
    required this.isBlocked,
  });

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      lastFourDigitsCardNumber:
          json['lastFourDigitsCardNumber']?.toString() ?? '',
      cardId: json['cardId']?.toString() ?? '',
      isBlocked: json['isBlocked'] == true,
    );
  }
}
