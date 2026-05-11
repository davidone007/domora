import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/proposal.dart';

/// Contrato para la gestión de propuestas (cotizaciones).
abstract class ProposalRepository {
  /// Envía una propuesta para un servicio.
  Future<Either<Failure, Unit>> sendProposal(Proposal proposal);

  /// Verifica si un proveedor ya envió una propuesta para un servicio específico.
  Future<Either<Failure, bool>> hasUserProposed(String serviceId, String providerId);
}
