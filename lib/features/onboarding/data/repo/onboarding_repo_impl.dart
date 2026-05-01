import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/onboarding/data/sources/onboarding_data_source.dart';
import 'package:domora/features/onboarding/domain/repo/onboarding_repo.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingDataSource _dataSource;
  OnboardingRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> saveClientProfile(
      ClientOnboardingData data) async {
    try {
      await _dataSource.saveClientProfile(data);
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
      ProviderOnboardingData data) async {
    try {
      await _dataSource.saveProviderProfile(data);
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
