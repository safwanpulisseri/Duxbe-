import 'package:duxbe/shared/shared.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final fcmTokenProvider = StreamProvider<String?>((ref) async* {
  final messaging = ref.watch(firebaseMessagingProvider);
  final token = await messaging.getToken(
    vapidKey: ref.read(envProvider).VAPID_KEY,
  );
  yield token;
  yield* messaging.onTokenRefresh;
});

final selectNotificationStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) async* {
  yield* NotificationService.selectNotificationStream.stream;
});
