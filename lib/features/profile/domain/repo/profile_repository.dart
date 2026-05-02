import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/entities/full_profile.dart';

abstract class ProfileRepository {
  /// Devuelve el perfil completo del usuario actual (HU4).
  Future<Either<Failure, FullProfile>> getCurrentProfile();
}
