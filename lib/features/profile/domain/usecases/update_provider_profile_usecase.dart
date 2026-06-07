import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/params/profile_params.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

export 'package:domora/features/profile/domain/params/profile_params.dart'
    show UpdateProviderProfileParams;

/// UseCase para actualizar el perfil específico de un proveedor.
class UpdateProviderProfileUseCase {
  final ProfileRepository _repository;

  UpdateProviderProfileUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UpdateProviderProfileParams params) async {
    if (params.yearsExperience == null &&
        params.hourlyRate == null &&
        params.isAvailable == null &&
        params.bio == null &&
        params.avatarUrl == null) {
      return const Right(unit);
    }
    return await _repository.updateProviderProfileFields(params);
  }
}
