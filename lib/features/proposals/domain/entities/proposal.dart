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

  Proposal copyWith({
    String? id,
    String? serviceId,
    String? providerId,
    double? price,
    double? estimatedHours,
    String? message,
    String? status,
    DateTime? createdAt,
  }) {
    return Proposal(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      price: price ?? this.price,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
