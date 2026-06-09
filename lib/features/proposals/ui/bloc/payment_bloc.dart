import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/process_payment_usecase.dart';

// Events
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class ProcessPaymentRequestedEvent extends PaymentEvent {
  final String bookingId;
  final double amount;
  final String method; // 'cash', 'card'
  final String? transactionId;

  const ProcessPaymentRequestedEvent({
    required this.bookingId,
    required this.amount,
    required this.method,
    this.transactionId,
  });

  @override
  List<Object?> get props => [bookingId, amount, method, transactionId];
}

// States
enum PaymentStatus { initial, loading, success, error }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, errorMessage];
}

// BLoC
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final ProcessPaymentUseCase _processPaymentUseCase;
  final GetCurrentSessionUseCase _getCurrentSession;

  PaymentBloc({
    required ProcessPaymentUseCase processPaymentUseCase,
    required GetCurrentSessionUseCase getCurrentSession,
  })  : _processPaymentUseCase = processPaymentUseCase,
        _getCurrentSession = getCurrentSession,
        super(const PaymentState()) {
    on<ProcessPaymentRequestedEvent>(_onProcessPaymentRequested);
  }

  Future<void> _onProcessPaymentRequested(
    ProcessPaymentRequestedEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState(status: PaymentStatus.loading));

    final sessionResult = await _getCurrentSession();
    final userId = sessionResult.fold((_) => null, (auth) => auth?.userId);

    if (userId == null) {
      emit(const PaymentState(
        status: PaymentStatus.error,
        errorMessage: 'Sesión no válida',
      ));
      return;
    }

    final payment = Payment(
      bookingId: event.bookingId,
      clientId: userId,
      amount: event.amount,
      paymentMethod: event.method,
      transactionId: event.transactionId,
    );

    final result = await _processPaymentUseCase.execute(payment);

    result.fold(
      (failure) => emit(PaymentState(
        status: PaymentStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(const PaymentState(status: PaymentStatus.success)),
    );
  }
}
