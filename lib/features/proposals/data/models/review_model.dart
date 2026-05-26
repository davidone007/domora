import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    super.id,
    required super.bookingId,
    required super.rating,
    super.comment,
    super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
    };
  }

  factory ReviewModel.fromEntity(Review entity) {
    return ReviewModel(
      bookingId: entity.bookingId,
      rating: entity.rating,
      comment: entity.comment,
    );
  }
}
