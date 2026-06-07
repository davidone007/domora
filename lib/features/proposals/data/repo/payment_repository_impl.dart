import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repo/payment_repository.dart';
import '../models/payment_model.dart';
import '../sources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;
  final FailureMapper _errorMapper;

  PaymentRepositoryImpl(this._remoteDataSource, this._errorMapper);

  @override
  Future<Either<Failure, Unit>> processPayment(Payment payment) async {
    try {
      final model = PaymentModel.fromEntity(payment);

      // El repositorio orquesta las dos operaciones atómicas:
      // 1. Registrar el pago en la tabla `payments`.
      await _remoteDataSource.insertPayment(model);

      // 2. Actualizar el estado de pago en el booking.
      await _remoteDataSource.updateBookingPaymentStatus(payment.bookingId, 'paid');

      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(
          operation: 'processPayment',
          userId: payment.clientId,
        ).toString(),
      ));
    }
  }
}
