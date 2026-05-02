import 'dart:io';

class ClientOnboardingParams {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final File? avatar;

  const ClientOnboardingParams({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.avatar,
  });
}
