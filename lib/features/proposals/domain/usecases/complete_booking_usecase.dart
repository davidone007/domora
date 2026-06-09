import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../repo/booking_repository.dart';

class CompleteBookingUseCase {
  final BookingRepository _repository;

  CompleteBookingUseCase(this._repository);

  Future<Either<Failure, Unit>> execute({
    required String bookingId,
    required String serviceId,
  }) {
    return _repository.completeBooking(
      bookingId: bookingId,
      serviceId: serviceId,
    );
  }
}
