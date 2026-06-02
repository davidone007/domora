import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/network/network_info.dart';
import '../models/proposal_model.dart';
import '../models/proposal_with_provider_model.dart';

abstract class ProposalRemoteDataSource {
  Future<void> sendProposal(ProposalModel proposal);
  Future<bool> hasUserProposed(String serviceId, String providerId);
  Future<List<ProposalWithProviderModel>> getProposalsByServiceId({
    required String serviceId,
    required String clientId,
  });
  Future<String> acceptProposal(ProposalModel proposal);
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
  Future<List<ProposalWithProviderModel>> getProposalsByServiceId({
    required String serviceId,
    required String clientId,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    // Usamos un join con la tabla 'services' para asegurar que el servicio
    // pertenece al cliente que hace la consulta (Client Ownership Validation).
    final List<dynamic> response = await _client
        .from('quotes')
        .select('*, services!inner(client_id), users(first_name, last_name, provider_profiles(avatar_url, years_experience))')
        .eq('service_id', serviceId)
        .eq('services.client_id', clientId)
        .order('created_at', ascending: false);

    return response.map((json) => ProposalWithProviderModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<String> acceptProposal(ProposalModel proposal) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    final response = await _client.rpc('accept_quote', params: {
      'p_quote_id': proposal.id,
      'p_service_id': proposal.serviceId,
      'p_client_id': _client.auth.currentUser!.id,
      'p_provider_id': proposal.providerId,
      'p_price': proposal.price,
    });

    // Defensive: ensure the parent service moves to in_progress even if the
    // RPC implementation does not handle this transition. Idempotent.
    try {
      await _client
          .from('services')
          .update({'status': 'in_progress'})
          .eq('id', proposal.serviceId);
    } catch (_) {
      // Don't fail accept if status nudge fails; the booking is already created.
    }

    return response as String;
  }
}
