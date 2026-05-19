import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/features/onboarding/data/sources/onboarding_data_source.dart';
import 'package:domora/features/onboarding/domain/params/client_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/params/provider_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/repo/onboarding_repo.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingDataSource _dataSource;
  final FailureMapper _errorMapper;
  
  OnboardingRepositoryImpl(this._dataSource, this._errorMapper);

  @override
  Future<Either<Failure, void>> saveClientProfile(
      ClientOnboardingParams params) async {
    try {
      await _dataSource.saveClientProfile(
        ClientOnboardingData(
          userId: params.userId,
          firstName: params.firstName,
          lastName: params.lastName,
          phone: params.phone,
          avatar: params.avatar,
        ),
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'saveClientProfile',
          userId: params.userId,
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveProviderProfile(
      ProviderOnboardingParams params) async {
    try {
      await _dataSource.saveProviderProfile(
        ProviderOnboardingData(
          userId: params.userId,
          firstName: params.firstName,
          lastName: params.lastName,
          phone: params.phone,
          yearsExperience: params.yearsExperience,
          hourlyRate: params.hourlyRate,
          bio: params.bio,
          avatar: params.avatar,
          addressLine1: params.addressLine1,
          addressLine2: params.addressLine2,
          department: params.department,
          city: params.city,
          neighborhood: params.neighborhood,
          coverageCities: params.coverageCities,
        ),
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'saveProviderProfile',
          userId: params.userId,
        ).toString(),
      ));
    }
  }
}
