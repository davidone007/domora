import 'package:equatable/equatable.dart';

/// Entidad que representa una imagen asociada a un servicio.
class ServiceImage extends Equatable {
  final String id;
  final String serviceId;
  final String imageUrl;
  final bool isPrimary;
  final int orderIndex;

  const ServiceImage({
    required this.id,
    required this.serviceId,
    required this.imageUrl,
    this.isPrimary = false,
    this.orderIndex = 0,
  });

  @override
  List<Object?> get props => [id, serviceId, imageUrl, isPrimary, orderIndex];
}
