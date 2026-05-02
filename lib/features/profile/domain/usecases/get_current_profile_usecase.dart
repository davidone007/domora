import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

class GetCurrentProfileUseCase {
  final ProfileRepository _repository;

  GetCurrentProfileUseCase(this._repository);

  Future<Either<Failure, FullProfile>> call() {
    return _repository.getCurrentProfile();
  }
}
