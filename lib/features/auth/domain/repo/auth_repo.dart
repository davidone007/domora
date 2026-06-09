import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:domora/core/error/failures.dart';

/// Resultado de operaciones de autenticación.
class AuthResult extends Equatable {
  final String userId;
  final String email;
  final String? role;
  final bool onboardingCompleted;

  const AuthResult({
    required this.userId,
    required this.email,
    this.role,
    this.onboardingCompleted = false,
  });

  AuthResult copyWith({
    String? userId,
    String? email,
    String? role,
    bool? onboardingCompleted,
  }) {
    return AuthResult(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  List<Object?> get props => [userId, email, role, onboardingCompleted];
}

/// Contrato abstracto del repositorio de autenticación. La capa de dominio
/// no conoce la implementación concreta (Supabase u otra).
abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> signUp({
    required String email,
    required String password,
    required String role,
  });

  Future<Either<Failure, AuthResult>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  /// Devuelve el resultado de la sesión actual o `null` si no hay sesión.
  Future<Either<Failure, AuthResult?>> getCurrentSession();

  /// Devuelve el correo del usuario actualmente autenticado, o `null`.
  String? get currentUserEmail;

  /// Reautentica con el correo y contraseña actual antes de cambiar el correo.
  Future<Either<Failure, void>> updateEmail({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  });

  /// Reautentica con la contraseña actual y actualiza la contraseña en Auth.
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Envía un correo de restablecimiento de contraseña.
  Future<Either<Failure, void>> requestPasswordReset(String email);

  /// Establece una nueva contraseña usando la sesión de recuperación activa.
  Future<Either<Failure, void>> setNewPasswordAfterReset(String newPassword);
}
