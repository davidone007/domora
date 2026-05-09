import 'package:equatable/equatable.dart';
import 'cleaning_service_detail.dart';
import 'service_address.dart';

/// Agregado que representa una solicitud completa de servicio de limpieza.
class CleaningServiceRequest extends Equatable {
  final String clientId;
  final String title;
  final String? description;
  final DateTime preferredDate;
  final String preferredTimeStart; // Formato HH:mm:ss
  final ServiceAddress address;
  final CleaningServiceDetail details;

  const CleaningServiceRequest({
    required this.clientId,
    required this.title,
    this.description,
    required this.preferredDate,
    required this.preferredTimeStart,
    required this.address,
    required this.details,
  });

  @override
  List<Object?> get props => [
        clientId,
        title,
        description,
        preferredDate,
        preferredTimeStart,
        address,
        details,
      ];
}
