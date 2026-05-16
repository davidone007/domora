import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

/// Parámetros de dominio para actualizar el perfil de un proveedor.
/// Sin claves de BD — solo conceptos de negocio.
class UpdateProviderProfileParams {
  final String userId;
  final int? yearsExperience;
  final double? hourlyRate;
  final bool? isAvailable;
  final String? bio;
  final String? avatarUrl;

  const UpdateProviderProfileParams({
    required this.userId,
    this.yearsExperience,
    this.hourlyRate,
    this.isAvailable,
    this.bio,
    this.avatarUrl,
  });
}

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
