import 'package:equatable/equatable.dart';

class ProviderReview extends Equatable {
  final String reviewerName;

  /// Rating general (1-5).
  final int rating;
  final String? comment;

  /// Sub-ratings opcionales del MER (null = no calificado por el cliente).
  final int? punctualityRating;
  final int? qualityRating;
  final int? communicationRating;

  final DateTime? createdAt;

  const ProviderReview({
    required this.reviewerName,
    required this.rating,
    this.comment,
    this.punctualityRating,
    this.qualityRating,
    this.communicationRating,
    this.createdAt,
  });

  /// Devuelve true si al menos un sub-rating fue proporcionado.
  bool get hasSubRatings =>
      punctualityRating != null ||
      qualityRating != null ||
      communicationRating != null;

  @override
  List<Object?> get props => [
        reviewerName,
        rating,
        comment,
        punctualityRating,
        qualityRating,
        communicationRating,
        createdAt,
      ];
}
