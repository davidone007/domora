import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/features/auth/data/sources/auth_data_source.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

/// Implementación de [AuthRepository] basada en Supabase.
/// Traduce las excepciones de la capa de datos a [Failure]s tipadas.
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final FailureMapper _errorMapper;

  AuthRepositoryImpl(this._dataSource, this._errorMapper);

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
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'signUp',
          parameters: {'email': email, 'role': role},
        ).toString(),
      ));
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
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'signIn',
          parameters: {'email': email},
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
    } catch (_) {
      // Supabase Flutter siempre limpia la sesión local incluso si la
      // petición al servidor falla (p.ej. sin conexión). Tratamos cualquier
      // excepción como cierre de sesión exitoso para garantizar que la UI
      // siempre navega a la pantalla de bienvenida.
    }
    return const Right(null);
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
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'getCurrentSession').toString(),
      ));
    }
  }

  @override
  String? get currentUserEmail => _dataSource.currentUser?.email;

  @override
  Future<Either<Failure, void>> updateEmail({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  }) async {
    try {
      await _dataSource.updateEmail(
        currentEmail: currentEmail,
        currentPassword: currentPassword,
        newEmail: newEmail,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'updateEmail').toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'updatePassword').toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      await _dataSource.requestPasswordReset(email);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'requestPasswordReset',
          parameters: {'email': email},
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> setNewPasswordAfterReset(String newPassword) async {
    try {
      await _dataSource.setNewPasswordAfterReset(newPassword);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'setNewPasswordAfterReset').toString(),
      ));
    }
  }
}
