import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

class RequestPasswordResetUseCase {
  final AuthRepository _repository;
  RequestPasswordResetUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) {
    // Validación de dominio: el correo no puede estar vacío.
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Ingresa un correo válido')),
      );
    }
    return _repository.requestPasswordReset(normalized);
  }
}
