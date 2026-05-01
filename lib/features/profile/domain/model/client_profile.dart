import 'package:equatable/equatable.dart';

class ClientProfile extends Equatable {
  final String id;
  final String userId;
  final String? avatarUrl;
  final String? bio;

  const ClientProfile({
    required this.id,
    required this.userId,
    this.avatarUrl,
    this.bio,
  });

  factory ClientProfile.fromMap(Map<String, dynamic> map) {
    return ClientProfile(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, userId, avatarUrl, bio];
}
