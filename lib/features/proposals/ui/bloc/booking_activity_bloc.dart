import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:domora/core/utils/constants.dart';
import '../../domain/entities/booking_with_service.dart';
import '../../domain/usecases/get_client_booking_history_usecase.dart';
import '../../domain/usecases/get_provider_active_bookings_usecase.dart';
import '../../domain/usecases/complete_booking_usecase.dart';

// Events
abstract class BookingActivityEvent extends Equatable {
  const BookingActivityEvent();
  @override
  List<Object?> get props => [];
}

class FetchBookingActivityEvent extends BookingActivityEvent {
  const FetchBookingActivityEvent();
}

class CompleteBookingRequestedEvent extends BookingActivityEvent {
  final String bookingId;
  final String serviceId;

  const CompleteBookingRequestedEvent({required this.bookingId, required this.serviceId});

  @override
  List<Object?> get props => [bookingId, serviceId];
}

// States
enum BookingActivityStatus { initial, loading, success, error, completing, completeSuccess }

class BookingActivityState extends Equatable {
  final BookingActivityStatus status;
  final List<BookingWithService> bookings;
  final String? role;
  final String? userId;
  final String? errorMessage;

  const BookingActivityState({
    this.status = BookingActivityStatus.initial,
    this.bookings = const [],
    this.role,
    this.userId,
    this.errorMessage,
  });

  BookingActivityState copyWith({
    BookingActivityStatus? status,
    List<BookingWithService>? bookings,
    String? role,
    String? userId,
    String? errorMessage,
  }) {
    return BookingActivityState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookings, role, userId, errorMessage];
}

// BLoC
class BookingActivityBloc extends Bloc<BookingActivityEvent, BookingActivityState> {
  final GetClientBookingHistoryUseCase _getClientHistory;
  final GetProviderActiveBookingsUseCase _getProviderActive;
  final CompleteBookingUseCase _completeBooking;
  final GetCurrentSessionUseCase _getCurrentSession;

  BookingActivityBloc({
    required GetClientBookingHistoryUseCase getClientHistory,
    required GetProviderActiveBookingsUseCase getProviderActive,
    required CompleteBookingUseCase completeBooking,
    required GetCurrentSessionUseCase getCurrentSession,
  })  : _getClientHistory = getClientHistory,
        _getProviderActive = getProviderActive,
        _completeBooking = completeBooking,
        _getCurrentSession = getCurrentSession,
        super(const BookingActivityState()) {
    on<FetchBookingActivityEvent>(_onFetchActivity);
    on<CompleteBookingRequestedEvent>(_onCompleteBooking);
  }

  Future<void> _onFetchActivity(FetchBookingActivityEvent event, Emitter<BookingActivityState> emit) async {
    emit(state.copyWith(status: BookingActivityStatus.loading));

    final sessionResult = await _getCurrentSession();
    final auth = sessionResult.fold((_) => null, (a) => a);

    if (auth == null) {
      emit(state.copyWith(status: BookingActivityStatus.error, errorMessage: 'Sesión expirada'));
      return;
    }

    final isProvider = auth.role == AppConstants.roleProvider;
    final result = isProvider 
        ? await _getProviderActive.execute(auth.userId)
        : await _getClientHistory.execute(auth.userId);

    result.fold(
      (failure) => emit(state.copyWith(status: BookingActivityStatus.error, errorMessage: failure.message)),
      (bookings) => emit(state.copyWith(
        status: BookingActivityStatus.success,
        bookings: bookings,
        role: auth.role,
        userId: auth.userId,
      )),
    );
  }

  Future<void> _onCompleteBooking(CompleteBookingRequestedEvent event, Emitter<BookingActivityState> emit) async {
    emit(state.copyWith(status: BookingActivityStatus.completing));

    final result = await _completeBooking.execute(
      bookingId: event.bookingId,
      serviceId: event.serviceId,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: BookingActivityStatus.error, errorMessage: failure.message)),
      (_) {
        emit(state.copyWith(status: BookingActivityStatus.completeSuccess));
        add(const FetchBookingActivityEvent()); // Refrescamos lista
      },
    );
  }
}
