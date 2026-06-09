import '../../domain/entities/proposal_with_service.dart';
import 'proposal_model.dart';

class ProposalWithServiceModel extends ProposalWithService {
  const ProposalWithServiceModel({
    required super.proposal,
    required super.serviceTitle,
    required super.serviceStatus,
  });

  factory ProposalWithServiceModel.fromJson(Map<String, dynamic> json) {
    // Estructura de la query de Supabase:
    // quotes { ..., services: { title, status } }
    final serviceData = json['services'] as Map<String, dynamic>?;

    return ProposalWithServiceModel(
      proposal: ProposalModel.fromJson(json),
      serviceTitle: serviceData?['title'] ?? 'Servicio sin título',
      serviceStatus: serviceData?['status'] ?? 'unknown',
    );
  }
}
