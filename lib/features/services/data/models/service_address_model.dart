import '../../domain/entities/service_address.dart';

class ServiceAddressModel extends ServiceAddress {
  const ServiceAddressModel({
    required super.addressLine1,
    super.addressLine2,
    required super.city,
    super.neighborhood,
    super.latitude,
    super.longitude,
  });

  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'is_primary': false, // Las direcciones de servicios no suelen ser las principales del usuario
      'address_type': 'service_location',
    };
  }

  factory ServiceAddressModel.fromEntity(ServiceAddress address) {
    return ServiceAddressModel(
      addressLine1: address.addressLine1,
      addressLine2: address.addressLine2,
      city: address.city,
      neighborhood: address.neighborhood,
      latitude: address.latitude,
      longitude: address.longitude,
    );
  }

  factory ServiceAddressModel.fromJson(Map<String, dynamic> json) {
    return ServiceAddressModel(
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      neighborhood: json['neighborhood'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
}
