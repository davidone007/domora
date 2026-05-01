import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String userId;
  final String? locationName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;
  final String? addressType;

  const Address({
    required this.id,
    required this.userId,
    this.locationName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.neighborhood,
    this.latitude,
    this.longitude,
    this.isPrimary = false,
    this.addressType,
  });

  String get formatted {
    final parts = <String>[
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      if (neighborhood != null && neighborhood!.isNotEmpty) neighborhood!,
      city,
    ];
    return parts.join(', ');
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      locationName: map['location_name'] as String?,
      addressLine1: map['address_line1'] as String? ?? '',
      addressLine2: map['address_line2'] as String?,
      city: map['city'] as String? ?? '',
      neighborhood: map['neighborhood'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isPrimary: (map['is_primary'] as bool?) ?? false,
      addressType: map['address_type'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        addressLine1,
        addressLine2,
        city,
        neighborhood,
        isPrimary,
        addressType,
      ];
}
