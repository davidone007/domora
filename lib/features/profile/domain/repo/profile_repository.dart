import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/core/entities/avatar_file.dart';
import 'package:domora/features/profile/domain/entities/full_profile.dart';
import 'package:domora/features/profile/domain/entities/provider_stats.dart';
import 'package:domora/features/profile/domain/params/profile_params.dart';

abstract class ProfileRepository {
  /// Devuelve el perfil completo del usuario actual (HU4).
  Future<Either<Failure, FullProfile>> getCurrentProfile();

  /// Actualiza los campos básicos del usuario (nombre, apellido, teléfono).
  Future<Either<Failure, Unit>> updateUserFields(UpdateUserFieldsParams params);

  /// Actualiza los campos del perfil de un cliente (bio, avatarUrl).
  Future<Either<Failure, Unit>> updateClientProfileFields(UpdateClientProfileParams params);

  /// Actualiza los campos del perfil de un proveedor (experiencia, tarifa, etc.).
  Future<Either<Failure, Unit>> updateProviderProfileFields(UpdateProviderProfileParams params);

  /// Actualiza la dirección principal del usuario.
  Future<Either<Failure, Unit>> updatePrimaryAddress(UpdateProviderAddressParams params);

  /// Sube la foto de perfil a Supabase Storage y actualiza la DB.
  /// Retorna la URL pública de la imagen.
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required AvatarFile avatarFile,
    required bool isProvider,
  });

  /// Devuelve el perfil completo de un proveedor por su ID de usuario.
  Future<Either<Failure, FullProfile>> getProviderProfileById(String userId);

  /// Obtiene las estadísticas de un proveedor (rating, servicios completados).
  Future<Either<Failure, ProviderStats>> getProviderStats(String providerId);

}
