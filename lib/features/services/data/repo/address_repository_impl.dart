import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/address_suggestion.dart';
import '../../domain/entities/geo_coordinates.dart';
import '../../domain/entities/service_address.dart';
import '../../domain/repo/address_repository.dart';
import '../models/address_suggestion_model.dart';
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
      final raw = await _locationDataSource.getCurrentCoordinates();
      final coords = GeoCoordinates(
        latitude: raw.latitude,
        longitude: raw.longitude,
      );
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
      final rawFeatures = await _remoteDataSource.autocomplete(query);
      final suggestions = rawFeatures
          .map((item) => AddressSuggestionModel.fromGeoapifyJson(item))
          .toList();
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
      final rawJson = await _remoteDataSource.reverseGeocode(
        latitude: coords.latitude,
        longitude: coords.longitude,
      );

      final features = (rawJson['features'] as List?) ?? [];
      if (features.isEmpty) {
        return const Right(ServiceAddress(addressLine1: '', city: ''));
      }

      final properties =
          (features.first as Map<String, dynamic>)['properties'] as Map<String, dynamic>? ?? {};

      final addressLine1 = properties['address_line1']?.toString() ??
          properties['street']?.toString() ??
          properties['formatted']?.toString() ??
          '';
      final city = properties['city']?.toString() ??
          properties['town']?.toString() ??
          properties['village']?.toString() ??
          properties['county']?.toString() ??
          '';
      final neighborhood = properties['neighbourhood']?.toString() ??
          properties['neighborhood']?.toString() ??
          properties['suburb']?.toString() ??
          properties['district']?.toString() ??
          properties['quarter']?.toString();

      return Right(ServiceAddress(
        addressLine1: addressLine1,
        addressLine2: properties['address_line2']?.toString(),
        city: city,
        neighborhood: neighborhood,
        latitude: (properties['lat'] as num?)?.toDouble(),
        longitude: (properties['lon'] as num?)?.toDouble(),
      ));
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
