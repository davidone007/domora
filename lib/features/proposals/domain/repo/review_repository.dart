import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  /// Envía una calificación para un booking específico.
  Future<Either<Failure, Unit>> sendReview(Review review);

  /// Verifica si un booking ya tiene una calificación.
  Future<Either<Failure, Review?>> getReviewByBookingId(String bookingId);
}
