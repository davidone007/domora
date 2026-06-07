import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';

class SetNewPasswordUseCase {
  final AuthRepository _repository;
  SetNewPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(String newPassword) {
    return _repository.setNewPasswordAfterReset(newPassword);
  }
}
