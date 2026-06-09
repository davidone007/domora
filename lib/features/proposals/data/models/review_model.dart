import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    super.id,
    required super.bookingId,
    required super.rating,
    super.comment,
    super.punctualityRating,
    super.qualityRating,
    super.communicationRating,
    super.reviewerType,
    super.reviewerId,
    super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String?,
      bookingId: json['booking_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      punctualityRating: json['punctuality_rating'] as int?,
      qualityRating: json['quality_rating'] as int?,
      communicationRating: json['communication_rating'] as int?,
      reviewerType: json['reviewer_type'] as String?,
      reviewerId: json['reviewer_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'rating': rating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
      if (punctualityRating != null) 'punctuality_rating': punctualityRating,
      if (qualityRating != null) 'quality_rating': qualityRating,
      if (communicationRating != null)
        'communication_rating': communicationRating,
      // Campos de dirección — solo se envían cuando la migración DB ya fue aplicada.
      if (reviewerType != null) 'reviewer_type': reviewerType,
      if (reviewerId != null) 'reviewer_id': reviewerId,
    };
  }

  factory ReviewModel.fromEntity(Review entity) {
    return ReviewModel(
      bookingId: entity.bookingId,
      rating: entity.rating,
      comment: entity.comment,
      punctualityRating: entity.punctualityRating,
      qualityRating: entity.qualityRating,
      communicationRating: entity.communicationRating,
      reviewerType: entity.reviewerType,
      reviewerId: entity.reviewerId,
    );
  }
}
