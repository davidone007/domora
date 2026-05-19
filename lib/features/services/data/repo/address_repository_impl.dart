import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/address_suggestion.dart';
import '../../domain/entities/geo_coordinates.dart';
import '../../domain/entities/service_address.dart';
import '../../domain/repo/address_repository.dart';
import '../sources/address_remote_data_source.dart';
import '../sources/location_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;
  final LocationDataSource _locationDataSource;
  final FailureMapper _errorMapper;

  AddressRepositoryImpl(
    this._remoteDataSource,
    this._locationDataSource,
    this._errorMapper,
  );

  @override
  Future<Either<Failure, GeoCoordinates>> getCurrentLocation() async {
    try {
      final coords = await _locationDataSource.getCurrentCoordinates();
      return Right(coords);
    } catch (e, stackTrace) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'getCurrentLocation').toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<AddressSuggestion>>> autocomplete(String query) async {
    try {
      final suggestions = await _remoteDataSource.autocomplete(query);
      return Right(suggestions);
    } catch (e, stackTrace) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'autocomplete', parameters: {'query': query}).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, ServiceAddress>> reverseGeocode(GeoCoordinates coords) async {
    try {
      final address = await _remoteDataSource.reverseGeocode(
        latitude: coords.latitude,
        longitude: coords.longitude,
      );
      return Right(address);
    } catch (e, stackTrace) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'reverseGeocode').toString(),
      ));
    }
  }
}
