import '../../domain/entities/provider_profile.dart';

class ProviderProfileModel extends ProviderProfile {
  const ProviderProfileModel({
    required super.id,
    required super.userId,
    super.yearsExperience,
    super.hourlyRate,
    super.isAvailable,
    super.bio,
    super.avatarUrl,
    super.coverageCities,
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    final rawCities = json['coverage_cities'];
    final coverageCities = rawCities is List
        ? List<String>.from(rawCities)
        : const <String>[];

    return ProviderProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      yearsExperience: (json['years_experience'] as int?) ?? 0,
      hourlyRate: ((json['hourly_rate'] as num?) ?? 0).toDouble(),
      isAvailable: (json['is_available'] as bool?) ?? true,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverageCities: coverageCities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'years_experience': yearsExperience,
      'hourly_rate': hourlyRate,
      'is_available': isAvailable,
      'bio': bio,
      'avatar_url': avatarUrl,
      'coverage_cities': coverageCities,
    };
  }
}
