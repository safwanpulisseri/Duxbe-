// Analytics event constants for Google Analytics 4
// Based on the Duxbe SaaS Dashboard Event Tracking Specification

// 1. Login & Session Events
class AuthEvents {
  static const String loginSuccess = 'login_success';
  static const String logout = 'logout';
  static const String sessionStart = 'user_session_start';
  static const String sessionEnd = 'user_session_end';
  static const String passwordReset = 'password_reset';
}

// 2. Navigation & Module Access
class NavigationEvents {
  static const String moduleOpened = 'module_opened';
}

// 3. POS Module Events
class POSEvents {
  static const String newInvoiceCreated = 'new_invoice_created';
  static const String invoiceSavedDraft = 'invoice_saved_draft';
  static const String invoicePrinted = 'invoice_printed';
  static const String invoicePaid = 'invoice_paid';
  static const String productAdded = 'pos_product_added';
  static const String discountApplied = 'pos_discount_applied';
}

// 4. Inventory Module Events
class InventoryEvents {
  static const String itemAdded = 'inventory_item_added';
  static const String itemEdited = 'inventory_item_edited';
  static const String stockUpdated = 'stock_updated';
  static const String lowStockAlertSeen = 'low_stock_alert_seen';
}

// 5. Sales & Purchase Module
class SalesEvents {
  static const String salesOrderCreated = 'sales_order_created';
  static const String salesOrderApproved = 'sales_order_approved';
  static const String purchaseOrderCreated = 'purchase_order_created';
  static const String purchaseOrderSent = 'purchase_order_sent';
}

// 6. Customer Management (CRM)
class CRMEvents {
  static const String customerAdded = 'customer_added';
  static const String customerUpdated = 'customer_updated';
  static const String customerDeleted = 'customer_deleted';
  static const String customerTagged = 'customer_tagged';
}

// 7. Reports & Insights
class ReportEvents {
  static const String reportGenerated = 'report_generated';
  static const String reportExported = 'report_exported';
  static const String dashboardFilterApplied = 'dashboard_filter_applied';
}

// 8. User Interaction & Engagement
class InteractionEvents {
  static const String searchUsed = 'search_used';
  static const String buttonClicked = 'button_clicked';
  static const String tabSwitched = 'tab_switched';
}

// 9. Account & Settings
class AccountEvents {
  static const String profileUpdated = 'profile_updated';
  static const String whatsappConnected = 'whatsapp_connected';
  static const String planUpgraded = 'plan_upgraded';
}

// 10. Notifications & Errors
class NotificationEvents {
  static const String notificationClicked = 'notification_clicked';
  static const String errorPopupSeen = 'error_popup_seen';
  static const String feedbackSubmitted = 'feedback_submitted';
}

// Common parameter keys for events
class AnalyticsParams {
  // Common parameters
  static const String eventCategory = 'event_category';
  static const String eventAction = 'event_action';
  static const String eventLabel = 'event_label';
  static const String userId = 'user_id';
  static const String companyId = 'company_id';
  static const String moduleName = 'module_name';
  static const String userRole = 'user_role';
  static const String interactionType = 'interaction_type';
  static const String timestamp = 'timestamp';

  // Module-specific parameters
  static const String reportType = 'report_type';
  static const String buttonName = 'button_name';
  static const String fromTab = 'from_tab';
  static const String toTab = 'to_tab';
  static const String platform = 'platform';
}

// Module names for consistent tracking
class ModuleNames {
  static const String inventory = 'Inventory';
  static const String sales = 'Sales';
  static const String pos = 'POS';
  static const String crm = 'CRM';
  static const String accounting = 'Accounting';
  static const String reports = 'Reports';
  static const String settings = 'Settings';
}
