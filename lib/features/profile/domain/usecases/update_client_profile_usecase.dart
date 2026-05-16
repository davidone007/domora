import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

/// Parámetros de dominio para actualizar el perfil de un cliente.
/// Sin claves de BD — solo conceptos de negocio.
class UpdateClientProfileParams {
  final String userId;
  final String? bio;
  final String? avatarUrl;

  const UpdateClientProfileParams({
    required this.userId,
    this.bio,
    this.avatarUrl,
  });
}

/// UseCase para actualizar el perfil específico de un cliente.
class UpdateClientProfileUseCase {
  final ProfileRepository _repository;

  UpdateClientProfileUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UpdateClientProfileParams params) async {
    if (params.bio == null && params.avatarUrl == null) {
      return const Right(unit);
    }
    return await _repository.updateClientProfileFields(params);
  }
}
