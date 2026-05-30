import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:domora/features/notifications/domain/usecases/register_fcm_token_usecase.dart';
import 'package:domora/features/notifications/ui/bloc/notification_bloc.dart';

/// Coordinates the Firebase Cloud Messaging lifecycle for the signed-in user.
///
/// Call [initialize] once a session is confirmed (post-login or post-splash).
/// Safe to call multiple times — listeners are attached only once.
class FcmService {
  final RegisterFcmTokenUseCase _registerFcmToken;
  final NotificationBloc _notificationBloc;
  final FirebaseMessaging _messaging;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  bool _handlersAttached = false;

  FcmService({
    required RegisterFcmTokenUseCase registerFcmToken,
    required NotificationBloc notificationBloc,
    FirebaseMessaging? messaging,
  })  : _registerFcmToken = registerFcmToken,
        _notificationBloc = notificationBloc,
        _messaging = messaging ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _registerFcmToken.execute(token);
        if (kDebugMode) debugPrint('[FCM] Token registered: ${token.substring(0, 12)}…');
      }

      _attachHandlers();
    } catch (e, st) {
      if (kDebugMode) debugPrint('[FCM] initialize failed: $e\n$st');
    }
  }

  void _attachHandlers() {
    if (_handlersAttached) return;
    _handlersAttached = true;

    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
      _registerFcmToken.execute(newToken);
      if (kDebugMode) debugPrint('[FCM] Token refreshed');
    });

    _onMessageSub = FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        debugPrint('[FCM foreground] ${message.notification?.title}');
      }
      // Realtime stream usually beats this, but trigger a fetch as safety net.
      _notificationBloc.add(const FetchNotificationsEvent());
    });

    _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) debugPrint('[FCM tap] ${message.data}');
      // Refresh so the bell badge / list reflects the new notification.
      _notificationBloc.add(const FetchNotificationsEvent());
    });
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _onMessageSub?.cancel();
    await _onMessageOpenedSub?.cancel();
    _handlersAttached = false;
  }
}
