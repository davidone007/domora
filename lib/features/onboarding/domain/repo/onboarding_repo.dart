import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/onboarding/data/sources/onboarding_data_source.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, void>> saveClientProfile(ClientOnboardingData data);
  Future<Either<Failure, void>> saveProviderProfile(ProviderOnboardingData data);
}
