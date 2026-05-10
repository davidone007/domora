import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/cleaning_service_request.dart';

/// Contrato para la gestión de servicios.
abstract class ServiceRepository {
  /// Publica una solicitud de servicio de limpieza con sus imágenes.
  Future<Either<Failure, Unit>> publishCleaningService(
      CleaningServiceRequest request);
}
