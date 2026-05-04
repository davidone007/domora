import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

class UpdateClientProfileParams {
  final String userId;
  final String? bio;
  final String? avatarUrl;

  const UpdateClientProfileParams({
    required this.userId,
    this.bio,
    this.avatarUrl,
  });
}

/// UseCase para actualizar el perfil específico de un cliente.
/// Actualiza `client_profiles` (bio, avatar_url).
class UpdateClientProfileUseCase {
  final ProfileRepository _repository;

  UpdateClientProfileUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UpdateClientProfileParams params) async {
    final updates = <String, dynamic>{};
    
    if (params.bio != null) updates['bio'] = params.bio;
    if (params.avatarUrl != null) updates['avatar_url'] = params.avatarUrl;

    if (updates.isEmpty) {
      return const Right(unit);
    }

    return await _repository.updateProfileFields(params.userId, updates);
  }
}
