import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/onboarding/domain/params/provider_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/repo/onboarding_repo.dart';

/// Caso de uso: persistir el perfil de proveedor al finalizar el onboarding.
class SaveProviderProfileUseCase {
  final OnboardingRepository _repository;
  SaveProviderProfileUseCase(this._repository);

  Future<Either<Failure, void>> call(ProviderOnboardingParams params) {
    return _repository.saveProviderProfile(params);
  }
}
