import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/entities/avatar_file.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';
import 'package:domora/features/profile/data/sources/profile_data_source.dart';
import 'package:domora/features/profile/domain/entities/address.dart';
import 'package:domora/features/profile/domain/entities/client_profile.dart';
import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/domain/entities/provider_profile.dart';
import 'package:domora/features/profile/domain/entities/provider_review.dart';
import 'package:domora/features/profile/domain/entities/provider_stats.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';
import 'package:domora/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_client_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_provider_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_provider_address_usecase.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;
  final AuthRepository _authRepository;
  final FailureMapper _errorMapper;

  ProfileRepositoryImpl(
    this._dataSource,
    this._authRepository,
    this._errorMapper,
  );

  @override
  Future<Either<Failure, FullProfile>> getCurrentProfile() async {
    String? userId;
    try {
      userId = _dataSource.getCurrentUserId();
      if (userId == null) {
        return const Left(AuthFailure('No hay una sesión activa'));
      }

      var user = await _dataSource.getUser(userId);
      if (user == null) {
        return const Left(ServerFailure('Usuario no encontrado'));
      }

      final authEmail = _dataSource.getCurrentUserEmail();
      if (authEmail != null && authEmail.isNotEmpty) {
        user = user.copyWith(email: authEmail);
      }

      final role = await _dataSource.getRole(userId);
      if (role == null) {
        return const Left(ServerFailure('No se encontró el rol del usuario'));
      }

      ClientProfile? clientProfile;
      ProviderProfile? providerProfile;
      Address? primaryAddress;
      var reviews = const <ProviderReview>[];

      if (role == AppConstants.roleClient) {
        clientProfile = await _dataSource.getClientProfile(userId);
      } else if (role == AppConstants.roleProvider) {
        providerProfile = await _dataSource.getProviderProfile(userId);
        primaryAddress = await _dataSource.getPrimaryAddress(userId);
        reviews = await _dataSource.getProviderReviews(userId);
      }

      return Right(
        FullProfile(
          user: user,
          role: role,
          clientProfile: clientProfile,
          providerProfile: providerProfile,
          primaryAddress: primaryAddress,
          reviews: reviews,
        ),
      );
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'getCurrentProfile',
          userId: userId,
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserFields(UpdateUserFieldsParams params) async {
    try {
      final dbMap = <String, dynamic>{
        if (params.firstName != null) 'first_name': params.firstName,
        if (params.lastName  != null) 'last_name':  params.lastName,
        if (params.phone     != null) 'phone':       params.phone,
      };

      if (dbMap.isEmpty) {
        return const Left(ValidationFailure('No hay campos válidos para actualizar'));
      }

      await _dataSource.updateUser(params.userId, dbMap);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'updateUserFields', userId: params.userId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateClientProfileFields(UpdateClientProfileParams params) async {
    try {
      final dbMap = <String, dynamic>{
        if (params.bio       != null) 'bio':        params.bio,
        if (params.avatarUrl != null) 'avatar_url': params.avatarUrl,
      };

      if (dbMap.isEmpty) {
        return const Left(ValidationFailure('No hay campos válidos para actualizar'));
      }

      await _dataSource.updateClientProfile(params.userId, dbMap);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'updateClientProfileFields', userId: params.userId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProviderProfileFields(UpdateProviderProfileParams params) async {
    try {
      final dbMap = <String, dynamic>{
        if (params.yearsExperience != null) 'years_experience': params.yearsExperience,
        if (params.hourlyRate      != null) 'hourly_rate':      params.hourlyRate,
        if (params.isAvailable     != null) 'is_available':     params.isAvailable,
        if (params.bio             != null) 'bio':              params.bio,
        if (params.avatarUrl       != null) 'avatar_url':       params.avatarUrl,
      };

      if (dbMap.isEmpty) {
        return const Left(ValidationFailure('No hay campos válidos para actualizar'));
      }

      await _dataSource.updateProviderProfile(params.userId, dbMap);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'updateProviderProfileFields', userId: params.userId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePrimaryAddress(UpdateProviderAddressParams params) async {
    try {
      final dbMap = <String, dynamic>{
        'address_line1': params.addressLine1,
        if (params.addressLine2 != null) 'address_line2': params.addressLine2,
        'department':  params.department,
        'city':        params.city,
        if (params.neighborhood != null) 'neighborhood': params.neighborhood,
      };

      await _dataSource.updatePrimaryAddress(params.userId, dbMap);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'updatePrimaryAddress', userId: params.userId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required AvatarFile avatarFile,
    required bool isProvider,
  }) async {
    try {
      final publicUrl = await _dataSource.uploadAvatar(
        userId: userId,
        avatarFile: avatarFile,
        isProvider: isProvider,
      );

      if (isProvider) {
        await _dataSource.updateProviderProfile(userId, {'avatar_url': publicUrl});
      } else {
        await _dataSource.updateClientProfile(userId, {'avatar_url': publicUrl});
      }

      return Right(publicUrl);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'uploadAvatar', userId: userId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, FullProfile>> getProviderProfileById(String userId) async {
    try {
      final user = await _dataSource.getUser(userId);
      if (user == null) {
        return const Left(ServerFailure('Proveedor no encontrado'));
      }

      final role = await _dataSource.getRole(userId);
      if (role != AppConstants.roleProvider) {
        return const Left(ValidationFailure('El usuario no es un proveedor'));
      }

      ProviderProfile? providerProfile;
      Address? primaryAddress;

      providerProfile = await _dataSource.getProviderProfile(userId);
      primaryAddress = await _dataSource.getPrimaryAddress(userId);

      // Cargamos las estadísticas reales
      final statsResult = await getProviderStats(userId);
      final ProviderStats? stats = statsResult.fold((_) => null, (s) => s);
      final reviews = await _dataSource.getProviderReviews(userId);

      return Right(
        FullProfile(
          user: user,
          role: role!,
          providerProfile: providerProfile,
          primaryAddress: primaryAddress,
          stats: stats,
          reviews: reviews,
        ),
      );
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'getProviderProfileById',
          userId: userId,
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, ProviderStats>> getProviderStats(String providerId) async {
    try {
      final completedCount = await _dataSource.getCompletedServicesCount(providerId);
      final reviewsData = await _dataSource.getReviewsStats(providerId);

      return Right(ProviderStats(
        averageRating: (reviewsData['average_rating'] as num).toDouble(),
        totalReviewsCount: reviewsData['total_reviews'] as int,
        completedServicesCount: completedCount,
      ));
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'getProviderStats',
          userId: providerId,
        ).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmail({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  }) =>
      _authRepository.updateEmail(
        currentEmail: currentEmail,
        currentPassword: currentPassword,
        newEmail: newEmail,
      );

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _authRepository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}
