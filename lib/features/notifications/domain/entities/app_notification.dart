import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String type; // 'proposal_received', 'service_accepted', 'payment_confirmed', etc.
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedServiceId;
  final String? relatedQuoteId;
  final String? relatedBookingId;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.relatedServiceId,
    this.relatedQuoteId,
    this.relatedBookingId,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        message,
        isRead,
        createdAt,
        relatedServiceId,
        relatedQuoteId,
        relatedBookingId,
      ];
}
