import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/onboarding/data/sources/onboarding_data_source.dart';
import 'package:domora/features/onboarding/domain/repo/onboarding_repo.dart';

/// Caso de uso: persistir el perfil de proveedor al finalizar el onboarding.
class SaveProviderProfileUseCase {
  final OnboardingRepository _repository;
  SaveProviderProfileUseCase(this._repository);

  Future<Either<Failure, void>> call(ProviderOnboardingData data) {
    return _repository.saveProviderProfile(data);
  }
}
