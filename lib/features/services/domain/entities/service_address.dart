import 'package:equatable/equatable.dart';

/// Entidad que representa la dirección asociada a un servicio.
class ServiceAddress extends Equatable {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;

  const ServiceAddress({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.neighborhood,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        addressLine1,
        addressLine2,
        city,
        neighborhood,
        latitude,
        longitude,
      ];
}
