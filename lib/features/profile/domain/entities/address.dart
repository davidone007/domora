import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String userId;
  final String? locationName;
  final String addressLine1;
  final String? addressLine2;
  final String department;
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
    required this.department,
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
      department,
      city,
    ];
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        addressLine1,
        addressLine2,
        department,
        city,
        neighborhood,
        isPrimary,
        addressType,
      ];
}
