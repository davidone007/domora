import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:domora/core/error/failures.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/features/profile/data/source/profile_data_source.dart';
import 'package:domora/features/profile/domain/model/address.dart';
import 'package:domora/features/profile/domain/model/client_profile.dart';
import 'package:domora/features/profile/domain/model/full_profile.dart';
import 'package:domora/features/profile/domain/model/provider_profile.dart';
import 'package:domora/features/profile/domain/model/user.dart';
import 'package:domora/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;
  final SupabaseClient _client;

  ProfileRepositoryImpl(this._dataSource, this._client);

  @override
  Future<Either<Failure, FullProfile>> getCurrentProfile() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        return const Left(AuthFailure('No hay una sesión activa'));
      }
      final userId = authUser.id;

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
        if (cp != null) clientProfile = ClientProfile.fromMap(cp);
      } else if (role == AppConstants.roleProvider) {
        final pp = await _dataSource.getProviderProfile(userId);
        if (pp != null) providerProfile = ProviderProfile.fromMap(pp);

        final addr = await _dataSource.getPrimaryAddress(userId);
        if (addr != null) primaryAddress = Address.fromMap(addr);
      }

      return Right(
        FullProfile(
          user: User.fromMap(userMap),
          role: role,
          clientProfile: clientProfile,
          providerProfile: providerProfile,
          primaryAddress: primaryAddress,
        ),
      );
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
