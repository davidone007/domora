import 'package:equatable/equatable.dart';

import 'package:domora/features/profile/domain/model/address.dart';
import 'package:domora/features/profile/domain/model/client_profile.dart';
import 'package:domora/features/profile/domain/model/provider_profile.dart';
import 'package:domora/features/profile/domain/model/user.dart';

/// Vista agregada del perfil para mostrar en la UI (HU4).
class FullProfile extends Equatable {
  final User user;
  final String role;
  final ClientProfile? clientProfile;
  final ProviderProfile? providerProfile;
  final Address? primaryAddress;

  const FullProfile({
    required this.user,
    required this.role,
    this.clientProfile,
    this.providerProfile,
    this.primaryAddress,
  });

  bool get isProvider => role == 'provider';

  String? get avatarUrl =>
      isProvider ? providerProfile?.avatarUrl : clientProfile?.avatarUrl;

  String? get bio => isProvider ? providerProfile?.bio : clientProfile?.bio;

  @override
  List<Object?> get props =>
      [user, role, clientProfile, providerProfile, primaryAddress];
}
