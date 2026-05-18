import 'package:equatable/equatable.dart';

class AddressSuggestion extends Equatable {
  final String id;
  final String label;
  final double latitude;
  final double longitude;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? neighborhood;

  const AddressSuggestion({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.neighborhood,
  });

  @override
  List<Object?> get props => [
        id,
        label,
        latitude,
        longitude,
        addressLine1,
        addressLine2,
        city,
        neighborhood,
      ];
}
