import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

/// UseCase para actualizar el email del usuario autenticado.
/// Habla directamente con [AuthRepository] porque cambiar el email
/// es una operación de autenticación, no de perfil.
class UpdateEmailUseCase {
  final AuthRepository _authRepository;

  UpdateEmailUseCase(this._authRepository);

  Future<Either<Failure, Unit>> call({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  }) async {
    if (currentEmail.trim().toLowerCase() == newEmail.trim().toLowerCase()) {
      return const Left(ValidationFailure('No se puede cambiar por el mismo correo'));
    }

    return (await _authRepository.updateEmail(
      currentEmail: currentEmail,
      currentPassword: currentPassword,
      newEmail: newEmail,
    )).map((_) => unit);
  }
}
