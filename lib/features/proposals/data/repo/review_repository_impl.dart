import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repo/review_repository.dart';
import '../models/review_model.dart';
import '../sources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;
  final FailureMapper _errorMapper;

  ReviewRepositoryImpl(this._remoteDataSource, this._errorMapper);

  @override
  Future<Either<Failure, Unit>> sendReview(Review review) async {
    try {
      final model = ReviewModel.fromEntity(review);
      await _remoteDataSource.sendReview(model);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'sendReview', userId: review.bookingId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Review?>> getReviewByBookingId(String bookingId) async {
    try {
      final model = await _remoteDataSource.getReviewByBookingId(bookingId);
      return Right(model);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'getReviewByBookingId', userId: bookingId).toString(),
      ));
    }
  }
}
