import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

class GetCurrentSessionUseCase {
  final AuthRepository _repository;

  GetCurrentSessionUseCase(this._repository);

  Future<Either<Failure, AuthResult?>> call() {
    return _repository.getCurrentSession();
  }
}
