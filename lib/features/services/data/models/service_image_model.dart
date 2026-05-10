import '../../domain/entities/service_image.dart';

class ServiceImageModel extends ServiceImage {
  const ServiceImageModel({
    required super.id,
    required super.serviceId,
    required super.imageUrl,
    super.isPrimary,
    super.orderIndex,
  });

  factory ServiceImageModel.fromMap(Map<String, dynamic> map) {
    return ServiceImageModel(
      id: map['id'] as String,
      serviceId: map['service_id'] as String,
      imageUrl: map['image_url'] as String,
      isPrimary: (map['is_primary'] as bool?) ?? false,
      orderIndex: (map['order_index'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'order_index': orderIndex,
    };
  }
}
