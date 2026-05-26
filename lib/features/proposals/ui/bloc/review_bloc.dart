import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/send_review_usecase.dart';
import '../../domain/usecases/check_booking_review_usecase.dart';

// Events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class SendReviewRequestedEvent extends ReviewEvent {
  final String bookingId;
  final int rating;
  final String? comment;

  const SendReviewRequestedEvent({
    required this.bookingId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [bookingId, rating, comment];
}

class CheckReviewStatusEvent extends ReviewEvent {
  final String bookingId;
  const CheckReviewStatusEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

// States
enum ReviewStatus { initial, loading, success, error, alreadyReviewed }

class ReviewState extends Equatable {
  final ReviewStatus status;
  final String? errorMessage;
  final Review? existingReview;

  const ReviewState({
    this.status = ReviewStatus.initial,
    this.errorMessage,
    this.existingReview,
  });

  ReviewState copyWith({
    ReviewStatus? status,
    String? errorMessage,
    Review? existingReview,
  }) {
    return ReviewState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      existingReview: existingReview ?? this.existingReview,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, existingReview];
}

// BLoC
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final SendReviewUseCase _sendReviewUseCase;
  final CheckBookingReviewUseCase _checkReviewUseCase;

  ReviewBloc({
    required SendReviewUseCase sendReviewUseCase,
    required CheckBookingReviewUseCase checkReviewUseCase,
  })  : _sendReviewUseCase = sendReviewUseCase,
        _checkReviewUseCase = checkReviewUseCase,
        super(const ReviewState()) {
    on<SendReviewRequestedEvent>(_onSendReview);
    on<CheckReviewStatusEvent>(_onCheckStatus);
  }

  Future<void> _onSendReview(SendReviewRequestedEvent event, Emitter<ReviewState> emit) async {
    emit(state.copyWith(status: ReviewStatus.loading));

    final review = Review(
      bookingId: event.bookingId,
      rating: event.rating,
      comment: event.comment,
    );

    final result = await _sendReviewUseCase.execute(review);

    result.fold(
      (failure) => emit(state.copyWith(status: ReviewStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: ReviewStatus.success)),
    );
  }

  Future<void> _onCheckStatus(CheckReviewStatusEvent event, Emitter<ReviewState> emit) async {
    final result = await _checkReviewUseCase.execute(event.bookingId);

    result.fold(
      (_) => null, // Silencioso si falla el check
      (review) {
        if (review != null) {
          emit(state.copyWith(status: ReviewStatus.alreadyReviewed, existingReview: review));
        }
      },
    );
  }
}
