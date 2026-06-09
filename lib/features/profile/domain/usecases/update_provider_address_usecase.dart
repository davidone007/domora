import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/params/profile_params.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

export 'package:domora/features/profile/domain/params/profile_params.dart'
    show UpdateProviderAddressParams;

/// UseCase para actualizar la dirección principal de un proveedor.
class UpdateProviderAddressUseCase {
  final ProfileRepository repository;

  UpdateProviderAddressUseCase(this.repository);

  Future<Either<Failure, Unit>> call(UpdateProviderAddressParams params) async {
    return repository.updatePrimaryAddress(params);
  }
}