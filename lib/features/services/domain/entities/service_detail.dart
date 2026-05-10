import 'package:equatable/equatable.dart';
import 'cleaning_service_detail.dart';
import 'service.dart';
import 'service_address.dart';

/// Entidad que representa el detalle completo de un servicio.
class ServiceDetail extends Equatable {
  final Service service;
  final CleaningServiceDetail cleaningDetail;
  final ServiceAddress address;
  final List<String> imageUrls;

  const ServiceDetail({
    required this.service,
    required this.cleaningDetail,
    required this.address,
    required this.imageUrls,
  });

  @override
  List<Object?> get props => [
        service,
        cleaningDetail,
        address,
        imageUrls,
      ];
}
