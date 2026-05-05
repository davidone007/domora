import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

class UpdateEmailUseCase {
  final ProfileRepository repository;

  UpdateEmailUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  }) async {
    if (currentEmail.trim().toLowerCase() == newEmail.trim().toLowerCase()) {
      return Left(const ValidationFailure('No se puede cambiar por el mismo correo'));
    }

    return await repository.updateEmail(
      currentEmail: currentEmail,
      currentPassword: currentPassword,
      newEmail: newEmail,
    );
  }
}
