import 'package:intl/intl.dart';
import '../../domain/entities/cleaning_service_request.dart';
import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.title,
    super.description,
    required super.status,
    required super.createdAt,
    super.preferredDate,
    super.preferredTimeStart,
    super.quotesCount = 0,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Supabase returns 'quotes' as a list or an object with count depending on query
    int count = 0;
    if (json['quotes'] != null) {
      if (json['quotes'] is List) {
        final list = json['quotes'] as List;
        // quotes(count) → [{"count": N}]; distinguish from a plain list of rows
        if (list.isNotEmpty && list.first is Map && (list.first as Map).containsKey('count')) {
          count = (list.first as Map)['count'] as int? ?? 0;
        } else {
          count = list.length;
        }
      } else if (json['quotes'] is Map && json['quotes']['count'] != null) {
        count = json['quotes']['count'] as int;
      }
    }

    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      preferredDate: json['preferred_date'] != null
          ? DateTime.parse(json['preferred_date'])
          : null,
      preferredTimeStart: json['preferred_time_start'],
      quotesCount: count,
    );
  }

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
