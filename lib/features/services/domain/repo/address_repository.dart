import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/address_suggestion.dart';
import '../entities/geo_coordinates.dart';
import '../entities/service_address.dart';

abstract class AddressRepository {
  Future<Either<Failure, GeoCoordinates>> getCurrentLocation();

  Future<Either<Failure, ServiceAddress>> reverseGeocode(GeoCoordinates coords);

  Future<Either<Failure, List<AddressSuggestion>>> autocomplete(String query);
}
