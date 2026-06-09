import '../../domain/entities/provider_review.dart';

/// Modelo para reseñas recibidas por un cliente (escritas por proveedores).
/// La diferencia con [ProviderReviewModel] es que el nombre viene del
/// proveedor, no del cliente (fk: bookings.provider_id → users).
class ClientReviewModel extends ProviderReview {
  const ClientReviewModel({
    required super.reviewerName,
    required super.rating,
    super.comment,
    super.punctualityRating,
    super.qualityRating,
    super.communicationRating,
    super.createdAt,
  });

  factory ClientReviewModel.fromJson(Map<String, dynamic> json) {
    // Estructura de la query:
    // reviews { ..., bookings!inner(client_id,
    //   users!bookings_provider_id_fkey(first_name, last_name)) }
    Map<String, dynamic>? reviewerData;
    final bookings = json['bookings'];
    if (bookings is Map) {
      reviewerData =
          bookings['users!bookings_provider_id_fkey'] as Map<String, dynamic>?;
    }
    final firstName = reviewerData?['first_name'] as String?;
    final lastName = reviewerData?['last_name'] as String?;
    final nameParts = <String>[];
    if (firstName != null && firstName.isNotEmpty) nameParts.add(firstName);
    if (lastName != null && lastName.isNotEmpty) nameParts.add(lastName);

    return ClientReviewModel(
      reviewerName: nameParts.isNotEmpty ? nameParts.join(' ') : 'Proveedor',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      punctualityRating: json['punctuality_rating'] as int?,
      qualityRating: json['quality_rating'] as int?,
      communicationRating: json['communication_rating'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
