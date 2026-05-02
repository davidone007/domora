import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/onboarding/domain/params/client_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/repo/onboarding_repo.dart';

/// Caso de uso: persistir el perfil de cliente al finalizar el onboarding.
class SaveClientProfileUseCase {
  final OnboardingRepository _repository;
  SaveClientProfileUseCase(this._repository);

  Future<Either<Failure, void>> call(ClientOnboardingParams params) {
    return _repository.saveClientProfile(params);
  }
}
