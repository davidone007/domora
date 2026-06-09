import 'package:domora/core/entities/avatar_file.dart';
import '../../domain/entities/cleaning_service_request.dart';
import 'cleaning_details_model.dart';
import 'service_address_model.dart';

/// DTO de capa de datos para publicar un servicio.
/// El DataSource nunca debe recibir entidades de dominio; esta clase
/// actúa como equivalente de [CleaningServiceRequest] con los campos
/// de dirección y detalle ya convertidos a sus modelos de datos.
class PublishServiceRequestModel {
  final String clientId;
  final String title;
  final String? description;
  final DateTime preferredDate;
  final String preferredTimeStart;
  final ServiceAddressModel address;
  final CleaningDetailsModel details;
  final List<AvatarFile> images;
  final int primaryImageIndex;

  const PublishServiceRequestModel({
    required this.clientId,
    required this.title,
    this.description,
    required this.preferredDate,
    required this.preferredTimeStart,
    required this.address,
    required this.details,
    required this.images,
    required this.primaryImageIndex,
  });

  factory PublishServiceRequestModel.fromEntity(CleaningServiceRequest request) {
    return PublishServiceRequestModel(
      clientId: request.clientId,
      title: request.title,
      description: request.description,
      preferredDate: request.preferredDate,
      preferredTimeStart: request.preferredTimeStart,
      address: ServiceAddressModel.fromEntity(request.address),
      details: CleaningDetailsModel.fromEntity(request.details),
      images: request.images,
      primaryImageIndex: request.primaryImageIndex,
    );
  }
}
