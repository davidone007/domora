import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

/// UseCase para actualizar la contraseña del usuario autenticado.
/// Habla directamente con [AuthRepository] porque cambiar la contraseña
/// es una operación de autenticación, no de perfil.
class UpdatePasswordUseCase {
  final AuthRepository _authRepository;

  UpdatePasswordUseCase(this._authRepository);

  Future<Either<Failure, Unit>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword == newPassword) {
      return const Left(ValidationFailure('No se puede cambiar por la misma contraseña'));
    }

    return (await _authRepository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    )).map((_) => unit);
  }
}
