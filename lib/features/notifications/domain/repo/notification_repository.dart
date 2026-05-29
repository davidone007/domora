import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationRepository {
  /// Obtiene la lista de notificaciones del usuario actual.
  Future<Either<Failure, List<AppNotification>>> getNotifications();

  /// Marca una notificación como leída.
  Future<Either<Failure, Unit>> markAsRead(String notificationId);

  /// Registra el token de FCM del dispositivo actual en la base de datos.
  Future<Either<Failure, Unit>> registerFcmToken(String token);

  /// Escucha cambios en las notificaciones en tiempo real.
  Stream<List<AppNotification>> watchNotifications();
}
