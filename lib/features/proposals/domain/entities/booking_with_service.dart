import 'package:equatable/equatable.dart';
import 'package:domora/features/services/domain/entities/service.dart';
import 'booking.dart';

class BookingWithService extends Equatable {
  final Booking booking;
  final Service service;
  final String otherPartyName;
  final String? otherPartyAvatarUrl;

  /// true si el cliente ya envió su reseña sobre el proveedor.
  final bool hasReview;
  final int? reviewRating;
  final String? reviewComment;

  /// true si el proveedor ya envió su reseña sobre el cliente.
  /// Requiere migración DB (reviewer_type). Mientras tanto, siempre false.
  final bool hasProviderReview;

  const BookingWithService({
    required this.booking,
    required this.service,
    required this.otherPartyName,
    this.otherPartyAvatarUrl,
    this.hasReview = false,
    this.reviewRating,
    this.reviewComment,
    this.hasProviderReview = false,
  });

  @override
  List<Object?> get props => [
        booking,
        service,
        otherPartyName,
        otherPartyAvatarUrl,
        hasReview,
        reviewRating,
        reviewComment,
        hasProviderReview,
      ];
}
