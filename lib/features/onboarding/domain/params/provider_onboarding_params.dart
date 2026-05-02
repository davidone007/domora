import 'dart:io';

class ProviderOnboardingParams {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final int yearsExperience;
  final double hourlyRate;
  final String? bio;
  final File? avatar;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? neighborhood;

  const ProviderOnboardingParams({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.yearsExperience,
    required this.hourlyRate,
    this.bio,
    this.avatar,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.neighborhood,
  });
}
