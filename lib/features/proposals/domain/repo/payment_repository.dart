import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  /// Registra un pago en la base de datos y actualiza el estado del booking.
  Future<Either<Failure, Unit>> processPayment(Payment payment);
}
