import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../repo/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<Either<Failure, Unit>> execute(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
