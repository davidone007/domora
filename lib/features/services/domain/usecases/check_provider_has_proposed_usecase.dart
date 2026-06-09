import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../repo/service_repository.dart';

/// Comprueba si un proveedor ya envió una propuesta para un servicio dado.
///
/// Vive en el feature `services` porque la pantalla de detalle del servicio
/// es quien lo necesita. El acceso a datos se delega a [ServiceRepository],
/// que internamente consulta la tabla `quotes` a través de
/// [ServiceRemoteDataSource] — sin dependencias cross-feature.
class CheckProviderHasProposedUseCase {
  final ServiceRepository _repository;

  CheckProviderHasProposedUseCase(this._repository);

  Future<Either<Failure, bool>> execute(
      String serviceId, String providerId) {
    return _repository.hasUserProposed(serviceId, providerId);
  }
}
