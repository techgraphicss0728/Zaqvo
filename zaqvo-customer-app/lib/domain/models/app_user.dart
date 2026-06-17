import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.membershipTier,
    this.phoneNumber = '',
    this.dateOfBirth,
  });

  final String id;
  final String name;
  final String email;
  final String membershipTier;
  final String phoneNumber;
  final DateTime? dateOfBirth;

  AppUser copyWith({
    String? name,
    String? email,
    String? membershipTier,
    String? phoneNumber,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      membershipTier: membershipTier ?? this.membershipTier,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth:
          clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        membershipTier,
        phoneNumber,
        dateOfBirth,
      ];
}
