import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../repo/notification_repository.dart';

class RegisterFcmTokenUseCase {
  final NotificationRepository _repository;

  RegisterFcmTokenUseCase(this._repository);

  Future<Either<Failure, Unit>> execute(String token) {
    return _repository.registerFcmToken(token);
  }
}
