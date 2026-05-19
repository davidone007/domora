import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import '../repo/profile_repository.dart';

/// UseCase para actualizar la contraseña del usuario autenticado.
/// Delega en [ProfileRepository] que internamente coordina con la capa de auth.
class UpdatePasswordUseCase {
  final ProfileRepository _profileRepository;

  UpdatePasswordUseCase(this._profileRepository);

  Future<Either<Failure, Unit>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword == newPassword) {
      return const Left(ValidationFailure('No se puede cambiar por la misma contraseña'));
    }

    return (await _profileRepository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    )).map((_) => unit);
  }
}
