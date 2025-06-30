import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsProvider = Provider<FirebaseAnalytics>(
  (ref) => FirebaseAnalytics.instance..setAnalyticsCollectionEnabled(true),
);

final analyticsObserverProvider = Provider<FirebaseAnalyticsObserver>(
  (ref) => FirebaseAnalyticsObserver(
    analytics: ref.watch(analyticsProvider),
  ),
);
