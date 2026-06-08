import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/full_profile.dart';
import '../repo/profile_repository.dart';

class GetClientPublicProfileUseCase {
  final ProfileRepository _repository;

  GetClientPublicProfileUseCase(this._repository);

  Future<Either<Failure, FullProfile>> execute(String userId) {
    return _repository.getClientPublicProfile(userId);
  }
}
