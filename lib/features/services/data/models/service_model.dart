import 'package:intl/intl.dart';
import '../../domain/entities/cleaning_service_request.dart';

class ServiceModel {
  static Map<String, dynamic> toJson(CleaningServiceRequest request, String addressId) {
    return {
      'client_id': request.clientId,
      'address_id': addressId,
      'category': 'cleaning',
      'title': request.title,
      'description': request.description,
      'status': 'open',
      'preferred_date': DateFormat('yyyy-MM-dd').format(request.preferredDate),
      'preferred_time_start': request.preferredTimeStart,
    };
  }
}
