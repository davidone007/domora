import 'package:dartz/dartz.dart';
import 'package:domora/core/error/error_context.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repo/notification_repository.dart';
import '../models/notification_model.dart';
import '../sources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final FailureMapper _errorMapper;

  NotificationRepositoryImpl(this._remoteDataSource, this._errorMapper);

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    try {
      final models = await _remoteDataSource.getNotifications();
      return Right(models);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'getNotifications').toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'markAsRead', userId: notificationId).toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> registerFcmToken(String token) async {
    try {
      await _remoteDataSource.updateFcmToken(token);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_errorMapper.mapException(
        e,
        stackTrace: stackTrace,
        context: ErrorContext(operation: 'registerFcmToken').toString(),
      ));
    }
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return _remoteDataSource.watchNotifications().map((list) {
      return list.map((json) => NotificationModel.fromJson(json)).toList();
    });
  }
}
