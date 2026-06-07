import '../../domain/entities/provider_review.dart';

class ProviderReviewModel extends ProviderReview {
  const ProviderReviewModel({
    required super.reviewerName,
    required super.rating,
    super.comment,
    super.punctualityRating,
    super.qualityRating,
    super.communicationRating,
    super.createdAt,
  });

  factory ProviderReviewModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? reviewerData;
    final bookings = json['bookings'];
    if (bookings is Map) {
      reviewerData = bookings['users!bookings_client_id_fkey']
          as Map<String, dynamic>?;
    }
    final firstName = reviewerData?['first_name'] as String?;
    final lastName = reviewerData?['last_name'] as String?;
    final nameParts = <String>[];
    if (firstName != null && firstName.isNotEmpty) nameParts.add(firstName);
    if (lastName != null && lastName.isNotEmpty) nameParts.add(lastName);

    return ProviderReviewModel(
      reviewerName: nameParts.isNotEmpty ? nameParts.join(' ') : 'Cliente',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      punctualityRating: json['punctuality_rating'] as int?,
      qualityRating: json['quality_rating'] as int?,
      communicationRating: json['communication_rating'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
