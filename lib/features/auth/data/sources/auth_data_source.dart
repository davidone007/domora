import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/network/network_info.dart';

/// Fuente de datos para autenticación. Encapsula toda la interacción con
/// Supabase Auth y la tabla `user_roles`.
abstract class AuthDataSource {
  Future<AuthResponse> signUp({required String email, required String password});
  Future<AuthResponse> signIn({required String email, required String password});
  Future<void> signOut();

  /// Asocia el rol al usuario buscando primero el `role_id` por nombre.
  Future<void> assignRole({required String userId, required String roleName});

  /// Obtiene el nombre del rol del usuario (`client` o `provider`).
  Future<String?> getUserRole(String userId);

  /// Verifica si el usuario ya completó el onboarding.
  Future<bool> isOnboardingCompleted(String userId);

  /// Devuelve la sesión actual (si existe).
  Session? get currentSession;
  User? get currentUser;

  /// Actualiza el correo del usuario a través de Supabase Auth.
  Future<void> updateEmail({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  });

  /// Actualiza la contraseña del usuario a través de Supabase Auth.
  Future<void> updatePassword({required String currentPassword, required String newPassword});
}

class AuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  AuthDataSourceImpl(this._client, {required NetworkInfo networkInfo}) : _networkInfo = networkInfo;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }
    return await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }
    await _client.auth.signOut();
  }

  @override
  Future<void> updateEmail({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    final authEmail = _client.auth.currentUser?.email?.trim().toLowerCase();
    final emailToUse = (authEmail == null || authEmail.isEmpty)
      ? currentEmail.trim().toLowerCase()
      : authEmail;
    final nextEmail = newEmail.trim().toLowerCase();
    if (emailToUse.isEmpty || nextEmail.isEmpty) {
      throw const AuthException('El correo no es válido');
    }

    if (emailToUse == nextEmail) {
      throw const AuthException('No se puede cambiar por el mismo correo');
    }

    try {
      await _client.auth.signInWithPassword(email: emailToUse, password: currentPassword);
    } on AuthException {
      throw const AuthException('Contraseña incorrecta');
    }

    await _client.auth.updateUser(UserAttributes(email: nextEmail));
    // El trigger on_auth_user_updated en la BD sincroniza automáticamente
    // public.users.email cuando auth.users.email cambia. No se actualiza
    // la tabla aquí para evitar inconsistencias si Supabase requiere
    // confirmación del correo antes de aplicar el cambio.
  }

  @override
  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    final email = _client.auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      throw const AuthException('No se pudo obtener el correo actual');
    }

    if (currentPassword == newPassword) {
      throw const AuthException('No se puede cambiar por la misma contraseña');
    }

    try {
      await _client.auth.signInWithPassword(email: email, password: currentPassword);
    } on AuthException {
      throw const AuthException('Contraseña incorrecta');
    }

    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> assignRole({
    required String userId,
    required String roleName,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    // 1. Buscar el role_id correspondiente al nombre.
    final roleRow = await _client
        .from(AppConstants.tableRoles)
        .select('id')
        .eq('name', roleName)
        .maybeSingle();

    if (roleRow == null) {
      throw const AuthException('Rol no encontrado en la base de datos');
    }
    final roleId = roleRow['id'] as String;

    // 2. Insertar en user_roles (upsert por la unique constraint).
    await _client.from(AppConstants.tableUserRoles).upsert(
      {
        'user_id': userId,
        'role_id': roleId,
      },
      onConflict: 'user_id,role_id',
    );
  }

  @override
  Future<String?> getUserRole(String userId) async {
    // 1. Intentar obtener el rol desde los metadatos del usuario actual si coincide el ID.
    // Esto es más rápido y ahorra una consulta a la base de datos.
    final current = _client.auth.currentUser;
    if (current != null && current.id == userId) {
      final metaRole = current.userMetadata?['role'] as String?;
      if (metaRole != null) return metaRole;
    }

    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    // 2. Si no está en metadatos o no es el usuario actual, buscar en la base de datos.
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
  Future<bool> isOnboardingCompleted(String userId) async {
    if (!await _networkInfo.isConnected()) {
      throw const SocketException('No internet');
    }

    final row = await _client
        .from(AppConstants.tableUsers)
        .select('onboarding_completed')
        .eq('id', userId)
        .maybeSingle();

    if (row == null) return false;
    return (row['onboarding_completed'] as bool?) ?? false;
  }
}
