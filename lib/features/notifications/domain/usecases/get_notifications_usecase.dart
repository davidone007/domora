import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/app_notification.dart';
import '../repo/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<Either<Failure, List<AppNotification>>> execute() {
    return _repository.getNotifications();
  }
}
