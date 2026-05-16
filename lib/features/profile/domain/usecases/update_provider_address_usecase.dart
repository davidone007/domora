import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

/// Parámetros de dominio para actualizar la dirección principal de un proveedor.
/// Sin claves de BD — solo conceptos de negocio.
class UpdateProviderAddressParams {
  final String userId;
  final String addressLine1;
  final String? addressLine2;
  final String department;
  final String city;
  final String? neighborhood;

  const UpdateProviderAddressParams({
    required this.userId,
    required this.addressLine1,
    this.addressLine2,
    required this.department,
    required this.city,
    this.neighborhood,
  });
}

/// UseCase para actualizar la dirección principal de un proveedor.
class UpdateProviderAddressUseCase {
  final ProfileRepository repository;

  UpdateProviderAddressUseCase(this.repository);

  Future<Either<Failure, Unit>> call(UpdateProviderAddressParams params) async {
    return repository.updatePrimaryAddress(params);
  }
}