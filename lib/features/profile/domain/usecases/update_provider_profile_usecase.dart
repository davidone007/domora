import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

class UpdateProviderProfileParams {
  final String userId;
  final int? yearsExperience;
  final double? hourlyRate;
  final bool? isAvailable;
  final String? bio;
  final String? avatarUrl;

  const UpdateProviderProfileParams({
    required this.userId,
    this.yearsExperience,
    this.hourlyRate,
    this.isAvailable,
    this.bio,
    this.avatarUrl,
  });
}

/// UseCase para actualizar el perfil específico de un proveedor.
/// Actualiza `provider_profiles` (years_experience, hourly_rate, is_available, bio, avatar_url).
class UpdateProviderProfileUseCase {
  final ProfileRepository _repository;

  UpdateProviderProfileUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UpdateProviderProfileParams params) async {
    final updates = <String, dynamic>{};
    
    if (params.yearsExperience != null) updates['years_experience'] = params.yearsExperience;
    if (params.hourlyRate != null) updates['hourly_rate'] = params.hourlyRate;
    if (params.isAvailable != null) updates['is_available'] = params.isAvailable;
    if (params.bio != null) updates['bio'] = params.bio;
    if (params.avatarUrl != null) updates['avatar_url'] = params.avatarUrl;

    if (updates.isEmpty) {
      return const Right(unit);
    }

    return await _repository.updateProfileFields(params.userId, updates);
  }
}
