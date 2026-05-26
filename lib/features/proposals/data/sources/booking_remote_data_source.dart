import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:domora/core/utils/constants.dart';

abstract class BookingRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBookings({
    required String userId,
    required bool isProvider,
    required List<String> statuses,
  });

  Future<void> completeBooking({
    required String bookingId,
    required String serviceId,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  BookingRemoteDataSourceImpl(this._client, {required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  @override
  Future<List<Map<String, dynamic>>> getBookings({
    required String userId,
    required bool isProvider,
    required List<String> statuses,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    final String userField = isProvider ? 'provider_id' : 'client_id';
    
    // Consulta con joins para traer datos del servicio y de la contraparte
    // Usamos el nombre de la tabla con el campo de unión para mayor robustez
    final String otherPartyTable = isProvider ? 'users!client_id' : 'users!provider_id';

    final response = await _client
        .from(AppConstants.tableBookings)
        .select('*, services(*), reviews(id), $otherPartyTable(first_name, last_name, client_profiles(avatar_url), provider_profiles(avatar_url))')
        .eq(userField, userId)
        .inFilter('status', statuses)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> completeBooking({
    required String bookingId,
    required String serviceId,
  }) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    await _client.rpc('complete_booking', params: {
      'p_booking_id': bookingId,
      'p_service_id': serviceId,
    });
  }
}
