import 'dart:developer';
import 'dart:io';

import 'package:duxbe/app/app.dart';
import 'package:duxbe/bootstrap.dart';
import 'package:duxbe/env.dart';
import 'package:duxbe/firebase_options_prod.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

class MyHttpoverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpoverrides();

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
        const widthOfDesign = kIsWeb ? 1920 : 1600;
        return deviceSize.width / widthOfDesign;
      }

      return 1; // No scaling in portrait mode
    },
  );

  // WidgetsFlutterBinding.ensureInitialized();

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
  const env = ProductionEnv();

  // Supabase config
  await Supabase.initialize(
    url: env.SERVER_URL,
    anonKey: env.ANON_KEY,
    debug: false,
  );

  await bootstrap(() => App(environment: env));
}
