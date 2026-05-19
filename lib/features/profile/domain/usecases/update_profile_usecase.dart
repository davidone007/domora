import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

/// Parámetros de dominio para actualizar los campos básicos del usuario.
/// Solo contiene conceptos de negocio — sin claves de BD.
class UpdateUserFieldsParams {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? phone;

  const UpdateUserFieldsParams({
    required this.userId,
    this.firstName,
    this.lastName,
    this.phone,
  });
}

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
