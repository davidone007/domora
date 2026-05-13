import 'package:equatable/equatable.dart';

import 'package:domora/features/profile/domain/entities/address.dart';
import 'package:domora/features/profile/domain/entities/client_profile.dart';
import 'package:domora/features/profile/domain/entities/provider_profile.dart';
import 'package:domora/features/profile/domain/entities/provider_stats.dart';
import 'package:domora/features/profile/domain/entities/user.dart';

/// Vista agregada del perfil para mostrar en la UI (HU4).
class FullProfile extends Equatable {
  final User user;
  final String role;
  final ClientProfile? clientProfile;
  final ProviderProfile? providerProfile;
  final Address? primaryAddress;
  final ProviderStats? stats;

  const FullProfile({
    required this.user,
    required this.role,
    this.clientProfile,
    this.providerProfile,
    this.primaryAddress,
    this.stats,
  });

  bool get isProvider => role == 'provider';

  String? get avatarUrl =>
      isProvider ? providerProfile?.avatarUrl : clientProfile?.avatarUrl;

  String? get bio => isProvider ? providerProfile?.bio : clientProfile?.bio;

  @override
  List<Object?> get props =>
      [user, role, clientProfile, providerProfile, primaryAddress, stats];
}
