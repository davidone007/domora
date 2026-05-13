import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/core/entities/avatar_file.dart';
import 'package:domora/features/profile/domain/entities/full_profile.dart';

abstract class ProfileRepository {
  /// Devuelve el perfil completo del usuario actual (HU4).
  Future<Either<Failure, FullProfile>> getCurrentProfile();

  /// Actualiza campos del usuario en la tabla `users` (por ejemplo: nombres, apellidos, teléfono).
  Future<Either<Failure, Unit>> updateUserFields(String userId, Map<String, dynamic> updates);

  /// Actualiza campos del perfil específico (client o provider) asociados al usuario.
  Future<Either<Failure, Unit>> updateProfileFields(String userId, Map<String, dynamic> updates);

  /// Actualiza la dirección principal del usuario.
  Future<Either<Failure, Unit>> updatePrimaryAddress(String userId, Map<String, dynamic> updates);

  /// Reautentica con el correo y contraseña actual antes de cambiar el correo en Auth.
  Future<Either<Failure, Unit>> updateEmail({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  });

  /// Reautentica con la contraseña actual y actualiza la contraseña en Auth.
  Future<Either<Failure, Unit>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Sube la foto de perfil a Supabase Storage y actualiza la DB.
  /// Retorna la URL pública de la imagen.
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required AvatarFile avatarFile,
    required bool isProvider,
  });

  /// Devuelve el perfil completo de un proveedor por su ID de usuario.
  Future<Either<Failure, FullProfile>> getProviderProfileById(String userId);
}
