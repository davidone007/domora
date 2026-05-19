import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

/// Caso de uso: iniciar sesión.
class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<Either<Failure, AuthResult>> call(LoginParams params) {
    return _repository.signIn(
      email: params.email.trim(),
      password: params.password,
    );
  }
}
