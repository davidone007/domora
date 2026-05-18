import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/device_position.dart';
import '../entities/service_address.dart';

/// Contrato para operaciones de localización del dispositivo.
abstract class LocationRepository {
  /// Obtiene la posición GPS actual del dispositivo.
  Future<Either<Failure, DevicePosition>> getCurrentPosition();

  /// Convierte coordenadas GPS en una dirección legible.
  Future<Either<Failure, ServiceAddress>> reverseGeocode(DevicePosition position);
}
