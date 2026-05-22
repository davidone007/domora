import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:domora/core/utils/constants.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<void> processPayment(PaymentModel payment);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  PaymentRemoteDataSourceImpl(this._client, {required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  @override
  Future<void> processPayment(PaymentModel payment) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    // 1. Insertar el pago
    await _client.from(AppConstants.tablePayments).insert(payment.toJson());

    // 2. Actualizar el estado de pago del booking
    await _client
        .from(AppConstants.tableBookings)
        .update({'payment_status': 'paid'})
        .eq('id', payment.bookingId);
  }
}

// Add tablePayments to AppConstants if not exists
