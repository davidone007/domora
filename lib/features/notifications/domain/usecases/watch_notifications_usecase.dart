import '../entities/app_notification.dart';
import '../repo/notification_repository.dart';

class WatchNotificationsUseCase {
  final NotificationRepository _repository;

  WatchNotificationsUseCase(this._repository);

  Stream<List<AppNotification>> execute() {
    return _repository.watchNotifications();
  }
}
