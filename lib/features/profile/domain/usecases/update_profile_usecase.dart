import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId, Map<String, dynamic> updates) async {
    return await repository.updateUserFields(userId, updates);
  }
}
