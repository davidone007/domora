import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import '../repo/profile_repository.dart';

/// UseCase para actualizar el email del usuario autenticado.
/// Delega en [ProfileRepository] que internamente coordina con la capa de auth.
class UpdateEmailUseCase {
  final ProfileRepository _profileRepository;

  UpdateEmailUseCase(this._profileRepository);

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

    return (await _profileRepository.updateEmail(
      currentEmail: currentEmail,
      currentPassword: currentPassword,
      newEmail: newEmail,
    ))
        .map((_) => unit);
  }
}
