import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

class SignupParams {
  final String email;
  final String password;
  final String role;

  const SignupParams({
    required this.email,
    required this.password,
    required this.role,
  });
}

/// Caso de uso: registrar un nuevo usuario y asignar su rol.
class SignupUseCase {
  final AuthRepository _repository;
  SignupUseCase(this._repository);

  Future<Either<Failure, AuthResult>> call(SignupParams params) {
    return _repository.signUp(
      email: params.email.trim(),
      password: params.password,
      role: params.role,
    );
  }
}
