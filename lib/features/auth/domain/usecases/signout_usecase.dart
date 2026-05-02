import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.signOut();
  }
}
