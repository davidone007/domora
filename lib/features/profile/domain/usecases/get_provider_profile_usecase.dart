import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/full_profile.dart';
import '../repo/profile_repository.dart';

class GetProviderProfileUseCase {
  final ProfileRepository _repository;

  GetProviderProfileUseCase(this._repository);

  Future<Either<Failure, FullProfile>> execute(String userId) {
    return _repository.getProviderProfileById(userId);
  }
}
