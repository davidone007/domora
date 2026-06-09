import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/cleaning_service_request.dart';
import '../repo/service_repository.dart';

/// Caso de uso para publicar un servicio de limpieza.
class PublishCleaningServiceUseCase {
  final ServiceRepository _repository;

  PublishCleaningServiceUseCase(this._repository);

  Future<Either<Failure, Unit>> call(CleaningServiceRequest request) async {
    // Aquí se podrían agregar validaciones de negocio adicionales
    // antes de llamar al repositorio.
    
    if (request.title.trim().isEmpty) {
      return const Left(ValidationFailure('El título del servicio es obligatorio'));
    }

    if (request.address.addressLine1.trim().isEmpty) {
      return const Left(ValidationFailure('La dirección del servicio es obligatoria'));
    }

    if (request.address.city.trim().isEmpty) {
      return const Left(ValidationFailure('La ciudad del servicio es obligatoria'));
    }

    return await _repository.publishCleaningService(request);
  }
}
