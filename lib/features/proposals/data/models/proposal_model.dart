import '../../domain/entities/proposal.dart';

class ProposalModel extends Proposal {
  const ProposalModel({
    super.id,
    required super.serviceId,
    required super.providerId,
    required super.price,
    super.estimatedHours,
    super.message,
    super.status,
    super.createdAt,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      id: json['id'],
      serviceId: json['service_id'],
      providerId: json['provider_id'],
      price: (json['price'] as num).toDouble(),
      estimatedHours: json['estimated_hours'] != null
          ? (json['estimated_hours'] as num).toDouble()
          : null,
      message: json['message'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'provider_id': providerId,
      'price': price,
      'estimated_hours': estimatedHours,
      'message': message,
      'status': status,
    };
  }

  factory ProposalModel.fromEntity(Proposal proposal) {
    return ProposalModel(
      id: proposal.id,
      serviceId: proposal.serviceId,
      providerId: proposal.providerId,
      price: proposal.price,
      estimatedHours: proposal.estimatedHours,
      message: proposal.message,
      status: proposal.status,
      createdAt: proposal.createdAt,
    );
  }
}
