import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

class UpdatePasswordUseCase {
  final ProfileRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword == newPassword) {
      return const Left(ValidationFailure('No se puede cambiar por la misma contraseña'));
    }

    return await repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
