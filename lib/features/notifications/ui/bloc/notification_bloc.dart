import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repo/notification_repository.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationEvent {
  const FetchNotificationsEvent();
}

class MarkAsReadRequestedEvent extends NotificationEvent {
  final String notificationId;
  const MarkAsReadRequestedEvent(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class NotificationsUpdatedEvent extends NotificationEvent {
  final List<AppNotification> notifications;
  const NotificationsUpdatedEvent(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

// States
enum NotificationStatus { initial, loading, success, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<AppNotification> notifications;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotification>? notifications,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markAsRead;
  final NotificationRepository _repository;
  StreamSubscription? _notificationsSubscription;

  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markAsRead,
    required NotificationRepository repository,
  })  : _getNotifications = getNotifications,
        _markAsRead = markAsRead,
        _repository = repository,
        super(const NotificationState()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkAsReadRequestedEvent>(_onMarkAsRead);
    on<NotificationsUpdatedEvent>(_onNotificationsUpdated);

    // Iniciar escucha en tiempo real
    _notificationsSubscription = _repository.watchNotifications().listen((notifications) {
      add(NotificationsUpdatedEvent(notifications));
    });
  }

  Future<void> _onFetchNotifications(FetchNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    final result = await _getNotifications.execute();

    result.fold(
      (failure) => emit(state.copyWith(status: NotificationStatus.error, errorMessage: failure.message)),
      (notifications) => emit(state.copyWith(status: NotificationStatus.success, notifications: notifications)),
    );
  }

  Future<void> _onMarkAsRead(MarkAsReadRequestedEvent event, Emitter<NotificationState> emit) async {
    await _markAsRead.execute(event.notificationId);
    // No emitimos éxito aquí, esperamos a que el Stream actualice la lista.
  }

  void _onNotificationsUpdated(NotificationsUpdatedEvent event, Emitter<NotificationState> emit) {
    emit(state.copyWith(status: NotificationStatus.success, notifications: event.notifications));
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
