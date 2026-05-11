import 'package:equatable/equatable.dart';

/// Entidad que representa una propuesta o cotización de un proveedor.
class Proposal extends Equatable {
  final String? id;
  final String serviceId;
  final String providerId;
  final double price;
  final double? estimatedHours;
  final String? message;
  final String status;
  final DateTime? createdAt;

  const Proposal({
    this.id,
    required this.serviceId,
    required this.providerId,
    required this.price,
    this.estimatedHours,
    this.message,
    this.status = 'pending',
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        serviceId,
        providerId,
        price,
        estimatedHours,
        message,
        status,
        createdAt,
      ];
}
