import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/utils/constants.dart';

abstract class ProfileDataSource {
  Future<Map<String, dynamic>?> getUser(String userId);
  Future<String?> getRole(String userId);
  Future<Map<String, dynamic>?> getClientProfile(String userId);
  Future<Map<String, dynamic>?> getProviderProfile(String userId);
  Future<Map<String, dynamic>?> getPrimaryAddress(String userId);
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final SupabaseClient _client;
  ProfileDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>?> getUser(String userId) async {
    return await _client
        .from(AppConstants.tableUsers)
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  @override
  Future<String?> getRole(String userId) async {
    final result = await _client
        .from(AppConstants.tableUserRoles)
        .select('roles(name)')
        .eq('user_id', userId)
        .maybeSingle();

    if (result == null) return null;
    final roles = result['roles'];
    if (roles is Map) return roles['name'] as String?;
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getClientProfile(String userId) async {
    return await _client
        .from(AppConstants.tableClientProfiles)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  @override
  Future<Map<String, dynamic>?> getProviderProfile(String userId) async {
    return await _client
        .from(AppConstants.tableProviderProfiles)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  @override
  Future<Map<String, dynamic>?> getPrimaryAddress(String userId) async {
    // Devuelve la primaria; si no hay, la primera registrada.
    final primary = await _client
        .from(AppConstants.tableAddresses)
        .select()
        .eq('user_id', userId)
        .eq('is_primary', true)
        .maybeSingle();
    if (primary != null) return primary;

    final any = await _client
        .from(AppConstants.tableAddresses)
        .select()
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();
    return any;
  }
}
