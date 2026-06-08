import 'package:equatable/equatable.dart';
import 'proposal.dart';

/// Entidad que combina una propuesta enviada por el proveedor con los datos
/// del servicio al que pertenece. Usada en la pantalla "Mis Propuestas".
class ProposalWithService extends Equatable {
  final Proposal proposal;
  final String serviceTitle;
  final String serviceStatus;

  const ProposalWithService({
    required this.proposal,
    required this.serviceTitle,
    required this.serviceStatus,
  });

  @override
  List<Object?> get props => [proposal, serviceTitle, serviceStatus];
}
