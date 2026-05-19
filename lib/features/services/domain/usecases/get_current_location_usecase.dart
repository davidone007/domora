import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/geo_coordinates.dart';
import '../repo/address_repository.dart';

class GetCurrentLocationUseCase {
  final AddressRepository repository;

  GetCurrentLocationUseCase(this.repository);

  Future<Either<Failure, GeoCoordinates>> call() {
    return repository.getCurrentLocation();
  }
}
