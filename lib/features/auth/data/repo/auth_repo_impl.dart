import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/data/sources/auth_data_source.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

/// Implementación de [AuthRepository] basada en Supabase.
/// Traduce las excepciones de la capa de datos a [Failure]s tipadas.
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  String _mapAuthError(AuthException e) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (m.contains('user already registered') ||
        m.contains('already been registered')) {
      return 'Este correo ya está registrado';
    }
    if (m.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión';
    }
    if (m.contains('password should be')) {
      return 'La contraseña no cumple los requisitos mínimos';
    }
    return e.message;
  }

  @override
  Future<Either<Failure, AuthResult>> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dataSource.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const Left(AuthFailure('No se pudo crear la cuenta'));
      }

      // Asignar rol al nuevo usuario.
      await _dataSource.assignRole(userId: user.id, roleName: role);

      return Right(
        AuthResult(
          userId: user.id,
          email: user.email ?? email,
          role: role,
          onboardingCompleted: false,
        ),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e)));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.signIn(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const Left(AuthFailure('No se pudo iniciar sesión'));
      }

      final role = await _dataSource.getUserRole(user.id);
      final onboardingDone = await _dataSource.isOnboardingCompleted(user.id);

      return Right(
        AuthResult(
          userId: user.id,
          email: user.email ?? email,
          role: role,
          onboardingCompleted: onboardingDone,
        ),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e)));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult?>> getCurrentSession() async {
    try {
      final session = _dataSource.currentSession;
      final user = _dataSource.currentUser;
      if (session == null || user == null) return const Right(null);

      final role = await _dataSource.getUserRole(user.id);
      final onboardingDone = await _dataSource.isOnboardingCompleted(user.id);

      return Right(AuthResult(
        userId: user.id,
        email: user.email ?? '',
        role: role,
        onboardingCompleted: onboardingDone,
      ));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
