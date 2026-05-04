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
    return await repository.updateEmail(
      currentEmail: currentEmail,
      currentPassword: currentPassword,
      newEmail: newEmail,
    );
  }
}
