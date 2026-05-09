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
      return const Left(ValidationFailure('El título no puede estar vacío'));
    }

    return await _repository.publishCleaningService(request);
  }
}
