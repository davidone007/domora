import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/network/network_info.dart';
import '../models/proposal_model.dart';
import '../models/proposal_with_provider_model.dart';

abstract class ProposalRemoteDataSource {
  Future<void> sendProposal(ProposalModel proposal);
  Future<bool> hasUserProposed(String serviceId, String providerId);
  Future<List<ProposalWithProviderModel>> getProposalsByServiceId(String serviceId);
}

class ProposalRemoteDataSourceImpl implements ProposalRemoteDataSource {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  ProposalRemoteDataSourceImpl(this._client, {required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  @override
  Future<void> sendProposal(ProposalModel proposal) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    await _client.from('quotes').insert(proposal.toJson());
  }

  @override
  Future<bool> hasUserProposed(String serviceId, String providerId) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    final response = await _client
        .from('quotes')
        .select('id')
        .eq('service_id', serviceId)
        .eq('provider_id', providerId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<List<ProposalWithProviderModel>> getProposalsByServiceId(String serviceId) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    final List<dynamic> response = await _client
        .from('quotes')
        .select('*, users(first_name, last_name, provider_profiles(avatar_url, years_experience))')
        .eq('service_id', serviceId)
        .order('created_at', ascending: false);

    return response.map((json) => ProposalWithProviderModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
