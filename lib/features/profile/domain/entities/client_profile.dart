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

  @override
  List<Object?> get props => [id, userId, avatarUrl, bio];
}
