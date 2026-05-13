import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:domora/core/utils/constants.dart';
import 'package:domora/core/entities/avatar_file.dart';
import '../models/cleaning_details_model.dart';
import '../models/service_address_model.dart';
import '../models/service_model.dart';
import '../models/service_detail_model.dart';
import '../../domain/entities/cleaning_service_request.dart';

abstract class ServiceRemoteDataSource {
  /// Retorna el ID del servicio creado
  Future<String> publishCleaningService(CleaningServiceRequest request);

  Future<void> uploadServiceImages({
    required String serviceId,
    required List<AvatarFile> images,
    required int primaryIndex,
  });

  /// Obtiene los servicios del usuario con conteo de propuestas
  Future<List<ServiceModel>> getMyServices(String userId);

  /// Obtiene todos los servicios disponibles con conteo de propuestas
  Future<List<ServiceModel>> getAllAvailableServices();

  /// Obtiene el detalle de un servicio por su ID
  Future<ServiceDetailModel> getServiceById(String serviceId);
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  ServiceRemoteDataSourceImpl(this._client, {required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  @override
  Future<ServiceDetailModel> getServiceById(String serviceId) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    final response = await _client
        .from('services')
        .select('*, cleaning_details(*), addresses(*), service_images(*), quotes(count)')
        .eq('id', serviceId)
        .single();

    return ServiceDetailModel.fromJson(response);
  }

  @override
  Future<List<ServiceModel>> getMyServices(String userId) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    // Consulta que trae los servicios y cuenta las propuestas (quotes)
    final response = await _client
        .from('services')
        .select('*, quotes(count)')
        .eq('client_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => ServiceModel.fromJson(json)).toList();
  }

  @override
  Future<List<ServiceModel>> getAllAvailableServices() async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    // Consulta que trae todos los servicios y cuenta las propuestas (quotes)
    final response = await _client
        .from('services')
        .select('*, quotes(count)')
        .order('created_at', ascending: false);

    return (response as List).map((json) => ServiceModel.fromJson(json)).toList();
  }

  @override
  Future<String> publishCleaningService(CleaningServiceRequest request) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    // 1. Insertar dirección
    final addressModel = ServiceAddressModel.fromEntity(request.address);
    final addressResponse = await _client
        .from(AppConstants.tableAddresses)
        .insert(addressModel.toJson(request.clientId))
        .select('id')
        .single();

    final addressId = addressResponse['id'] as String;

    // 2. Insertar servicio
    final serviceResponse = await _client
        .from('services')
        .insert(ServiceModel.toJson(request, addressId))
        .select('id')
        .single();

    final serviceId = serviceResponse['id'] as String;

    // 3. Insertar detalles de limpieza
    final detailsModel = CleaningDetailsModel.fromEntity(request.details);
    await _client
        .from('cleaning_details')
        .insert(detailsModel.toJson(serviceId));

    return serviceId;
  }

  @override
  Future<void> uploadServiceImages({
    required String serviceId,
    required List<AvatarFile> images,
    required int primaryIndex,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final imageUrl = await _uploadImage(serviceId, file);
      
      if (imageUrl != null) {
        await _client.from('service_images').insert({
          'service_id': serviceId,
          'image_url': imageUrl,
          'is_primary': i == primaryIndex,
          'order_index': i,
        });
      }
    }
  }

  Future<String?> _uploadImage(String serviceId, AvatarFile file) async {
    final ext = file.filename.split('.').last.toLowerCase();
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}_${file.filename}';
    final path = '$serviceId/$fileName';

    final storage = _client.storage.from('service-images');

    await storage.uploadBinary(
      path,
      file.bytes,
      fileOptions: FileOptions(
        contentType: 'image/$ext',
        upsert: true,
      ),
    );

    return storage.getPublicUrl(path);
  }
}
