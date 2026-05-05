import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/core/entities/avatar_file.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

/// UseCase para subir la foto de perfil del usuario a Supabase Storage.
/// 
/// Parámetros:
/// - `userId`: ID del usuario
/// - `avatarFile`: Archivo de imagen (bytes + filename)
/// - `isProvider`: true si es proveedor, false si es cliente (para determinar la tabla a actualizar)
/// 
/// Retorna la URL pública de la imagen subida.
class UploadAvatarUseCase {
  final ProfileRepository _repository;

  UploadAvatarUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String userId,
    required AvatarFile avatarFile,
    required bool isProvider,
  }) async {
    // La lógica de subida se delega al repository, que internamente
    // maneja la carga a Storage y la actualización de la DB.
    return await _repository.uploadAvatar(
      userId: userId,
      avatarFile: avatarFile,
      isProvider: isProvider,
    );
  }
}
