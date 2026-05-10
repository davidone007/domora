import '../../domain/entities/cleaning_service_detail.dart';

class CleaningDetailsModel extends CleaningServiceDetail {
  const CleaningDetailsModel({
    super.bathrooms,
    super.kitchens,
    super.bedrooms,
    super.livingRooms,
    super.includesBalcony,
    super.hasOwnSupplies,
    super.suppliesNotes,
  });

  Map<String, dynamic> toJson(String serviceId) {
    return {
      'service_id': serviceId,
      'bathrooms': bathrooms,
      'kitchens': kitchens,
      'bedrooms': bedrooms,
      'living_rooms': livingRooms,
      'includes_balcony': includesBalcony,
      'has_own_supplies': hasOwnSupplies,
      'supplies_notes': suppliesNotes,
    };
  }

  factory CleaningDetailsModel.fromEntity(CleaningServiceDetail detail) {
    return CleaningDetailsModel(
      bathrooms: detail.bathrooms,
      kitchens: detail.kitchens,
      bedrooms: detail.bedrooms,
      livingRooms: detail.livingRooms,
      includesBalcony: detail.includesBalcony,
      hasOwnSupplies: detail.hasOwnSupplies,
      suppliesNotes: detail.suppliesNotes,
    );
  }

  factory CleaningDetailsModel.fromJson(Map<String, dynamic> json) {
    return CleaningDetailsModel(
      bathrooms: json['bathrooms'] ?? 0,
      kitchens: json['kitchens'] ?? 0,
      bedrooms: json['bedrooms'] ?? 0,
      livingRooms: json['living_rooms'] ?? 0,
      includesBalcony: json['includes_balcony'] ?? false,
      hasOwnSupplies: json['has_own_supplies'] ?? false,
      suppliesNotes: json['supplies_notes'],
    );
  }
}
