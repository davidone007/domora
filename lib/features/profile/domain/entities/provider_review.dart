import 'package:equatable/equatable.dart';

class ProviderReview extends Equatable {
  final String reviewerName;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  const ProviderReview({
    required this.reviewerName,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  @override
  List<Object?> get props => [reviewerName, rating, comment, createdAt];
}
