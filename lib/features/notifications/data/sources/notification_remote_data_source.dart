import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/network/network_info.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> updateFcmToken(String token);
  Stream<List<Map<String, dynamic>>> watchNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  NotificationRemoteDataSourceImpl(this._client, {required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    final userId = _client.auth.currentUser!.id;
    final List<dynamic> response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map((json) => NotificationModel.fromJson(json)).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (!await _networkInfo.isConnected()) {
      throw const PostgrestException(message: 'No hay conexión a internet');
    }

    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> updateFcmToken(String token) async {
    if (!await _networkInfo.isConnected()) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    // Asumimos que hay una columna fcm_token en la tabla users o una tabla dedicada
    // Por simplicidad, actualizamos la tabla users si existe el campo
    try {
      await _client.from('users').update({'fcm_token': token}).eq('id', userId);
    } catch (_) {
      // Ignorar si el campo no existe aún en la base de datos
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchNotifications() {
    final userId = _client.auth.currentUser!.id;
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
