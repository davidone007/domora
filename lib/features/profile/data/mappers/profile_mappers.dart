import 'package:domora/features/profile/domain/entities/address.dart';
import 'package:domora/features/profile/domain/entities/client_profile.dart';
import 'package:domora/features/profile/domain/entities/provider_profile.dart';
import 'package:domora/features/profile/domain/entities/user.dart';

class ProfileMappers {
  const ProfileMappers._();

  static User userFromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      isActive: (map['is_active'] as bool?) ?? true,
      onboardingCompleted: (map['onboarding_completed'] as bool?) ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      lastLogin: map['last_login'] != null
          ? DateTime.tryParse(map['last_login'] as String)
          : null,
    );
  }

  static Address addressFromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      locationName: map['location_name'] as String?,
      addressLine1: map['address_line1'] as String? ?? '',
      addressLine2: map['address_line2'] as String?,
      city: map['city'] as String? ?? '',
      neighborhood: map['neighborhood'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isPrimary: (map['is_primary'] as bool?) ?? false,
      addressType: map['address_type'] as String?,
    );
  }

  static ClientProfile clientProfileFromMap(Map<String, dynamic> map) {
    return ClientProfile(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
    );
  }

  static ProviderProfile providerProfileFromMap(Map<String, dynamic> map) {
    return ProviderProfile(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      yearsExperience: (map['years_experience'] as int?) ?? 0,
      hourlyRate: ((map['hourly_rate'] as num?) ?? 0).toDouble(),
      isAvailable: (map['is_available'] as bool?) ?? true,
      bio: map['bio'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}
