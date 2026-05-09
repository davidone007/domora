import 'package:equatable/equatable.dart';

/// Detalles técnicos específicos de un servicio de limpieza.
class CleaningServiceDetail extends Equatable {
  final int bathrooms;
  final int kitchens;
  final int bedrooms;
  final int livingRooms;
  final bool includesBalcony;
  final bool hasOwnSupplies;
  final String? suppliesNotes;

  const CleaningServiceDetail({
    this.bathrooms = 0,
    this.kitchens = 0,
    this.bedrooms = 0,
    this.livingRooms = 0,
    this.includesBalcony = false,
    this.hasOwnSupplies = false,
    this.suppliesNotes,
  });

  @override
  List<Object?> get props => [
        bathrooms,
        kitchens,
        bedrooms,
        livingRooms,
        includesBalcony,
        hasOwnSupplies,
        suppliesNotes,
      ];
}
