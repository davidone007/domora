import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Coordinates the Firebase Cloud Messaging lifecycle for the signed-in user.
///
/// Call [initialize] once a session is confirmed (post-login or post-splash).
/// Safe to call multiple times — listeners are attached only once.
///
/// Both [onTokenReceived] and [onNotificationReceived] are callbacks so that
/// `FcmService` (a core service) stays completely free of feature-layer
/// dependencies. The caller wires up the feature logic in the DI container.
class FcmService {
  /// Callback invocado cuando se obtiene/refresca el token FCM.
  /// Responsable de registrar el token en el backend.
  final Future<void> Function(String token) onTokenReceived;

  /// Callback invocado al recibir o abrir una notificación push.
  /// No debe ser nulo; si no se necesita reacción, pasar `() {}`.
  final void Function() onNotificationReceived;

  final FirebaseMessaging _messaging;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  bool _handlersAttached = false;

  FcmService({
    required this.onTokenReceived,
    required this.onNotificationReceived,
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await onTokenReceived(token);
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
      onTokenReceived(newToken);
      if (kDebugMode) debugPrint('[FCM] Token refreshed');
    });

    _onMessageSub = FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        debugPrint('[FCM foreground] ${message.notification?.title}');
      }
      // Realtime stream usually beats this, but trigger a fetch as safety net.
      onNotificationReceived();
    });

    _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) debugPrint('[FCM tap] ${message.data}');
      // Refresh so the bell badge / list reflects the new notification.
      onNotificationReceived();
    });
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _onMessageSub?.cancel();
    await _onMessageOpenedSub?.cancel();
    _handlersAttached = false;
  }
}
