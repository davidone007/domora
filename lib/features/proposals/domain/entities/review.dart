import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String? id;
  final String bookingId;

  /// Rating general obligatorio (1-5).
  final int rating;
  final String? comment;

  /// Sub-ratings opcionales del MER (null = no calificado).
  final int? punctualityRating;
  final int? qualityRating;
  final int? communicationRating;

  /// Dirección de la reseña (requiere migración DB).
  /// 'client' = cliente califica al proveedor.
  /// 'provider' = proveedor califica al cliente.
  /// null = reseña legada sin dirección.
  final String? reviewerType;

  /// ID del usuario que escribe la reseña (requiere migración DB).
  final String? reviewerId;

  final DateTime? createdAt;

  const Review({
    this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
    this.punctualityRating,
    this.qualityRating,
    this.communicationRating,
    this.reviewerType,
    this.reviewerId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        rating,
        comment,
        punctualityRating,
        qualityRating,
        communicationRating,
        reviewerType,
        reviewerId,
        createdAt,
      ];
}
