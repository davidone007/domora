import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/review.dart';
import '../repo/review_repository.dart';

class CheckBookingReviewUseCase {
  final ReviewRepository _repository;

  CheckBookingReviewUseCase(this._repository);

  Future<Either<Failure, Review?>> execute(String bookingId) {
    return _repository.getReviewByBookingId(bookingId);
  }
}
