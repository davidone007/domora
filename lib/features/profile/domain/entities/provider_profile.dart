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

  @override
  List<Object?> get props =>
      [id, userId, yearsExperience, hourlyRate, isAvailable, bio, avatarUrl];
}
