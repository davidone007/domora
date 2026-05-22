import 'package:equatable/equatable.dart';
import 'package:domora/features/services/domain/entities/service.dart';
import 'booking.dart';

class BookingWithService extends Equatable {
  final Booking booking;
  final Service service;
  final String otherPartyName;
  final String? otherPartyAvatarUrl;

  const BookingWithService({
    required this.booking,
    required this.service,
    required this.otherPartyName,
    this.otherPartyAvatarUrl,
  });

  @override
  List<Object?> get props => [booking, service, otherPartyName, otherPartyAvatarUrl];
}
