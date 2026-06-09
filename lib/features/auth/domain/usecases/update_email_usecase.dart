import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import '../repo/auth_repo.dart';

/// UseCase para actualizar el email del usuario autenticado.
/// Pertenece a la capa de dominio de `auth` porque opera sobre credenciales
/// de autenticación y depende únicamente de [AuthRepository].
class UpdateEmailUseCase {
  final AuthRepository _repository;

  UpdateEmailUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  }) async {
    final normalizedCurrent = currentEmail.trim().toLowerCase();
    final normalizedNew = newEmail.trim().toLowerCase();

    if (normalizedCurrent.isEmpty || normalizedNew.isEmpty) {
      return const Left(ValidationFailure('El correo no es válido'));
    }

    if (normalizedCurrent == normalizedNew) {
      return const Left(
          ValidationFailure('No se puede cambiar por el mismo correo'));
    }

    return (await _repository.updateEmail(
      currentEmail: currentEmail,
      currentPassword: currentPassword,
      newEmail: newEmail,
    ))
        .map((_) => unit);
  }
}
