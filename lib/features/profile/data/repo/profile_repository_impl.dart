import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/core/error/error_mapper.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/features/profile/data/mappers/profile_mappers.dart';
import 'package:domora/features/profile/data/sources/profile_data_source.dart';
import 'package:domora/features/profile/domain/entities/address.dart';
import 'package:domora/features/profile/domain/entities/client_profile.dart';
import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/domain/entities/provider_profile.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;
  final ErrorMapper _errorMapper;

  ProfileRepositoryImpl(this._dataSource, this._errorMapper);

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
}
