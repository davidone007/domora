import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/cleaning_service_request.dart';
import '../entities/service.dart';

/// Contrato para la gestión de servicios.
abstract class ServiceRepository {
  /// Publica una solicitud de servicio de limpieza con sus imágenes.
  Future<Either<Failure, Unit>> publishCleaningService(
      CleaningServiceRequest request);

  /// Obtiene la lista de servicios publicados por un usuario (cliente).
  Future<Either<Failure, List<Service>>> getMyServices(String userId);
}
