import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:domora/core/utils/constants.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  /// Inserta el registro de pago en la tabla `payments`.
  Future<void> insertPayment(PaymentModel payment);

  /// Actualiza el `payment_status` del booking asociado.
  /// Separado de [insertPayment] para que el [PaymentRepositoryImpl]
  /// pueda orquestar ambas operaciones y manejar cada fallo de forma
  /// independiente.
  Future<void> updateBookingPaymentStatus(String bookingId, String status);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  PaymentRemoteDataSourceImpl(this._client, {required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  @override
  Future<void> insertPayment(PaymentModel payment) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }
    await _client.from(AppConstants.tablePayments).insert(payment.toJson());
  }

  @override
  Future<void> updateBookingPaymentStatus(String bookingId, String status) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }
    await _client
        .from(AppConstants.tableBookings)
        .update({'payment_status': status})
        .eq('id', bookingId);
  }
}
