abstract class IAnalyticsRepository {
  /// Generic event logging method
  void logEvent(String eventName, Map<String, Object>? parameters);
   
  /// Set user ID for better tracking
  void setUserId(String userId);

  /// Set user properties for better user segmentation
  void setUserProperties(Map<String, Object> properties);

  /// Track session start
  void trackSessionStart(String userId, String userRole);

  /// Track session end
  void trackSessionEnd(String userId);

  /// Track module navigation
  void trackModuleOpened(String moduleName, String userId, String? companyId);

  /// Track button clicks with context
  void trackButtonClick(String buttonName, String moduleName, String userId);

  /// Track form submissions
  void trackFormSubmit(String formName, String moduleName, String userId, bool success);

  /// Track search actions
  void trackSearch(String searchTerm, String moduleName, String userId, int resultCount);

  /// Track errors
  void trackError(String errorMessage, String moduleName, String userId);
}
