import 'package:equatable/equatable.dart';

class ProviderProfile extends Equatable {
  final String id;
  final String userId;
  final int yearsExperience;
  final double hourlyRate;
  final bool isAvailable;
  final String? bio;
  final String? avatarUrl;

  const ProviderProfile({
    required this.id,
    required this.userId,
    this.yearsExperience = 0,
    this.hourlyRate = 0,
    this.isAvailable = true,
    this.bio,
    this.avatarUrl,
  });

  factory ProviderProfile.fromMap(Map<String, dynamic> map) {
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

  @override
  List<Object?> get props =>
      [id, userId, yearsExperience, hourlyRate, isAvailable, bio, avatarUrl];
}
