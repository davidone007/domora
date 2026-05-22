import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/booking_with_service.dart';
import '../repo/booking_repository.dart';

class GetProviderActiveBookingsUseCase {
  final BookingRepository _repository;

  GetProviderActiveBookingsUseCase(this._repository);

  Future<Either<Failure, List<BookingWithService>>> execute(String providerId) {
    return _repository.getProviderActiveBookings(providerId);
  }
}
