import 'package:dartz/dartz.dart';

import 'package:domora/core/error/failures.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';

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

class UpdateProviderAddressUseCase {
  final ProfileRepository repository;

  UpdateProviderAddressUseCase(this.repository);

  Future<Either<Failure, Unit>> call(UpdateProviderAddressParams params) async {
    final updates = <String, dynamic>{
      'address_line1': params.addressLine1,
      if (params.addressLine2 != null) 'address_line2': params.addressLine2,
      'department': params.department,
      'city': params.city,
      if (params.neighborhood != null) 'neighborhood': params.neighborhood,
    };

    return repository.updatePrimaryAddress(params.userId, updates);
  }
}