import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:domora/infrastructure/network/network_info_impl.dart';

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

  AuthDataSourceImpl(this._client, {NetworkInfo? networkInfo}) : _networkInfo = networkInfo ?? NetworkInfoImpl();

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

    final emailToUse = currentEmail.trim().toLowerCase();
    final nextEmail = newEmail.trim().toLowerCase();
    if (emailToUse.isEmpty || nextEmail.isEmpty) {
      throw const AuthException('El correo no es válido');
    }

    print('🔵 AuthDataSource.updateEmail: $emailToUse → $nextEmail');

    // Re-authenticate with current credentials
    await _client.auth.signInWithPassword(email: emailToUse, password: currentPassword);
    print('✅ AuthDataSource: re-autenticado con $emailToUse');
    
    // Update email in Auth
    await _client.auth.updateUser(UserAttributes(email: nextEmail));
    print('✅ AuthDataSource: email en auth.users actualizado a $nextEmail');

    // Verifica que el nuevo correo ya pueda autenticarse antes de sincronizar
    // la tabla pública. Si Supabase dejó el cambio pendiente de confirmación,
    // aquí se devuelve error en lugar de mostrar un éxito falso.
    await _client.auth.signInWithPassword(email: nextEmail, password: currentPassword);
    print('✅ AuthDataSource: verificado acceso con el nuevo correo $nextEmail');
    
    // Sync email change to public.users table
    final userId = _client.auth.currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      await _client.from(AppConstants.tableUsers)
          .update({'email': nextEmail})
          .eq('id', userId);
      print('✅ AuthDataSource: email en public.users actualizado a $nextEmail');
    } else {
      print('⚠️ AuthDataSource: userId es null o vacío, no se sincronizó en public.users');
    }
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

    print('🔵 AuthDataSource.updatePassword: email=$email');

    await _client.auth.signInWithPassword(email: email, password: currentPassword);
    print('✅ AuthDataSource: re-autenticado con $email');
    
    await _client.auth.updateUser(UserAttributes(password: newPassword));
    print('✅ AuthDataSource: contraseña actualizada');

    // Verifica que la nueva contraseña ya sea válida en Supabase Auth.
    await _client.auth.signInWithPassword(email: email, password: newPassword);
    print('✅ AuthDataSource: verificado acceso con la nueva contraseña');
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
