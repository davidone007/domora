import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:domora/core/entities/avatar_file.dart';

abstract class ProfileDataSource {
  String? getCurrentUserId();
  Future<Map<String, dynamic>?> getUser(String userId);
  Future<String?> getRole(String userId);
  Future<Map<String, dynamic>?> getClientProfile(String userId);
  Future<Map<String, dynamic>?> getProviderProfile(String userId);
  Future<Map<String, dynamic>?> getPrimaryAddress(String userId);

  /// Actualiza la fila en la tabla `users` identificada por `userId`.
  Future<void> updateUser(String userId, Map<String, dynamic> updates);

  /// Actualiza la fila en `client_profiles` para el `userId`.
  Future<void> updateClientProfile(String userId, Map<String, dynamic> updates);

  /// Actualiza la fila en `provider_profiles` para el `userId`.
  Future<void> updateProviderProfile(String userId, Map<String, dynamic> updates);

  /// Actualiza o crea la dirección principal del usuario.
  Future<void> updatePrimaryAddress(String userId, Map<String, dynamic> updates);

  /// Sube el avatar a Supabase Storage y retorna la URL pública.
  /// El parámetro [isProvider] determina la subcarpeta (client_avatars o provider_avatars).
  Future<String> uploadAvatar({
    required String userId,
    required AvatarFile avatarFile,
    required bool isProvider,
  });
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  ProfileDataSourceImpl(this._client, {required NetworkInfo networkInfo}) : _networkInfo = networkInfo;

  @override
  String? getCurrentUserId() => _client.auth.currentUser?.id;

  @override
  Future<Map<String, dynamic>?> getUser(String userId) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    return await _client
        .from(AppConstants.tableUsers)
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  @override
  Future<String?> getRole(String userId) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

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
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    return await _client
        .from(AppConstants.tableClientProfiles)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  @override
  Future<Map<String, dynamic>?> getProviderProfile(String userId) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    return await _client
        .from(AppConstants.tableProviderProfiles)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  @override
  Future<Map<String, dynamic>?> getPrimaryAddress(String userId) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

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

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    if (userId.isEmpty) {
      throw const SocketException('userId está vacío');
    }

    await _client.from(AppConstants.tableUsers).update(updates).eq('id', userId);
  }

  @override
  Future<void> updateClientProfile(String userId, Map<String, dynamic> updates) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    await _client.from(AppConstants.tableClientProfiles).update(updates).eq('user_id', userId);
  }

  @override
  Future<void> updateProviderProfile(String userId, Map<String, dynamic> updates) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    await _client.from(AppConstants.tableProviderProfiles).update(updates).eq('user_id', userId);
  }

  @override
  Future<void> updatePrimaryAddress(String userId, Map<String, dynamic> updates) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    final current = await getPrimaryAddress(userId);
    if (current != null && current['id'] != null) {
      await _client.from(AppConstants.tableAddresses).update(updates).eq('id', current['id']);
      return;
    }

    await _client.from(AppConstants.tableAddresses).insert({
      'user_id': userId,
      'is_primary': true,
      'address_type': 'work',
      ...updates,
    });
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required AvatarFile avatarFile,
    required bool isProvider,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    if (userId.isEmpty) {
      throw const SocketException('userId está vacío');
    }

    final ext = avatarFile.filename.split('.').last.toLowerCase();
    final safeExt = ext.isNotEmpty ? ext : 'png';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/avatar_$timestamp.$safeExt';

    await _client.storage
      .from(AppConstants.bucketAvatars)
        .uploadBinary(
          path,
          avatarFile.bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = _client.storage.from(AppConstants.bucketAvatars).getPublicUrl(path);

    return publicUrl;
  }
}
