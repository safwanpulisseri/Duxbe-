import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_repository.g.dart';

@Riverpod(keepAlive: true)
IAnalyticsRepository analyticsRepo(AnalyticsRepoRef ref) => AnalyticsRepository(ref);

class AnalyticsRepository implements IAnalyticsRepository {
  AnalyticsRepository(this.ref) : _firebaseAnalytics = ref.watch(analyticsProvider);
  final AnalyticsRepoRef ref;
  final FirebaseAnalytics _firebaseAnalytics;

  @override
  void logEvent(String eventName, Map<String, Object>? parameters) {
    try {
      // Add timestamp to all events
      final enrichedParams = {
        ...?parameters,
        AnalyticsParams.timestamp: DateTime.now().toIso8601String(),
      };

      _firebaseAnalytics.logEvent(name: eventName, parameters: enrichedParams);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  @override
  void setUserId(String userId) {
    try {
      _firebaseAnalytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('Analytics error setting user ID: $e');
    }
  }

  @override
  void setUserProperties(Map<String, Object> properties) {
    try {
      properties.forEach((key, value) {
        if (value is String) {
          _firebaseAnalytics.setUserProperty(name: key, value: value);
        }
      });
    } catch (e) {
      debugPrint('Analytics error setting user properties: $e');
    }
  }

  @override
  void trackSessionStart(String userId, String userRole) {
    logEvent(
      AuthEvents.sessionStart,
      {
        AnalyticsParams.userId: userId,
        AnalyticsParams.userRole: userRole,
        AnalyticsParams.eventCategory: 'session',
        AnalyticsParams.eventAction: 'start',
        AnalyticsParams.platform: kIsWeb ? 'web' : 'mobile',
      },
    );
  }

  @override
  void trackSessionEnd(String userId) {
    logEvent(
      AuthEvents.sessionEnd,
      {
        AnalyticsParams.userId: userId,
        AnalyticsParams.eventCategory: 'session',
        AnalyticsParams.eventAction: 'end',
      },
    );
  }

  @override
  void trackModuleOpened(String moduleName, String userId, String? companyId) {
    final params = {
      AnalyticsParams.moduleName: moduleName,
      AnalyticsParams.userId: userId,
      AnalyticsParams.eventCategory: 'navigation',
      AnalyticsParams.eventAction: 'module_open',
    };

    if (companyId != null) {
      params[AnalyticsParams.companyId] = companyId;
    }

    logEvent(NavigationEvents.moduleOpened, params);
  }

  @override
  void trackButtonClick(String buttonName, String moduleName, String userId) {
    logEvent(
      InteractionEvents.buttonClicked,
      {
        AnalyticsParams.buttonName: buttonName,
        AnalyticsParams.moduleName: moduleName,
        AnalyticsParams.userId: userId,
        AnalyticsParams.eventCategory: 'interaction',
        AnalyticsParams.eventAction: 'click',
      },
    );
  }

  @override
  void trackFormSubmit(String formName, String moduleName, String userId, bool success) {
    logEvent(
      'form_submit',
      {
        'form_name': formName,
        AnalyticsParams.moduleName: moduleName,
        AnalyticsParams.userId: userId,
        AnalyticsParams.eventCategory: 'interaction',
        AnalyticsParams.eventAction: 'form_submit',
        'success': success,
      },
    );
  }

  @override
  void trackSearch(String searchTerm, String moduleName, String userId, int resultCount) {
    logEvent(
      InteractionEvents.searchUsed,
      {
        'search_term': searchTerm,
        'result_count': resultCount,
        AnalyticsParams.moduleName: moduleName,
        AnalyticsParams.userId: userId,
        AnalyticsParams.eventCategory: 'interaction',
        AnalyticsParams.eventAction: 'search',
      },
    );
  }

  @override
  void trackError(String errorMessage, String moduleName, String userId) {
    logEvent(
      NotificationEvents.errorPopupSeen,
      {
        'error_message': errorMessage,
        AnalyticsParams.moduleName: moduleName,
        AnalyticsParams.userId: userId,
        AnalyticsParams.eventCategory: 'error',
        AnalyticsParams.eventAction: 'error_displayed',
      },
    );
  }
}
