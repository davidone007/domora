import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/review.dart';
import '../repo/review_repository.dart';

class SendReviewUseCase {
  final ReviewRepository _repository;

  SendReviewUseCase(this._repository);

  Future<Either<Failure, Unit>> execute(Review review) {
    return _repository.sendReview(review);
  }
}
