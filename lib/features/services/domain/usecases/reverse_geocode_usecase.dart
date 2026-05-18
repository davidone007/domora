import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/device_position.dart';
import '../entities/service_address.dart';
import '../repo/location_repository.dart';

/// Caso de uso: convierte coordenadas GPS en una [ServiceAddress] legible.
class ReverseGeocodeUseCase {
  final LocationRepository _repository;

  ReverseGeocodeUseCase(this._repository);

  Future<Either<Failure, ServiceAddress>> call(DevicePosition position) async {
    return _repository.reverseGeocode(position);
  }
}
