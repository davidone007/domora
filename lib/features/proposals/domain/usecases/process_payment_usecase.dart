import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/payment.dart';
import '../repo/payment_repository.dart';

class ProcessPaymentUseCase {
  final PaymentRepository _repository;

  ProcessPaymentUseCase(this._repository);

  Future<Either<Failure, Unit>> execute(Payment payment) {
    return _repository.processPayment(payment);
  }
}
