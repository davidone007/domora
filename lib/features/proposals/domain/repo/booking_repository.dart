import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/booking_with_service.dart';

abstract class BookingRepository {
  /// Obtiene el historial de reservas (completadas) para un cliente.
  Future<Either<Failure, List<BookingWithService>>> getClientBookingHistory(String clientId);

  /// Obtiene las reservas activas (pendientes/confirmadas) para un proveedor.
  Future<Either<Failure, List<BookingWithService>>> getProviderActiveBookings(String providerId);

  /// Finaliza un servicio, actualizando tanto el booking como el servicio original.
  Future<Either<Failure, Unit>> completeBooking({
    required String bookingId,
    required String serviceId,
  });
}
