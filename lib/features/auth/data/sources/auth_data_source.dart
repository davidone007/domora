import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/utils/constants.dart';

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
}

class AuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient _client;

  AuthDataSourceImpl(this._client);

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> assignRole({
    required String userId,
    required String roleName,
  }) async {
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
    final row = await _client
        .from(AppConstants.tableUsers)
        .select('onboarding_completed')
        .eq('id', userId)
        .maybeSingle();

    if (row == null) return false;
    return (row['onboarding_completed'] as bool?) ?? false;
  }
}
