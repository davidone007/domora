import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/params/profile_params.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

export 'package:domora/features/profile/domain/params/profile_params.dart'
    show UpdateClientProfileParams;

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
