import 'package:intl/intl.dart';
import '../../domain/entities/service.dart';
import 'publish_service_request_model.dart';

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
    super.bookingProviderId,
    super.quoteProviderIds = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Supabase returns 'quotes' as a list or an object with count depending on query
    int count = 0;
    final quoteProviderIds = <String>[];
    if (json['quotes'] != null) {
      if (json['quotes'] is List) {
        final list = json['quotes'] as List;
        // quotes(count) → [{"count": N}]; distinguish from a plain list of rows
        if (list.isNotEmpty && list.first is Map && (list.first as Map).containsKey('count')) {
          count = (list.first as Map)['count'] as int? ?? 0;
        } else {
          count = list.length;
          for (final item in list) {
            if (item is Map && item['provider_id'] != null) {
              quoteProviderIds.add(item['provider_id'] as String);
            }
          }
        }
      } else if (json['quotes'] is Map && json['quotes']['count'] != null) {
        count = json['quotes']['count'] as int;
      }
    }

    String? bookingProviderId;
    final bookings = json['bookings'];
    if (bookings is List && bookings.isNotEmpty) {
      final first = bookings.first;
      if (first is Map && first['provider_id'] != null) {
        bookingProviderId = first['provider_id'] as String?;
      }
    } else if (bookings is Map && bookings['provider_id'] != null) {
      bookingProviderId = bookings['provider_id'] as String?;
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
      bookingProviderId: bookingProviderId,
      quoteProviderIds: quoteProviderIds,
    );
  }

  static Map<String, dynamic> toJson(PublishServiceRequestModel request, String addressId) {
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
