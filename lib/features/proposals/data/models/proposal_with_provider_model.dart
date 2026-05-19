import '../../domain/entities/proposal_with_provider.dart';
import 'proposal_model.dart';

class ProposalWithProviderModel extends ProposalWithProvider {
  const ProposalWithProviderModel({
    required super.proposal,
    required super.providerFirstName,
    required super.providerLastName,
    super.providerAvatarUrl,
    super.providerExperienceYears,
  });

  factory ProposalWithProviderModel.fromJson(Map<String, dynamic> json) {
    // Manejo de la anidación según la consulta de Supabase:
    // quotes { ..., users: { first_name, last_name, provider_profiles: { avatar_url, years_experience } } }
    final userData = json['users'] as Map<String, dynamic>;
    final profileData = (userData['provider_profiles'] is List) 
        ? (userData['provider_profiles'] as List).firstOrNull 
        : userData['provider_profiles'];

    return ProposalWithProviderModel(
      proposal: ProposalModel.fromJson(json),
      providerFirstName: userData['first_name'] ?? 'Usuario',
      providerLastName: userData['last_name'] ?? '',
      providerAvatarUrl: profileData?['avatar_url'],
      providerExperienceYears: profileData?['years_experience'],
    );
  }
}
