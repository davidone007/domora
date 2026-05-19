import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/onboarding/domain/params/provider_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/repo/onboarding_repo.dart';

/// Caso de uso: persistir el perfil de proveedor al finalizar el onboarding.
class SaveProviderProfileUseCase {
  final OnboardingRepository _repository;
  SaveProviderProfileUseCase(this._repository);

  Future<Either<Failure, void>> call(ProviderOnboardingParams params) {
    if (params.addressLine1.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('La dirección es obligatoria')),
      );
    }
    if (params.department.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('El departamento es obligatorio')),
      );
    }
    if (params.city.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('La ciudad es obligatoria')),
      );
    }
    if (params.hourlyRate <= 0) {
      return Future.value(
        const Left(ValidationFailure('La tarifa por hora debe ser mayor a 0')),
      );
    }

    return _repository.saveProviderProfile(params);
  }
}
