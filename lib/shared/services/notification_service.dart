// notification_service_web.dart
import 'dart:async';
import 'dart:developer';

import 'package:duxbe/env.dart';
import 'package:duxbe/firebase_options_dev.dart' as dev;
import 'package:duxbe/firebase_options_prod.dart' as prod;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// A service class that handles Firebase Cloud Messaging (FCM) notifications
/// for web platform.
///
/// This service manages:
/// * FCM token generation and refresh
/// * Foreground message handling
/// * Background message handling
/// * Web notifications display
/// * Notification click handling
class NotificationService {
  /// Stream controller for broadcasting notification payload data to blocs.
  ///
  /// This stream can be listened to by various parts of the application to
  /// react to incoming notifications.
  static final StreamController<Map<String, dynamic>?> selectNotificationStream =
      StreamController<Map<String, dynamic>?>.broadcast();

  /// Handles incoming FCM messages when the app is in the background.
  ///
  /// This handler is registered as a top-level function and will be called
  /// by the FCM SDK when a message is received in the background.
  ///
  /// [message] The RemoteMessage object containing the notification data.
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp(
      options: const String.fromEnvironment('ENV') == 'dev'
          ? dev.DefaultFirebaseOptions.currentPlatform
          : prod.DefaultFirebaseOptions.currentPlatform,
      name: const String.fromEnvironment('ENV'),
    );
    debugPrint('Handling a background message ${message.messageId}');
    debugPrint(message.data.toString());
  }

  /// Initializes the notification service.
  ///
  /// This method:
  /// * Requests notification permissions
  /// * Generates and manages FCM token
  /// * Sets up message handlers for different app states
  /// * Configures notification click handling
  ///
  /// Throws an exception if the initialization fails.
  static Future<void> init() async {
    final firebaseMessaging = FirebaseMessaging.instance;
    try {
      // Get permission for web
      final settings = await firebaseMessaging.requestPermission(provisional: true);

      if (kDebugMode) {
        debugPrint('User granted permission: ${settings.authorizationStatus}');
      }

      // Get FCM token for web
      final token = await firebaseMessaging.getToken(
        vapidKey: const DevelopmentEnv().VAPID_KEY,
      );

      if (token != null) {
        if (kDebugMode) {
          debugPrint('FCM Web Token: $token');
        }
        // You would typically send this token to your server
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    // Listen for token refresh
    firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        debugPrint('FCM Token refreshed: $newToken');
      }
      // Update token on your server
    });

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Handling a foreground message ${message.messageId}');
      debugPrint('Notification Message: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        _showWebNotification(
          message.notification!.title ?? 'New Message',
          message.notification?.body ?? '',
        );
      }

      selectNotificationStream.add(message.data);
    });

    // Listen for notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('Notification clicked: ${message.data}');
        }
        // Add data to stream for bloc to handle navigation
        selectNotificationStream.add(message.data);
      },
    );

    // Listen for background notification handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Displays a notification on web platform using the browser's Notification API.
  ///
  /// This is a web-specific implementation that currently only logs the notification
  /// details. In a production environment, this should be implemented using
  /// JavaScript interop to show actual browser notifications.
  ///
  /// [title] The title of the notification.
  /// [body] The body text of the notification.
  static void _showWebNotification(String title, String body) {
    if (kIsWeb) {
      // This is just a JavaScript function call for the browser's Notification API
      // You would typically implement this using js interop
      // For example, using the dart:js package:
      /*
      import 'dart:js' as js;
      
      js.context.callMethod('showNotification', [title, body]);
      
      // And in your index.html, you'd have:
      // <script>
      //   function showNotification(title, body) {
      //     if (Notification.permission === "granted") {
      //       new Notification(title, { body: body });
      //     }
      //   }
      // </script>
      */

      // For now, we'll just log it
      log('Web notification: $title - $body');
    }
  }
}
