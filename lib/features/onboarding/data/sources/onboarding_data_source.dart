import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/utils/constants.dart';

/// Datos requeridos para completar el perfil de un cliente.
class ClientOnboardingData {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final File? avatar;

  const ClientOnboardingData({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.avatar,
  });
}

/// Datos requeridos para completar el perfil de un proveedor.
class ProviderOnboardingData {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final int yearsExperience;
  final double hourlyRate;
  final String? bio;
  final File? avatar;

  // Dirección
  final String addressLine1;
  final String? addressLine2;
  final String department;
  final String city;
  final String? neighborhood;

  const ProviderOnboardingData({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.yearsExperience,
    required this.hourlyRate,
    this.bio,
    this.avatar,
    required this.addressLine1,
    this.addressLine2,
    required this.department,
    required this.city,
    this.neighborhood,
  });
}

/// Fuente de datos para el onboarding. Encapsula todas las escrituras
/// necesarias en Supabase.
abstract class OnboardingDataSource {
  Future<void> saveClientProfile(ClientOnboardingData data);
  Future<void> saveProviderProfile(ProviderOnboardingData data);
}

class OnboardingDataSourceImpl implements OnboardingDataSource {
  final SupabaseClient _client;
  OnboardingDataSourceImpl(this._client);

  /// Sube el avatar al bucket `avatars` y devuelve su URL pública.
  Future<String?> _uploadAvatar(String userId, File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final path =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage.from(AppConstants.bucketAvatars).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(AppConstants.bucketAvatars).getPublicUrl(path);
  }

  @override
  Future<void> saveClientProfile(ClientOnboardingData data) async {
    String? avatarUrl;
    if (data.avatar != null) {
      avatarUrl = await _uploadAvatar(data.userId, data.avatar!);
    }

    // 1. Actualizar USERS con datos básicos.
    await _client.from(AppConstants.tableUsers).update({
      'first_name': data.firstName,
      'last_name': data.lastName,
      'phone': data.phone,
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', data.userId);

    // 2. Upsert CLIENT_PROFILES.
    await _client.from(AppConstants.tableClientProfiles).upsert(
      {
        'user_id': data.userId,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
      onConflict: 'user_id',
    );
  }

  @override
  Future<void> saveProviderProfile(ProviderOnboardingData data) async {
    String? avatarUrl;
    if (data.avatar != null) {
      avatarUrl = await _uploadAvatar(data.userId, data.avatar!);
    }

    // 1. Actualizar USERS.
    await _client.from(AppConstants.tableUsers).update({
      'first_name': data.firstName,
      'last_name': data.lastName,
      'phone': data.phone,
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', data.userId);

    // 2. Upsert PROVIDER_PROFILES.
    await _client.from(AppConstants.tableProviderProfiles).upsert(
      {
        'user_id': data.userId,
        'years_experience': data.yearsExperience,
        'hourly_rate': data.hourlyRate,
        'bio': data.bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'is_available': true,
      },
      onConflict: 'user_id',
    );

    // 3. Insertar ADDRESSES (primera dirección como principal).
    await _client.from(AppConstants.tableAddresses).insert({
      'user_id': data.userId,
      'address_line1': data.addressLine1,
      'address_line2': data.addressLine2,
      'department': data.department,
      'city': data.city,
      'neighborhood': data.neighborhood,
      'is_primary': true,
      'address_type': 'work',
    });
  }
}
