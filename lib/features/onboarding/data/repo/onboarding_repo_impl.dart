import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/onboarding/data/sources/onboarding_data_source.dart';
import 'package:domora/features/onboarding/domain/params/client_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/params/provider_onboarding_params.dart';
import 'package:domora/features/onboarding/domain/repo/onboarding_repo.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingDataSource _dataSource;
  OnboardingRepositoryImpl(this._dataSource);

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
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on StorageException catch (e) {
      return Left(ServerFailure('Error al subir el avatar: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
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
        ),
      );
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on StorageException catch (e) {
      return Left(ServerFailure('Error al subir el avatar: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
