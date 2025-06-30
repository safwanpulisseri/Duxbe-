import 'dart:developer';

import 'package:duxbe/app/app.dart';
import 'package:duxbe/bootstrap.dart';
import 'package:duxbe/env.dart';
import 'package:duxbe/firebase_options_dev.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';

Future<void> main() async {
  tz.initializeTimeZones();

  // for scaling purposes, if required use the below code
  ScaledWidgetsFlutterBinding.ensureInitialized(
    scaleFactor: (deviceSize) {
      final isTablet = deviceSize.width > tabletSize;
      final isLandscape = deviceSize.width > deviceSize.height;

      // Set orientation restrictions
      if (isTablet) {
        // Allow all orientations for tablets
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } else {
        // Lock to portrait for mobile
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }

      // Apply scaling only in landscape mode
      if (isLandscape) {
        const widthOfDesign = kIsWeb ? 2200 : 2200;
        return deviceSize.width / widthOfDesign;
      }

      return 1; // No scaling in portrait mode
    },
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize device ID if not exists
  if (!prefs.containsKey('device_id')) {
    final deviceId = const Uuid().v4();
    await prefs.setString('device_id', deviceId);
  }

  // For analytics
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    log(e.toString());
  }

  // Used to remove trailing # in urls
  usePathUrlStrategy();

  // Envrionment
  const env = DevelopmentEnv();

  // Supabase config
  await Supabase.initialize(
    url: env.SERVER_URL,
    anonKey: env.ANON_KEY,
    debug: true,
  );

  await bootstrap(() => App(environment: env));
}
