import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/geo_coordinates.dart';
import '../entities/service_address.dart';
import '../repo/address_repository.dart';

class ReverseGeocodeUseCase {
  final AddressRepository repository;

  ReverseGeocodeUseCase(this.repository);

  Future<Either<Failure, ServiceAddress>> call(GeoCoordinates coords) {
    return repository.reverseGeocode(coords);
  }
}
