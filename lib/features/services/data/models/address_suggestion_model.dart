import '../../domain/entities/address_suggestion.dart';

class AddressSuggestionModel extends AddressSuggestion {
  const AddressSuggestionModel({
    required super.id,
    required super.label,
    required super.latitude,
    required super.longitude,
    super.addressLine1,
    super.addressLine2,
    super.city,
    super.neighborhood,
  });

  factory AddressSuggestionModel.fromGeoapifyJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final label = (properties['formatted'] ?? properties['address_line1'] ?? '').toString();
    final id = (properties['place_id'] ?? label).toString();

    return AddressSuggestionModel(
      id: id,
      label: label,
      latitude: (properties['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (properties['lon'] as num?)?.toDouble() ?? 0.0,
      addressLine1: properties['address_line1']?.toString(),
      addressLine2: properties['address_line2']?.toString(),
      city: _readCity(properties),
      neighborhood: _readNeighborhood(properties),
    );
  }

  static String? _readCity(Map<String, dynamic> properties) {
    return properties['city']?.toString() ??
        properties['town']?.toString() ??
        properties['village']?.toString() ??
        properties['county']?.toString();
  }

  static String? _readNeighborhood(Map<String, dynamic> properties) {
    return properties['neighbourhood']?.toString() ??
        properties['neighborhood']?.toString() ??
        properties['suburb']?.toString() ??
        properties['district']?.toString() ??
        properties['quarter']?.toString();
  }
}
