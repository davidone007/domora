import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/params/profile_params.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

export 'package:domora/features/profile/domain/params/profile_params.dart'
    show UpdateUserFieldsParams;

/// UseCase para actualizar los campos básicos del usuario (nombre, apellido, teléfono).
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, Unit>> call(UpdateUserFieldsParams params) async {
    if (params.firstName == null && params.lastName == null && params.phone == null) {
      return const Left(ValidationFailure('No hay campos para actualizar'));
    }
    return await repository.updateUserFields(params);
  }
}
