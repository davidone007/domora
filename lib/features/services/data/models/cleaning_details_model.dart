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
}
