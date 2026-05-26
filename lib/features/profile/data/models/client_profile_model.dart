import '../../domain/entities/client_profile.dart';

class ClientProfileModel extends ClientProfile {
  const ClientProfileModel({
    required super.id,
    required super.userId,
    super.avatarUrl,
    super.bio,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'avatar_url': avatarUrl,
      'bio': bio,
    };
  }
}
