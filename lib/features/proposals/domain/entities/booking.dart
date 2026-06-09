import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String quoteId;
  final String serviceId;
  final String clientId;
  final String providerId;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final double finalPrice;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const Booking({
    required this.id,
    required this.quoteId,
    required this.serviceId,
    required this.clientId,
    required this.providerId,
    required this.status,
    required this.finalPrice,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        quoteId,
        serviceId,
        clientId,
        providerId,
        status,
        finalPrice,
        createdAt,
        startedAt,
        completedAt,
      ];
}
