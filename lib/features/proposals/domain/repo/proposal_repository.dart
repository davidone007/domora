import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/proposal.dart';
import '../entities/proposal_with_provider.dart';

/// Contrato para la gestión de propuestas (cotizaciones).
abstract class ProposalRepository {
  /// Envía una propuesta para un servicio.
  Future<Either<Failure, Unit>> sendProposal(Proposal proposal);

  /// Verifica si un proveedor ya envió una propuesta para un servicio específico.
  Future<Either<Failure, bool>> hasUserProposed(String serviceId, String providerId);

  /// Obtiene todas las propuestas para un servicio específico.
  /// Requiere [clientId] para validar la propiedad del servicio.
  Future<Either<Failure, List<ProposalWithProvider>>> getProposalsByServiceId({
    required String serviceId,
    required String clientId,
  });

  /// Acepta una propuesta, creando un booking y actualizando los estados de las entidades relacionadas.
  Future<Either<Failure, Unit>> acceptProposal(Proposal proposal);
}
