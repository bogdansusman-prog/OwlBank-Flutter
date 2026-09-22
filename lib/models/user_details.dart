import 'user_card.dart';

/// The signed-in user's profile, as returned by
/// `GET /api/users/user-details`. Mirrors Angular's `UserDetails`
/// interface in `services/user.ts`.
class UserDetails {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? dateOfBirth;
  final double balance;
  final List<UserCard> cards;

  const UserDetails({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.balance,
    required this.cards,
    this.dateOfBirth,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString(),
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      cards: (json['cards'] as List<dynamic>? ?? [])
          .map((e) => UserCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns a copy of this [UserDetails] with a single editable field
  /// (email, firstName, lastName or phoneNumber) replaced. Mirrors the
  /// optimistic local update Angular's `Account` component does after a
  /// successful `updateUserDetails` call.
  UserDetails copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) {
    return UserDetails(
      username: username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth,
      balance: balance,
      cards: cards,
    );
  }

  /// Reads one of the four editable fields by name, matching Angular's
  /// `userDetails[field]` dynamic lookup in `account.ts`.
  String fieldValue(String field) {
    switch (field) {
      case 'email':
        return email;
      case 'firstName':
        return firstName;
      case 'lastName':
        return lastName;
      case 'phoneNumber':
        return phoneNumber;
      default:
        return '';
    }
  }
}
