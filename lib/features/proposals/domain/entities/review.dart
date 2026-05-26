import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String? id;
  final String bookingId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  const Review({
    this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, bookingId, rating, comment, createdAt];
}
