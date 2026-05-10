import '../../domain/entities/service_detail.dart';
import 'cleaning_details_model.dart';
import 'service_address_model.dart';
import 'service_model.dart';

class ServiceDetailModel extends ServiceDetail {
  const ServiceDetailModel({
    required super.service,
    required super.cleaningDetail,
    required super.address,
    required super.imageUrls,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    final images = (json['service_images'] as List?)
            ?.map((img) => img['image_url'] as String)
            .toList() ??
        [];

    return ServiceDetailModel(
      service: ServiceModel.fromJson(json),
      cleaningDetail: CleaningDetailsModel.fromJson(json['cleaning_details']),
      address: ServiceAddressModel.fromJson(json['addresses']),
      imageUrls: images,
    );
  }
}
