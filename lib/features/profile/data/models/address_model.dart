import '../../domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.userId,
    super.locationName,
    required super.addressLine1,
    super.addressLine2,
    required super.department,
    required super.city,
    super.neighborhood,
    super.latitude,
    super.longitude,
    super.isPrimary,
    super.addressType,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      locationName: json['location_name'] as String?,
      addressLine1: json['address_line1'] as String? ?? '',
      addressLine2: json['address_line2'] as String?,
      department: json['department'] as String? ?? '',
      city: json['city'] as String? ?? '',
      neighborhood: json['neighborhood'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isPrimary: (json['is_primary'] as bool?) ?? false,
      addressType: json['address_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'location_name': locationName,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'department': department,
      'city': city,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'is_primary': isPrimary,
      'address_type': addressType,
    };
  }
}
