import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level FCM background message handler.
///
/// MUST be a top-level function and annotated with `@pragma('vm:entry-point')`
/// so the Dart tree-shaker keeps it for the background isolate.
/// The background isolate has no app state — UI updates happen when the user
/// taps the notification and the foreground app rehydrates.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint('[FCM background] ${message.messageId} :: ${message.data}');
  }
}
