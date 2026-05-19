import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/cleaning_service_request.dart';
import '../entities/service.dart';
import '../entities/service_detail.dart';

/// Contrato para la gestión de servicios.
abstract class ServiceRepository {
  /// Publica una solicitud de servicio de limpieza con sus imágenes.
  Future<Either<Failure, Unit>> publishCleaningService(
      CleaningServiceRequest request);

  /// Obtiene la lista de servicios publicados por un usuario (cliente).
  Future<Either<Failure, List<Service>>> getMyServices(String userId);

  /// Obtiene todos los servicios disponibles (para proveedores).
  Future<Either<Failure, List<Service>>> getAllAvailableServices();

  /// Obtiene el detalle de un servicio por su ID.
  Future<Either<Failure, ServiceDetail>> getServiceById(String id);
}
