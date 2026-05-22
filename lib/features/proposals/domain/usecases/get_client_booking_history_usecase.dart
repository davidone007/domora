import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/booking_with_service.dart';
import '../repo/booking_repository.dart';

class GetClientBookingHistoryUseCase {
  final BookingRepository _repository;

  GetClientBookingHistoryUseCase(this._repository);

  Future<Either<Failure, List<BookingWithService>>> execute(String clientId) {
    return _repository.getClientBookingHistory(clientId);
  }
}
