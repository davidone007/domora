import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import '../repo/auth_repo.dart';

/// UseCase para actualizar la contraseña del usuario autenticado.
/// Pertenece a la capa de dominio de `auth` porque opera sobre credenciales
/// de autenticación y depende únicamente de [AuthRepository].
class UpdatePasswordUseCase {
  final AuthRepository _repository;

  UpdatePasswordUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword == newPassword) {
      return const Left(
          ValidationFailure('No se puede cambiar por la misma contraseña'));
    }

    return (await _repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ))
        .map((_) => unit);
  }
}
