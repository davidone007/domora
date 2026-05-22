import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.quoteId,
    required super.serviceId,
    required super.clientId,
    required super.providerId,
    required super.status,
    required super.finalPrice,
    required super.createdAt,
    super.startedAt,
    super.completedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      quoteId: json['quote_id'],
      serviceId: json['service_id'],
      clientId: json['client_id'],
      providerId: json['provider_id'],
      status: json['status'],
      finalPrice: (json['final_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote_id': quoteId,
      'service_id': serviceId,
      'client_id': clientId,
      'provider_id': providerId,
      'status': status,
      'final_price': finalPrice,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
