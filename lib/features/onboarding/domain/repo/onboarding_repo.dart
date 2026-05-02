import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/onboarding/domain/params/client_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/params/provider_onboarding_params.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, void>> saveClientProfile(ClientOnboardingParams params);
  Future<Either<Failure, void>> saveProviderProfile(
      ProviderOnboardingParams params);
}
