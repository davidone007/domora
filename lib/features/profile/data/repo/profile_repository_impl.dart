import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/entities/avatar_file.dart';
import 'package:domora/features/profile/data/mappers/profile_mappers.dart';
import 'package:domora/features/profile/data/sources/profile_data_source.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';
import 'package:domora/features/profile/domain/entities/address.dart';
import 'package:domora/features/profile/domain/entities/client_profile.dart';
import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/domain/entities/provider_profile.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;
  final AuthRepository _authRepository;
  final FailureMapper _errorMapper;

  ProfileRepositoryImpl(this._dataSource, this._authRepository, this._errorMapper);

  @override
  Future<Either<Failure, FullProfile>> getCurrentProfile() async {
    String? userId;
    try {
      userId = _dataSource.getCurrentUserId();
      if (userId == null) {
        return const Left(AuthFailure('No hay una sesión activa'));
      }

      final userMap = await _dataSource.getUser(userId);
      if (userMap == null) {
        return const Left(ServerFailure('Usuario no encontrado'));
      }

      final authEmail = _authRepository.currentUserEmail;
      if (authEmail != null && authEmail.isNotEmpty) {
        userMap['email'] = authEmail;
      }

      final role = await _dataSource.getRole(userId);
      if (role == null) {
        return const Left(ServerFailure('No se encontró el rol del usuario'));
      }

      ClientProfile? clientProfile;
      ProviderProfile? providerProfile;
      Address? primaryAddress;

      if (role == AppConstants.roleClient) {
        final cp = await _dataSource.getClientProfile(userId);
        if (cp != null) clientProfile = ProfileMappers.clientProfileFromMap(cp);
      } else if (role == AppConstants.roleProvider) {
        final pp = await _dataSource.getProviderProfile(userId);
        if (pp != null) {
          providerProfile = ProfileMappers.providerProfileFromMap(pp);
        }

        final addr = await _dataSource.getPrimaryAddress(userId);
        if (addr != null) primaryAddress = ProfileMappers.addressFromMap(addr);
      }

      return Right(
        FullProfile(
          user: ProfileMappers.userFromMap(userMap),
          role: role,
          clientProfile: clientProfile,
          providerProfile: providerProfile,
          primaryAddress: primaryAddress,
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
  Future<Either<Failure, Unit>> updateUserFields(String userId, Map<String, dynamic> updates) async {
    try {
      final allowedUpdates = _pickAllowedFields(updates, {'first_name', 'last_name', 'phone'});
      if (allowedUpdates.isEmpty) {
        return const Left(ValidationFailure('No hay campos válidos para actualizar'));
      }

      await _dataSource.updateUser(userId, allowedUpdates);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'updateUserFields', userId: userId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProfileFields(String userId, Map<String, dynamic> updates) async {
    try {
      final userUpdates = _pickAllowedFields(updates, {'first_name', 'last_name', 'phone'});
      if (userUpdates.isNotEmpty) {
        await _dataSource.updateUser(userId, userUpdates);
        return const Right(unit);
      }

      final role = await _dataSource.getRole(userId);
      if (role == AppConstants.roleClient) {
        final clientUpdates = _pickAllowedFields(updates, {'avatar_url', 'bio'});
        if (clientUpdates.isEmpty) {
          return const Left(ValidationFailure('No hay campos válidos para actualizar'));
        }
        await _dataSource.updateClientProfile(userId, clientUpdates);
      } else if (role == AppConstants.roleProvider) {
        final providerUpdates = _pickAllowedFields(
          updates,
          {'years_experience', 'hourly_rate', 'is_available', 'bio', 'avatar_url'},
        );
        if (providerUpdates.isEmpty) {
          return const Left(ValidationFailure('No hay campos válidos para actualizar'));
        }
        await _dataSource.updateProviderProfile(userId, providerUpdates);
      } else {
        return const Left(ServerFailure('No se pudo determinar el rol del usuario'));
      }

      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'updateProfileFields', userId: userId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePrimaryAddress(String userId, Map<String, dynamic> updates) async {
    try {
      final addressUpdates = _pickAllowedFields(
        updates,
        {'address_line1', 'address_line2', 'department', 'city', 'neighborhood'},
      );

      if (addressUpdates.isEmpty) {
        return const Left(ValidationFailure('No hay campos válidos para actualizar'));
      }

      await _dataSource.updatePrimaryAddress(userId, addressUpdates);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'updatePrimaryAddress', userId: userId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateEmail({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  }) async {
    final result = await _authRepository.updateEmail(
      currentEmail: currentEmail,
      currentPassword: currentPassword,
      newEmail: newEmail,
    );
    return result.map((_) => unit);
  }

  @override
  Future<Either<Failure, Unit>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final result = await _authRepository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    return result.map((_) => unit);
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

      // Update the appropriate profile table with the new avatar URL
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
      final userMap = await _dataSource.getUser(userId);
      if (userMap == null) {
        return const Left(ServerFailure('Proveedor no encontrado'));
      }

      final role = await _dataSource.getRole(userId);
      if (role != AppConstants.roleProvider) {
        return const Left(ValidationFailure('El usuario no es un proveedor'));
      }

      ProviderProfile? providerProfile;
      Address? primaryAddress;

      final pp = await _dataSource.getProviderProfile(userId);
      if (pp != null) {
        providerProfile = ProfileMappers.providerProfileFromMap(pp);
      }

      final addr = await _dataSource.getPrimaryAddress(userId);
      if (addr != null) primaryAddress = ProfileMappers.addressFromMap(addr);

      return Right(
        FullProfile(
          user: ProfileMappers.userFromMap(userMap),
          role: role!,
          providerProfile: providerProfile,
          primaryAddress: primaryAddress,
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

  Map<String, dynamic> _pickAllowedFields(
    Map<String, dynamic> updates,
    Set<String> allowedFields,
  ) {
    return Map<String, dynamic>.fromEntries(
      updates.entries.where((entry) => allowedFields.contains(entry.key) && entry.value != null),
    );
  }
}
