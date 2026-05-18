import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/device_position.dart';
import '../repo/location_repository.dart';

/// Caso de uso: obtiene la posición GPS actual del dispositivo.
class GetCurrentLocationUseCase {
  final LocationRepository _repository;

  GetCurrentLocationUseCase(this._repository);

  Future<Either<Failure, DevicePosition>> call() async {
    return _repository.getCurrentPosition();
  }
}
