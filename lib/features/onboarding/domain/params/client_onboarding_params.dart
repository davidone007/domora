import 'package:domora/features/onboarding/domain/entities/avatar_file.dart';

class ClientOnboardingParams {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final AvatarFile? avatar;

  const ClientOnboardingParams({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.avatar,
  });
}
