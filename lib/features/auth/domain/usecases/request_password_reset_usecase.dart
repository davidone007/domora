import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

class RequestPasswordResetUseCase {
  final AuthRepository _repository;
  RequestPasswordResetUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) {
    return _repository.requestPasswordReset(email);
  }
}
