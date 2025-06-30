import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @accessYourPersonalizedDashboardByEnteringYourCredentialsBelow.
  ///
  /// In en, this message translates to:
  /// **'Access your personalized dashboard by entering your credentials below.'**
  String get accessYourPersonalizedDashboardByEnteringYourCredentialsBelow;

  /// No description provided for @accounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get accounting;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Add Adjustment'**
  String get addAdjustment;

  /// No description provided for @addBranch.
  ///
  /// In en, this message translates to:
  /// **'Add Branch'**
  String get addBranch;

  /// No description provided for @addBrand.
  ///
  /// In en, this message translates to:
  /// **'Add Brand'**
  String get addBrand;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @addExistingUserFromOtherBranch.
  ///
  /// In en, this message translates to:
  /// **'Add existing user from other branch'**
  String get addExistingUserFromOtherBranch;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @addExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Expense Category'**
  String get addExpenseCategory;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @addIncomeCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Income Category'**
  String get addIncomeCategory;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @addItemToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add Item to Order'**
  String get addItemToOrder;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @addMoreItems.
  ///
  /// In en, this message translates to:
  /// **'Add more items'**
  String get addMoreItems;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @addNewArea.
  ///
  /// In en, this message translates to:
  /// **'Add New Area'**
  String get addNewArea;

  /// No description provided for @addNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// No description provided for @addNewPayment.
  ///
  /// In en, this message translates to:
  /// **'Add New Payment'**
  String get addNewPayment;

  /// No description provided for @addNewReservations.
  ///
  /// In en, this message translates to:
  /// **'Add New Reservations'**
  String get addNewReservations;

  /// No description provided for @addNewRow.
  ///
  /// In en, this message translates to:
  /// **'Add New Row'**
  String get addNewRow;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @addon.
  ///
  /// In en, this message translates to:
  /// **'Addon'**
  String get addon;

  /// No description provided for @addonConfigurationSummary.
  ///
  /// In en, this message translates to:
  /// **'Addon Configuration & Summary'**
  String get addonConfigurationSummary;

  /// No description provided for @addons.
  ///
  /// In en, this message translates to:
  /// **'Addons'**
  String get addons;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Shipping Address'**
  String get addShippingAddress;

  /// No description provided for @addStockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Add Stock Adjustment'**
  String get addStockAdjustment;

  /// No description provided for @addSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplier;

  /// No description provided for @addTable.
  ///
  /// In en, this message translates to:
  /// **'Add Table'**
  String get addTable;

  /// No description provided for @addTax.
  ///
  /// In en, this message translates to:
  /// **'Add Tax'**
  String get addTax;

  /// No description provided for @addUnit.
  ///
  /// In en, this message translates to:
  /// **'Add Unit'**
  String get addUnit;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @addUserRole.
  ///
  /// In en, this message translates to:
  /// **'Add User Role'**
  String get addUserRole;

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get adjustStock;

  /// No description provided for @adminAndStaffSettings.
  ///
  /// In en, this message translates to:
  /// **'Admin and Staff Settings'**
  String get adminAndStaffSettings;

  /// No description provided for @adminName.
  ///
  /// In en, this message translates to:
  /// **'Admin Name'**
  String get adminName;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @alertQty.
  ///
  /// In en, this message translates to:
  /// **'Alert Qty'**
  String get alertQty;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allowSalesWhenOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Allow sales when out of stock'**
  String get allowSalesWhenOutOfStock;

  /// No description provided for @allowWalkInCustomers.
  ///
  /// In en, this message translates to:
  /// **'Allow Walk-in Customers'**
  String get allowWalkInCustomers;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAnAccount;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountCredited.
  ///
  /// In en, this message translates to:
  /// **'Amount Credited'**
  String get amountCredited;

  /// No description provided for @amountReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount Received'**
  String get amountReceived;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @areaName.
  ///
  /// In en, this message translates to:
  /// **'Area Name'**
  String get areaName;

  /// No description provided for @areYouSureWantToDeleteSupplierName.
  ///
  /// In en, this message translates to:
  /// **'Are you sure want to delete {supplierName}?'**
  String areYouSureWantToDeleteSupplierName(String supplierName);

  /// No description provided for @areYouSureYouWantToDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get areYouSureYouWantToDelete;

  /// No description provided for @areYouSureYouWantToDeleteBusiness.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete business {businessName}?'**
  String areYouSureYouWantToDeleteBusiness(String businessName);

  /// No description provided for @areYouSureYouWantToDeleteCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {customerName}?'**
  String areYouSureYouWantToDeleteCustomerName(String customerName);

  /// No description provided for @areYouSureYouWantToDeleteThisExpense.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get areYouSureYouWantToDeleteThisExpense;

  /// No description provided for @areYouSureYouWantToDeleteThisIncome.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this income?'**
  String get areYouSureYouWantToDeleteThisIncome;

  /// No description provided for @areYouSureYouWantToDeleteThisQuote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this quote?'**
  String get areYouSureYouWantToDeleteThisQuote;

  /// No description provided for @areYouSureYouWantToDeleteThisRefund.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this refund?'**
  String get areYouSureYouWantToDeleteThisRefund;

  /// No description provided for @areYouSureYouWantToDeleteThisStockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this stock adjustment?'**
  String get areYouSureYouWantToDeleteThisStockAdjustment;

  /// No description provided for @areYouSureYouWantToDeleteThisTable.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure You Want To Delete this Table'**
  String get areYouSureYouWantToDeleteThisTable;

  /// No description provided for @areYouSureYouWantToDeleteThisTax.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this tax?'**
  String get areYouSureYouWantToDeleteThisTax;

  /// No description provided for @areYouSureYouWantToDeleteThisUserRole.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this User Role?'**
  String get areYouSureYouWantToDeleteThisUserRole;

  /// No description provided for @areYouSureYouWantToRemoveThisUserFromAccessingThisBranch.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this user from accessing this branch ?'**
  String get areYouSureYouWantToRemoveThisUserFromAccessingThisBranch;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @assignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedTo;

  /// No description provided for @assignTable.
  ///
  /// In en, this message translates to:
  /// **'Assign Table'**
  String get assignTable;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @auditHistory.
  ///
  /// In en, this message translates to:
  /// **'Audit History'**
  String get auditHistory;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @backToTableManagement.
  ///
  /// In en, this message translates to:
  /// **'Back To Table Management'**
  String get backToTableManagement;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @billDetails.
  ///
  /// In en, this message translates to:
  /// **'Bill Details'**
  String get billDetails;

  /// No description provided for @billedAnnually.
  ///
  /// In en, this message translates to:
  /// **'Billed annually'**
  String get billedAnnually;

  /// No description provided for @billing.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billing;

  /// No description provided for @billingAddress.
  ///
  /// In en, this message translates to:
  /// **'Billing Address'**
  String get billingAddress;

  /// No description provided for @billingDetails.
  ///
  /// In en, this message translates to:
  /// **'Billing Details'**
  String get billingDetails;

  /// No description provided for @billNo.
  ///
  /// In en, this message translates to:
  /// **'Bill No.'**
  String get billNo;

  /// No description provided for @billTo.
  ///
  /// In en, this message translates to:
  /// **'Bill To'**
  String get billTo;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @branchDetails.
  ///
  /// In en, this message translates to:
  /// **'Branch Details'**
  String get branchDetails;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get brandName;

  /// No description provided for @brands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brands;

  /// No description provided for @businessData.
  ///
  /// In en, this message translates to:
  /// **'Business data'**
  String get businessData;

  /// No description provided for @businessDetails.
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get businessDetails;

  /// No description provided for @businessLegalName.
  ///
  /// In en, this message translates to:
  /// **'Business legal name'**
  String get businessLegalName;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @businessSettings.
  ///
  /// In en, this message translates to:
  /// **'Business Settings'**
  String get businessSettings;

  /// No description provided for @businessTradeName.
  ///
  /// In en, this message translates to:
  /// **'Business trade name'**
  String get businessTradeName;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get businessType;

  /// No description provided for @byContinuingYouWillBePartOfOrgPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you will be a part of '**
  String get byContinuingYouWillBePartOfOrgPrefix;

  /// No description provided for @byRegisterIAgree.
  ///
  /// In en, this message translates to:
  /// **'By Register, I agree '**
  String get byRegisterIAgree;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelActiveAddonsBeforeChangingPlan.
  ///
  /// In en, this message translates to:
  /// **'Please cancel the active addons before changing the plan'**
  String get cancelActiveAddonsBeforeChangingPlan;

  /// No description provided for @cancelReservation.
  ///
  /// In en, this message translates to:
  /// **'Cancel Reservation'**
  String get cancelReservation;

  /// No description provided for @cancelThisReservation.
  ///
  /// In en, this message translates to:
  /// **'Cancel this reservation?'**
  String get cancelThisReservation;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @cartIsEmptyCannotHold.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty. Cannot hold.'**
  String get cartIsEmptyCannotHold;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryStatus.
  ///
  /// In en, this message translates to:
  /// **'Category Status'**
  String get categoryStatus;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changeTableS.
  ///
  /// In en, this message translates to:
  /// **'Change Table(s)'**
  String get changeTableS;

  /// No description provided for @chartOfAccounts.
  ///
  /// In en, this message translates to:
  /// **'Chart of Accounts'**
  String get chartOfAccounts;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose Date'**
  String get chooseDate;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @chooseItem.
  ///
  /// In en, this message translates to:
  /// **'Choose Item'**
  String get chooseItem;

  /// No description provided for @chooseReservationTable.
  ///
  /// In en, this message translates to:
  /// **'Choose Reservation Table'**
  String get chooseReservationTable;

  /// No description provided for @chooseSlot.
  ///
  /// In en, this message translates to:
  /// **'Choose Slot'**
  String get chooseSlot;

  /// No description provided for @chooseTimePeriod.
  ///
  /// In en, this message translates to:
  /// **'Choose Time Period'**
  String get chooseTimePeriod;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get clearCart;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @cogsProducts.
  ///
  /// In en, this message translates to:
  /// **'COGS: Products'**
  String get cogsProducts;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @compositionScheme.
  ///
  /// In en, this message translates to:
  /// **'Composition scheme'**
  String get compositionScheme;

  /// No description provided for @configure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configure;

  /// No description provided for @confimationPassword.
  ///
  /// In en, this message translates to:
  /// **'Confimation Password'**
  String get confimationPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @continu.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continu;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @convertToInvoice.
  ///
  /// In en, this message translates to:
  /// **'Convert to Invoice'**
  String get convertToInvoice;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 Duxbe. All Rights Reserved.'**
  String get copyright;

  /// No description provided for @couldNotFindSession.
  ///
  /// In en, this message translates to:
  /// **'Could not find session'**
  String get couldNotFindSession;

  /// No description provided for @couldNotOpenInvoiceLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open invoice link.'**
  String get couldNotOpenInvoiceLink;

  /// No description provided for @couldnTFindTheSlot.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find the slot'**
  String get couldnTFindTheSlot;

  /// Text shown in the AppBar of the Counter Page
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counterAppBarTitle;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @createANewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get createANewPassword;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'created'**
  String get created;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get createdBy;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get createNew;

  /// No description provided for @createNewPassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to login and regain access to your account.'**
  String get createNewPassSubtitle;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get createOrder;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPassword;

  /// No description provided for @createPurchase.
  ///
  /// In en, this message translates to:
  /// **'Create Purchase'**
  String get createPurchase;

  /// No description provided for @createPurchaseReturn.
  ///
  /// In en, this message translates to:
  /// **'Create Purchase Return'**
  String get createPurchaseReturn;

  /// No description provided for @createSale.
  ///
  /// In en, this message translates to:
  /// **'Create Sale'**
  String get createSale;

  /// No description provided for @createSaleReturn.
  ///
  /// In en, this message translates to:
  /// **'Create Sale Return'**
  String get createSaleReturn;

  /// No description provided for @createYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Create your Business'**
  String get createYourBusiness;

  /// No description provided for @creditCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Credit created successfully'**
  String get creditCreatedSuccessfully;

  /// No description provided for @creditDate.
  ///
  /// In en, this message translates to:
  /// **'Credit Date'**
  String get creditDate;

  /// No description provided for @creditNote.
  ///
  /// In en, this message translates to:
  /// **'Credit Note'**
  String get creditNote;

  /// No description provided for @creditNotes.
  ///
  /// In en, this message translates to:
  /// **'Credit Notes'**
  String get creditNotes;

  /// No description provided for @creditsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Credits Remaining'**
  String get creditsRemaining;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @currentQuantityBasedOnBillsAndInvoices.
  ///
  /// In en, this message translates to:
  /// **'Current Quantity based on bills and invoices'**
  String get currentQuantityBasedOnBillsAndInvoices;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStock;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @customerBalance.
  ///
  /// In en, this message translates to:
  /// **'Customer Balance'**
  String get customerBalance;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @customerDue.
  ///
  /// In en, this message translates to:
  /// **'Customer Due'**
  String get customerDue;

  /// No description provided for @customerList.
  ///
  /// In en, this message translates to:
  /// **'Customer List'**
  String get customerList;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer Phone'**
  String get customerPhone;

  /// No description provided for @customerRequiredOrder.
  ///
  /// In en, this message translates to:
  /// **'Customer is required for order mode'**
  String get customerRequiredOrder;

  /// No description provided for @customerSettings.
  ///
  /// In en, this message translates to:
  /// **'Customer Settings'**
  String get customerSettings;

  /// No description provided for @customerWallet.
  ///
  /// In en, this message translates to:
  /// **'Customer Wallet'**
  String get customerWallet;

  /// No description provided for @customFields.
  ///
  /// In en, this message translates to:
  /// **'Custom Fields'**
  String get customFields;

  /// No description provided for @dailySales.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales'**
  String get dailySales;

  /// No description provided for @dailyTransaction.
  ///
  /// In en, this message translates to:
  /// **'Daily Transaction'**
  String get dailyTransaction;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @dateRangeToSeparator.
  ///
  /// In en, this message translates to:
  /// **' To '**
  String get dateRangeToSeparator;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date/Time'**
  String get dateTime;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @defaultStateTax.
  ///
  /// In en, this message translates to:
  /// **'Default State Tax'**
  String get defaultStateTax;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteArea.
  ///
  /// In en, this message translates to:
  /// **'Delete Area'**
  String get deleteArea;

  /// No description provided for @deleteBrand.
  ///
  /// In en, this message translates to:
  /// **'Delete Brand'**
  String get deleteBrand;

  /// No description provided for @deleteBusiness.
  ///
  /// In en, this message translates to:
  /// **'Delete Business'**
  String get deleteBusiness;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @deleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer'**
  String get deleteCustomer;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @deleteIncome.
  ///
  /// In en, this message translates to:
  /// **'Delete Income'**
  String get deleteIncome;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @deleteQuote.
  ///
  /// In en, this message translates to:
  /// **'Delete Quote'**
  String get deleteQuote;

  /// No description provided for @deleteStockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Delete Stock Adjustment'**
  String get deleteStockAdjustment;

  /// No description provided for @deleteSupplier.
  ///
  /// In en, this message translates to:
  /// **'Delete Supplier'**
  String get deleteSupplier;

  /// No description provided for @deleteTax.
  ///
  /// In en, this message translates to:
  /// **'Delete Tax'**
  String get deleteTax;

  /// No description provided for @deleteThisBrand.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Brand?'**
  String get deleteThisBrand;

  /// No description provided for @deleteThisCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Category?'**
  String get deleteThisCategory;

  /// No description provided for @deleteThisItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteThisItem;

  /// No description provided for @deleteThisUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get deleteThisUser;

  /// No description provided for @deleteUnit.
  ///
  /// In en, this message translates to:
  /// **'Delete Unit'**
  String get deleteUnit;

  /// No description provided for @deleteUnitSub.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Unit?'**
  String get deleteUnitSub;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @deleteUserRole.
  ///
  /// In en, this message translates to:
  /// **'Delete User Role'**
  String get deleteUserRole;

  /// No description provided for @depositTo.
  ///
  /// In en, this message translates to:
  /// **'Deposit To'**
  String get depositTo;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @discountsOnPurchases.
  ///
  /// In en, this message translates to:
  /// **'Discounts on Purchases (-)'**
  String get discountsOnPurchases;

  /// No description provided for @discountsOnSales.
  ///
  /// In en, this message translates to:
  /// **'Discounts on Sales (-)'**
  String get discountsOnSales;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @donTHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get donTHaveAnAccount;

  /// No description provided for @downgrade.
  ///
  /// In en, this message translates to:
  /// **'Downgrade'**
  String get downgrade;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloadASampleFileAndCompareItToYourImportFileToEnsureYouHaveTheFilePerfectForTheImport.
  ///
  /// In en, this message translates to:
  /// **'Download a sample file and compare it to your import file to ensure you have the file perfect for the import.'**
  String
      get downloadASampleFileAndCompareItToYourImportFileToEnsureYouHaveTheFilePerfectForTheImport;

  /// No description provided for @downloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoice;

  /// No description provided for @downloadSampleFile.
  ///
  /// In en, this message translates to:
  /// **'Download Sample File'**
  String get downloadSampleFile;

  /// No description provided for @doYouHaveGstNumber.
  ///
  /// In en, this message translates to:
  /// **'Do you have GST number?'**
  String get doYouHaveGstNumber;

  /// No description provided for @dragAndDropFileToImport.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop file to import'**
  String get dragAndDropFileToImport;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @dueAmount.
  ///
  /// In en, this message translates to:
  /// **'Due Amount'**
  String get dueAmount;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @dueReport.
  ///
  /// In en, this message translates to:
  /// **'Due Report'**
  String get dueReport;

  /// No description provided for @duplicateHandling.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Handling'**
  String get duplicateHandling;

  /// No description provided for @duxbe.
  ///
  /// In en, this message translates to:
  /// **'DUXBE'**
  String get duxbe;

  /// No description provided for @duxbeField.
  ///
  /// In en, this message translates to:
  /// **'DUXBE FIELD'**
  String get duxbeField;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @employeeCode.
  ///
  /// In en, this message translates to:
  /// **'Employee Code'**
  String get employeeCode;

  /// No description provided for @employeeRole.
  ///
  /// In en, this message translates to:
  /// **'Employee Role'**
  String get employeeRole;

  /// No description provided for @employeeRoleDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Employee Role deleted Successfully'**
  String get employeeRoleDeletedSuccessfully;

  /// No description provided for @employeeSales.
  ///
  /// In en, this message translates to:
  /// **'Employee Sales'**
  String get employeeSales;

  /// No description provided for @employeeUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Employee updated successfully'**
  String get employeeUpdatedSuccessfully;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @enableReverseChargeInSalesTransactions.
  ///
  /// In en, this message translates to:
  /// **'Enable reverse charge in sales transactions.'**
  String get enableReverseChargeInSalesTransactions;

  /// No description provided for @enableStockTrackingAndReceiveAlertsWhenInventoryRunsLow.
  ///
  /// In en, this message translates to:
  /// **'Enable stock tracking and receive alerts when inventory runs low'**
  String get enableStockTrackingAndReceiveAlertsWhenInventoryRunsLow;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @enter6Digits.
  ///
  /// In en, this message translates to:
  /// **'Enter 6 Digits'**
  String get enter6Digits;

  /// No description provided for @enterAdminName.
  ///
  /// In en, this message translates to:
  /// **'Enter Admin Name'**
  String get enterAdminName;

  /// No description provided for @enterAmountReceived.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount Received'**
  String get enterAmountReceived;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get enterCompanyName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @enterEmailId.
  ///
  /// In en, this message translates to:
  /// **'Enter Email ID'**
  String get enterEmailId;

  /// No description provided for @enterGstNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter GST Number'**
  String get enterGstNumber;

  /// No description provided for @enterNameCodeOrCategory.
  ///
  /// In en, this message translates to:
  /// **'Enter name, code or category'**
  String get enterNameCodeOrCategory;

  /// No description provided for @enterNameInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Name / Invoice Number'**
  String get enterNameInvoiceNumber;

  /// No description provided for @enterNameOrSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Name or Serial Number'**
  String get enterNameOrSerialNumber;

  /// No description provided for @enterNoteHere.
  ///
  /// In en, this message translates to:
  /// **'Enter note here'**
  String get enterNoteHere;

  /// No description provided for @enterOTPSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kindly input the OTP code sent to your registered email/phone for account verification.'**
  String get enterOTPSubtitle;

  /// No description provided for @enterOtpVerification.
  ///
  /// In en, this message translates to:
  /// **'Enter otp verification'**
  String get enterOtpVerification;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @enterProductSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Product Serial Number'**
  String get enterProductSerialNumber;

  /// No description provided for @enterPurchaseNumberHere.
  ///
  /// In en, this message translates to:
  /// **'Enter Purchase number here'**
  String get enterPurchaseNumberHere;

  /// No description provided for @enterRoleName.
  ///
  /// In en, this message translates to:
  /// **'Enter Role Name'**
  String get enterRoleName;

  /// No description provided for @enterTermsAndConditionsHere.
  ///
  /// In en, this message translates to:
  /// **'Enter terms and conditions here'**
  String get enterTermsAndConditionsHere;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @errorLoadingChartOfAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error On loading Chart of Accounts'**
  String get errorLoadingChartOfAccounts;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategory;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Expense Date'**
  String get expenseDate;

  /// No description provided for @expenseDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted successfully'**
  String get expenseDeletedSuccessfully;

  /// No description provided for @expenseDetails.
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get expenseDetails;

  /// No description provided for @expenseFor.
  ///
  /// In en, this message translates to:
  /// **'Expense For'**
  String get expenseFor;

  /// No description provided for @expenseUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully'**
  String get expenseUpdatedSuccessfully;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @feature1.
  ///
  /// In en, this message translates to:
  /// **'Effortless Billing '**
  String get feature1;

  /// No description provided for @feature2.
  ///
  /// In en, this message translates to:
  /// **'Better Customer Management'**
  String get feature2;

  /// No description provided for @feature3.
  ///
  /// In en, this message translates to:
  /// **'Sales Tracking and Reporting'**
  String get feature3;

  /// No description provided for @feature4.
  ///
  /// In en, this message translates to:
  /// **'Unparalleled Software Support'**
  String get feature4;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @fiscalYear.
  ///
  /// In en, this message translates to:
  /// **'Fiscal Year'**
  String get fiscalYear;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotSubtitile.
  ///
  /// In en, this message translates to:
  /// **'No worries. We\'ll help you reset it. Just follow the instructions below to regain access to your account.'**
  String get forgotSubtitile;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Your Password?'**
  String get forgotYourPassword;

  /// No description provided for @formatPageSize.
  ///
  /// In en, this message translates to:
  /// **'Format (Page Size)'**
  String get formatPageSize;

  /// No description provided for @freeForever.
  ///
  /// In en, this message translates to:
  /// **'Free Forever'**
  String get freeForever;

  /// No description provided for @freightIn.
  ///
  /// In en, this message translates to:
  /// **'Freight In'**
  String get freightIn;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @generateBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Generate Barcodes'**
  String get generateBarcodes;

  /// No description provided for @generateBarcodeWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Generate Barcode with Price'**
  String get generateBarcodeWithPrice;

  /// No description provided for @getGenius.
  ///
  /// In en, this message translates to:
  /// **'Get Genius'**
  String get getGenius;

  /// No description provided for @getPro.
  ///
  /// In en, this message translates to:
  /// **'Get Pro'**
  String get getPro;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @goods.
  ///
  /// In en, this message translates to:
  /// **'Goods'**
  String get goods;

  /// No description provided for @goToOnlineStore.
  ///
  /// In en, this message translates to:
  /// **'Go to Online Store'**
  String get goToOnlineStore;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @grossProfit.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit'**
  String get grossProfit;

  /// No description provided for @gst18.
  ///
  /// In en, this message translates to:
  /// **'GST (18%)'**
  String get gst18;

  /// No description provided for @gstNumber.
  ///
  /// In en, this message translates to:
  /// **'GST Number'**
  String get gstNumber;

  /// No description provided for @gstRegisteredOn.
  ///
  /// In en, this message translates to:
  /// **'GST registered on'**
  String get gstRegisteredOn;

  /// No description provided for @gstSettings.
  ///
  /// In en, this message translates to:
  /// **'GST Settings'**
  String get gstSettings;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @heldDate.
  ///
  /// In en, this message translates to:
  /// **'Held Date'**
  String get heldDate;

  /// No description provided for @heldOn.
  ///
  /// In en, this message translates to:
  /// **'Held on'**
  String get heldOn;

  /// No description provided for @helloHancod.
  ///
  /// In en, this message translates to:
  /// **'Hello Hancod!'**
  String get helloHancod;

  /// No description provided for @hereIsYourStoreUrl.
  ///
  /// In en, this message translates to:
  /// **'Here is your store URL'**
  String get hereIsYourStoreUrl;

  /// No description provided for @hereIsYourWeeklyOverviewReport.
  ///
  /// In en, this message translates to:
  /// **'Here is your weekly overview report'**
  String get hereIsYourWeeklyOverviewReport;

  /// No description provided for @hmmm.
  ///
  /// In en, this message translates to:
  /// **'Hmmm!'**
  String get hmmm;

  /// No description provided for @holdBill.
  ///
  /// In en, this message translates to:
  /// **'Hold Bill'**
  String get holdBill;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @imageSizeExceeds10mb.
  ///
  /// In en, this message translates to:
  /// **'Image size exceeds 10MB'**
  String get imageSizeExceeds10mb;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importedFileHeaders.
  ///
  /// In en, this message translates to:
  /// **'IMPORTED FILE HEADERS'**
  String get importedFileHeaders;

  /// No description provided for @importItemGoodsSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Import Item Goods - Select File'**
  String get importItemGoodsSelectFile;

  /// No description provided for @importPreview.
  ///
  /// In en, this message translates to:
  /// **'Import Preview'**
  String get importPreview;

  /// No description provided for @importsTheDuplicatesInTheImportFileAndOverwritesTheExistingItems.
  ///
  /// In en, this message translates to:
  /// **'Imports the duplicates in the import file and overwrites the existing items.'**
  String get importsTheDuplicatesInTheImportFileAndOverwritesTheExistingItems;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @incomeCategory.
  ///
  /// In en, this message translates to:
  /// **'Income Category'**
  String get incomeCategory;

  /// No description provided for @incomeDate.
  ///
  /// In en, this message translates to:
  /// **'Income Date'**
  String get incomeDate;

  /// No description provided for @incomeDetails.
  ///
  /// In en, this message translates to:
  /// **'Income Details'**
  String get incomeDetails;

  /// No description provided for @incomeFor.
  ///
  /// In en, this message translates to:
  /// **'Income For'**
  String get incomeFor;

  /// No description provided for @incomeGeneral.
  ///
  /// In en, this message translates to:
  /// **'Income: General'**
  String get incomeGeneral;

  /// No description provided for @incomeStockOverage.
  ///
  /// In en, this message translates to:
  /// **'Income: Stock Overage'**
  String get incomeStockOverage;

  /// No description provided for @inLast30Days.
  ///
  /// In en, this message translates to:
  /// **'In Last 30 Days'**
  String get inLast30Days;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @invalidFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format'**
  String get invalidFileFormat;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @inventoryAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Inventory Adjustment'**
  String get inventoryAdjustment;

  /// No description provided for @inventoryInformation.
  ///
  /// In en, this message translates to:
  /// **'Inventory Information'**
  String get inventoryInformation;

  /// No description provided for @inventorySettings.
  ///
  /// In en, this message translates to:
  /// **'Inventory Settings'**
  String get inventorySettings;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @invoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Invoice date'**
  String get invoiceDate;

  /// No description provided for @invoiceId.
  ///
  /// In en, this message translates to:
  /// **'Invoice ID'**
  String get invoiceId;

  /// No description provided for @invoiceNo.
  ///
  /// In en, this message translates to:
  /// **'Invoice No'**
  String get invoiceNo;

  /// No description provided for @invoiceNoNo.
  ///
  /// In en, this message translates to:
  /// **'Invoice No. : {No}'**
  String invoiceNoNo(String No);

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice number'**
  String get invoiceNumber;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @invoiceTax.
  ///
  /// In en, this message translates to:
  /// **'Invoice Tax'**
  String get invoiceTax;

  /// No description provided for @invoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Invoice Total'**
  String get invoiceTotal;

  /// No description provided for @isTaxInclusive.
  ///
  /// In en, this message translates to:
  /// **'Is Tax Inclusive'**
  String get isTaxInclusive;

  /// No description provided for @isYourBusinessRegisteredFor.
  ///
  /// In en, this message translates to:
  /// **'Is your business registered for'**
  String get isYourBusinessRegisteredFor;

  /// No description provided for @itemAdded.
  ///
  /// In en, this message translates to:
  /// **'Item added successfully'**
  String get itemAdded;

  /// No description provided for @itemCategory.
  ///
  /// In en, this message translates to:
  /// **'Item Category'**
  String get itemCategory;

  /// No description provided for @itemCategoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Item Category Added Successfully'**
  String get itemCategoryAdded;

  /// No description provided for @itemCategoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item Category Deleted Successfully'**
  String get itemCategoryDeleted;

  /// No description provided for @itemCategoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Item Category Updated Successfully'**
  String get itemCategoryUpdated;

  /// No description provided for @itemCode.
  ///
  /// In en, this message translates to:
  /// **'Item Code'**
  String get itemCode;

  /// No description provided for @itemCodeBarcode.
  ///
  /// In en, this message translates to:
  /// **'Item Code/Barcode'**
  String get itemCodeBarcode;

  /// No description provided for @itemDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully'**
  String get itemDeletedSuccessfully;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @itemImport.
  ///
  /// In en, this message translates to:
  /// **'Item Import'**
  String get itemImport;

  /// No description provided for @itemList.
  ///
  /// In en, this message translates to:
  /// **'Item List'**
  String get itemList;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @itemNameShouldNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Item name should not be empty'**
  String get itemNameShouldNotBeEmpty;

  /// No description provided for @itemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item not found'**
  String get itemNotFound;

  /// No description provided for @itemQuantityPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Item Quantity (per unit)'**
  String get itemQuantityPerUnit;

  /// No description provided for @itemReturned.
  ///
  /// In en, this message translates to:
  /// **'Item Returned'**
  String get itemReturned;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @itemsOrdered.
  ///
  /// In en, this message translates to:
  /// **'Items Ordered'**
  String get itemsOrdered;

  /// No description provided for @itemSpecification.
  ///
  /// In en, this message translates to:
  /// **'Item Specification'**
  String get itemSpecification;

  /// No description provided for @itemsSummaryLength.
  ///
  /// In en, this message translates to:
  /// **'Items summary ({length})'**
  String itemsSummaryLength(String length);

  /// No description provided for @itemsThatAreReadyToBeImported.
  ///
  /// In en, this message translates to:
  /// **'Items that are ready to be imported -'**
  String get itemsThatAreReadyToBeImported;

  /// No description provided for @itemTotal.
  ///
  /// In en, this message translates to:
  /// **'Item Total'**
  String get itemTotal;

  /// No description provided for @itemUnit.
  ///
  /// In en, this message translates to:
  /// **'Item Unit'**
  String get itemUnit;

  /// No description provided for @jpgOrPngFileSizeNoMoreThan10mb.
  ///
  /// In en, this message translates to:
  /// **'JPG or PNG, file size no more than 10MB'**
  String get jpgOrPngFileSizeNoMoreThan10mb;

  /// No description provided for @last10Days.
  ///
  /// In en, this message translates to:
  /// **'Last 10 days'**
  String get last10Days;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get last3Months;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get last6Months;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @ledgerDetails.
  ///
  /// In en, this message translates to:
  /// **'Ledger Details'**
  String get ledgerDetails;

  /// No description provided for @linkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopiedToClipboard;

  /// No description provided for @listOfHeldCarts.
  ///
  /// In en, this message translates to:
  /// **'List of Held Carts'**
  String get listOfHeldCarts;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Access your personalized dashboard by entering your credentials below. We\'re excited to have you back with us!'**
  String get loginDescription;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Partner in Streamlined Sales'**
  String get loginSubtitle;

  /// No description provided for @loginSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Login Successfully'**
  String get loginSuccessfully;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'ERP\nREDEFINED'**
  String get loginTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logOutFromDuxbe.
  ///
  /// In en, this message translates to:
  /// **'Are sure you want to log out from Duxbe?'**
  String get logOutFromDuxbe;

  /// No description provided for @lowStocks.
  ///
  /// In en, this message translates to:
  /// **'Low Stocks'**
  String get lowStocks;

  /// No description provided for @manageArea.
  ///
  /// In en, this message translates to:
  /// **'Manage Area'**
  String get manageArea;

  /// No description provided for @manageStock.
  ///
  /// In en, this message translates to:
  /// **'Manage Stock'**
  String get manageStock;

  /// No description provided for @mapFields.
  ///
  /// In en, this message translates to:
  /// **'Map Fields'**
  String get mapFields;

  /// No description provided for @markAsSent.
  ///
  /// In en, this message translates to:
  /// **'Mark as Sent'**
  String get markAsSent;

  /// No description provided for @markAttendance.
  ///
  /// In en, this message translates to:
  /// **'Mark Attendance'**
  String get markAttendance;

  /// No description provided for @maximumFileSize25MbFileFormatXls.
  ///
  /// In en, this message translates to:
  /// **'Maximum File Size: 25 MB • File Format: XLS'**
  String get maximumFileSize25MbFileFormatXls;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Menu Settings'**
  String get menuSettings;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @moreInfo.
  ///
  /// In en, this message translates to:
  /// **'More Info'**
  String get moreInfo;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @myBusinessIsRegisteredForCompositionScheme.
  ///
  /// In en, this message translates to:
  /// **'My business is registered for composition scheme.'**
  String get myBusinessIsRegisteredForCompositionScheme;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @nA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get nA;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @namePrice.
  ///
  /// In en, this message translates to:
  /// **'Name & Price'**
  String get namePrice;

  /// No description provided for @netProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Net Profit/Loss'**
  String get netProfitLoss;

  /// No description provided for @newAddress.
  ///
  /// In en, this message translates to:
  /// **'New Address'**
  String get newAddress;

  /// No description provided for @newAdjustment.
  ///
  /// In en, this message translates to:
  /// **'New Adjustment'**
  String get newAdjustment;

  /// No description provided for @newCustomers.
  ///
  /// In en, this message translates to:
  /// **'New Customers'**
  String get newCustomers;

  /// No description provided for @newDue.
  ///
  /// In en, this message translates to:
  /// **'New Due'**
  String get newDue;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @newIncome.
  ///
  /// In en, this message translates to:
  /// **'New Income'**
  String get newIncome;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newQuantity.
  ///
  /// In en, this message translates to:
  /// **'New quantity'**
  String get newQuantity;

  /// No description provided for @newQuantityHand.
  ///
  /// In en, this message translates to:
  /// **'new quantity(hand)'**
  String get newQuantityHand;

  /// No description provided for @newQuantityOnHand.
  ///
  /// In en, this message translates to:
  /// **'New Quantity on hand'**
  String get newQuantityOnHand;

  /// No description provided for @newReservation.
  ///
  /// In en, this message translates to:
  /// **'New Reservation'**
  String get newReservation;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @nextBillingDate.
  ///
  /// In en, this message translates to:
  /// **'Next Billing Date'**
  String get nextBillingDate;

  /// No description provided for @nextPurchase.
  ///
  /// In en, this message translates to:
  /// **'Next Purchase'**
  String get nextPurchase;

  /// No description provided for @nextSale.
  ///
  /// In en, this message translates to:
  /// **'Next Sale'**
  String get nextSale;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noBillingAddressAvailable.
  ///
  /// In en, this message translates to:
  /// **'No billing address available'**
  String get noBillingAddressAvailable;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data!'**
  String get noData;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'It looks like there\'s no data available at the moment'**
  String get noDataAvailable;

  /// No description provided for @noHeldBillsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No held bills available.'**
  String get noHeldBillsAvailable;

  /// No description provided for @noOfItems.
  ///
  /// In en, this message translates to:
  /// **'No of Items'**
  String get noOfItems;

  /// No description provided for @noOfItemsAdjusted.
  ///
  /// In en, this message translates to:
  /// **'No of Items Adjusted'**
  String get noOfItemsAdjusted;

  /// No description provided for @noOfRecordsSkipped.
  ///
  /// In en, this message translates to:
  /// **'No of Records skipped -'**
  String get noOfRecordsSkipped;

  /// No description provided for @noOfRowsHaveInvalidValues.
  ///
  /// In en, this message translates to:
  /// **'No. of rows have invalid values'**
  String get noOfRowsHaveInvalidValues;

  /// No description provided for @noPlan.
  ///
  /// In en, this message translates to:
  /// **'No Plan'**
  String get noPlan;

  /// No description provided for @noRecentTransaction.
  ///
  /// In en, this message translates to:
  /// **'No Recent Transaction'**
  String get noRecentTransaction;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noResults;

  /// No description provided for @noShippingAddressAvailable.
  ///
  /// In en, this message translates to:
  /// **'No shipping address available'**
  String get noShippingAddressAvailable;

  /// No description provided for @noSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Slots Available'**
  String get noSlotsAvailable;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @oldPasswordDoesnTMatch.
  ///
  /// In en, this message translates to:
  /// **'Old password doesn\'t match'**
  String get oldPasswordDoesnTMatch;

  /// No description provided for @ooops.
  ///
  /// In en, this message translates to:
  /// **'Ooops!'**
  String get ooops;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get openingBalance;

  /// No description provided for @openingStockQty.
  ///
  /// In en, this message translates to:
  /// **'Opening Stock Qty'**
  String get openingStockQty;

  /// No description provided for @openingStockValuePrice.
  ///
  /// In en, this message translates to:
  /// **'Opening Stock Value (Price)'**
  String get openingStockValuePrice;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open Link'**
  String get openLink;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @orCreateNewUser.
  ///
  /// In en, this message translates to:
  /// **'Or Create new User'**
  String get orCreateNewUser;

  /// No description provided for @orderAssignation.
  ///
  /// In en, this message translates to:
  /// **'Order Assignation'**
  String get orderAssignation;

  /// No description provided for @orderCode.
  ///
  /// In en, this message translates to:
  /// **'Order Code'**
  String get orderCode;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @orderList.
  ///
  /// In en, this message translates to:
  /// **'Order List'**
  String get orderList;

  /// No description provided for @orderMode.
  ///
  /// In en, this message translates to:
  /// **'Order Mode'**
  String get orderMode;

  /// No description provided for @orderModeIsNotAvailableForWalkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Order mode is not available for walk-in customer'**
  String get orderModeIsNotAvailableForWalkInCustomer;

  /// No description provided for @orderNotification.
  ///
  /// In en, this message translates to:
  /// **'Order Notification'**
  String get orderNotification;

  /// No description provided for @orderSource.
  ///
  /// In en, this message translates to:
  /// **'Order Source'**
  String get orderSource;

  /// No description provided for @orderUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order updated successfully'**
  String get orderUpdatedSuccessfully;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @overwriteItems.
  ///
  /// In en, this message translates to:
  /// **'Overwrite items'**
  String get overwriteItems;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @paperSize.
  ///
  /// In en, this message translates to:
  /// **'Paper size'**
  String get paperSize;

  /// No description provided for @partyName.
  ///
  /// In en, this message translates to:
  /// **'Party Name'**
  String get partyName;

  /// No description provided for @partySize.
  ///
  /// In en, this message translates to:
  /// **'Party Size'**
  String get partySize;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordChangingFailed.
  ///
  /// In en, this message translates to:
  /// **'Password changing failed'**
  String get passwordChangingFailed;

  /// No description provided for @passwordDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Password does not match.'**
  String get passwordDoesNotMatch;

  /// No description provided for @passwordResetOtpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset OTP sent successfully'**
  String get passwordResetOtpSentSuccessfully;

  /// No description provided for @passwordsDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords does not match'**
  String get passwordsDoesNotMatch;

  /// No description provided for @payIn.
  ///
  /// In en, this message translates to:
  /// **'Pay In'**
  String get payIn;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @paymentFor.
  ///
  /// In en, this message translates to:
  /// **'Payment for'**
  String get paymentFor;

  /// No description provided for @paymentIn.
  ///
  /// In en, this message translates to:
  /// **'Payment In'**
  String get paymentIn;

  /// No description provided for @paymentLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment Last Updated'**
  String get paymentLastUpdated;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get paymentMode;

  /// No description provided for @paymentModePayments.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode : {Payments}'**
  String paymentModePayments(String Payments);

  /// No description provided for @paymentOut.
  ///
  /// In en, this message translates to:
  /// **'Payment Out'**
  String get paymentOut;

  /// No description provided for @paymentOverdueAlertInterval.
  ///
  /// In en, this message translates to:
  /// **'Payment Overdue Alert Interval'**
  String get paymentOverdueAlertInterval;

  /// No description provided for @paymentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get paymentReceipt;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @paymentSuccessfull.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessfull;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentType;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @payOut.
  ///
  /// In en, this message translates to:
  /// **'Pay Out'**
  String get payOut;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'Pdf'**
  String get pdf;

  /// No description provided for @per100Credits.
  ///
  /// In en, this message translates to:
  /// **'/100 credits'**
  String get per100Credits;

  /// No description provided for @performedBy.
  ///
  /// In en, this message translates to:
  /// **'Performed By'**
  String get performedBy;

  /// No description provided for @perMonthly.
  ///
  /// In en, this message translates to:
  /// **'/monthly'**
  String get perMonthly;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @perYearly.
  ///
  /// In en, this message translates to:
  /// **'/yearly'**
  String get perYearly;

  /// No description provided for @phoneNo.
  ///
  /// In en, this message translates to:
  /// **'Phone No.'**
  String get phoneNo;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @placedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed On'**
  String get placedOn;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @planAnnually.
  ///
  /// In en, this message translates to:
  /// **'Plan (Annually)'**
  String get planAnnually;

  /// No description provided for @planDetails.
  ///
  /// In en, this message translates to:
  /// **'Plan Details'**
  String get planDetails;

  /// No description provided for @plansCarefullyCrafted.
  ///
  /// In en, this message translates to:
  /// **'Plans that are carefully crafted to suit your business.'**
  String get plansCarefullyCrafted;

  /// No description provided for @plansInfo.
  ///
  /// In en, this message translates to:
  /// **'Plans Info'**
  String get plansInfo;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @pleaseAddAnItemFirstToCreateASale.
  ///
  /// In en, this message translates to:
  /// **'Please add an item first to create a sale.'**
  String get pleaseAddAnItemFirstToCreateASale;

  /// No description provided for @pleaseAddASaleFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add a Sale first'**
  String get pleaseAddASaleFirst;

  /// No description provided for @pleaseAddAtLeastOneItem.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one item'**
  String get pleaseAddAtLeastOneItem;

  /// No description provided for @pleaseAddProductsFirst.
  ///
  /// In en, this message translates to:
  /// **'Please Add products first'**
  String get pleaseAddProductsFirst;

  /// No description provided for @pleaseAddUnitShortName.
  ///
  /// In en, this message translates to:
  /// **'Please add unit short name'**
  String get pleaseAddUnitShortName;

  /// No description provided for @pleaseEnterAInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a invoice number'**
  String get pleaseEnterAInvoiceNumber;

  /// No description provided for @pleaseEnterAQuoteNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quote number'**
  String get pleaseEnterAQuoteNumber;

  /// No description provided for @pleaseEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter quantity'**
  String get pleaseEnterQuantity;

  /// No description provided for @pleaseEnterTheBrandName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the brand name'**
  String get pleaseEnterTheBrandName;

  /// No description provided for @pleaseEnterTheCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the category name'**
  String get pleaseEnterTheCategoryName;

  /// No description provided for @pleaseEnterTheCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the customer name'**
  String get pleaseEnterTheCustomerName;

  /// No description provided for @pleaseEnterThePuchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter the puchase price'**
  String get pleaseEnterThePuchasePrice;

  /// No description provided for @pleaseEnterTheSalePrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter the sale price'**
  String get pleaseEnterTheSalePrice;

  /// No description provided for @pleaseEnterTheSupplierName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the supplier name'**
  String get pleaseEnterTheSupplierName;

  /// No description provided for @pleaseEnterTheUnitName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the unit name'**
  String get pleaseEnterTheUnitName;

  /// No description provided for @pleaseEnterTheUserName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the user name'**
  String get pleaseEnterTheUserName;

  /// No description provided for @pleaseEnterUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter unit price'**
  String get pleaseEnterUnitPrice;

  /// No description provided for @pleaseFillInAllRequiredFieldsCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields correctly'**
  String get pleaseFillInAllRequiredFieldsCorrectly;

  /// No description provided for @pleaseSelectACustomer.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer'**
  String get pleaseSelectACustomer;

  /// No description provided for @pleaseSelectACustomerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer first'**
  String get pleaseSelectACustomerFirst;

  /// No description provided for @pleaseSelectADate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectADate;

  /// No description provided for @pleaseSelectATaxRate.
  ///
  /// In en, this message translates to:
  /// **'Please select a tax rate'**
  String get pleaseSelectATaxRate;

  /// No description provided for @pleaseSelectATimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Please Select a Time Slot'**
  String get pleaseSelectATimeSlot;

  /// No description provided for @pleaseSelectAtLeastOneItem.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one item'**
  String get pleaseSelectAtLeastOneItem;

  /// No description provided for @pleaseSelectAtleastOneTable.
  ///
  /// In en, this message translates to:
  /// **'Please Select Atleast One Table'**
  String get pleaseSelectAtleastOneTable;

  /// No description provided for @pleaseUpgradeToProToPrintBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Please upgrade to pro to print barcodes'**
  String get pleaseUpgradeToProToPrintBarcodes;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get pos;

  /// No description provided for @poweredByDuxbe.
  ///
  /// In en, this message translates to:
  /// **'Powered By Duxbe'**
  String get poweredByDuxbe;

  /// No description provided for @predefinedStockLevel.
  ///
  /// In en, this message translates to:
  /// **'Predefined stock level at which a notification or alert is triggered to indicate that inventory is running low'**
  String get predefinedStockLevel;

  /// No description provided for @preferredVendor.
  ///
  /// In en, this message translates to:
  /// **'Preferred Vendor'**
  String get preferredVendor;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get price;

  /// No description provided for @priceDetails.
  ///
  /// In en, this message translates to:
  /// **'Price Details'**
  String get priceDetails;

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get pricePerUnit;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @printBarcode.
  ///
  /// In en, this message translates to:
  /// **'Print Barcode'**
  String get printBarcode;

  /// No description provided for @printBarcodeOnPurchase.
  ///
  /// In en, this message translates to:
  /// **'Print Barcode on purchase'**
  String get printBarcodeOnPurchase;

  /// No description provided for @printBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Print Barcodes'**
  String get printBarcodes;

  /// No description provided for @printer.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get printer;

  /// No description provided for @printInvoice.
  ///
  /// In en, this message translates to:
  /// **'Print Invoice'**
  String get printInvoice;

  /// No description provided for @printOnPurchase.
  ///
  /// In en, this message translates to:
  /// **'Print on Purchase'**
  String get printOnPurchase;

  /// No description provided for @printOnSale.
  ///
  /// In en, this message translates to:
  /// **'Print on Sale'**
  String get printOnSale;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// No description provided for @printSettings.
  ///
  /// In en, this message translates to:
  /// **'Print Settings'**
  String get printSettings;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @productSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Product Serial Number'**
  String get productSerialNumber;

  /// No description provided for @profitAndLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit and Loss'**
  String get profitAndLoss;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @purchaseAddon.
  ///
  /// In en, this message translates to:
  /// **'Purchase Addon'**
  String get purchaseAddon;

  /// No description provided for @purchaseDetails.
  ///
  /// In en, this message translates to:
  /// **'Purchase Details'**
  String get purchaseDetails;

  /// No description provided for @purchaseDue.
  ///
  /// In en, this message translates to:
  /// **'Purchase Due'**
  String get purchaseDue;

  /// No description provided for @purchaseEnabled.
  ///
  /// In en, this message translates to:
  /// **'Purchase Enabled'**
  String get purchaseEnabled;

  /// No description provided for @purchaseInformation.
  ///
  /// In en, this message translates to:
  /// **'Purchase Information'**
  String get purchaseInformation;

  /// No description provided for @purchaseInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Purchase Invoice Number'**
  String get purchaseInvoiceNumber;

  /// No description provided for @purchaseList.
  ///
  /// In en, this message translates to:
  /// **'Purchase List'**
  String get purchaseList;

  /// No description provided for @purchaseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Purchase not found'**
  String get purchaseNotFound;

  /// No description provided for @purchasePlanToAddAddon.
  ///
  /// In en, this message translates to:
  /// **'Please purchase the plan to add this addon'**
  String get purchasePlanToAddAddon;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePrice;

  /// No description provided for @purchaseReport.
  ///
  /// In en, this message translates to:
  /// **'Purchase Report'**
  String get purchaseReport;

  /// No description provided for @purchaseReturn.
  ///
  /// In en, this message translates to:
  /// **'Purchase Return'**
  String get purchaseReturn;

  /// No description provided for @purchaseTransactionSuccessfullyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Purchase Transaction Successfully Completed'**
  String get purchaseTransactionSuccessfullyCompleted;

  /// No description provided for @pyType.
  ///
  /// In en, this message translates to:
  /// **'PY. Type'**
  String get pyType;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Quantity Adjusted'**
  String get quantityAdjusted;

  /// No description provided for @quantityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Quantity Available'**
  String get quantityAvailable;

  /// No description provided for @quantityOrUnitPriceCannotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity or unit price cannot be zero'**
  String get quantityOrUnitPriceCannotBeZero;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote;

  /// No description provided for @quoteCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Quote created successfully'**
  String get quoteCreatedSuccessfully;

  /// No description provided for @quoteDate.
  ///
  /// In en, this message translates to:
  /// **'Quote Date'**
  String get quoteDate;

  /// No description provided for @quoteNo.
  ///
  /// In en, this message translates to:
  /// **'Quote No'**
  String get quoteNo;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @recall.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get recall;

  /// No description provided for @recallBill.
  ///
  /// In en, this message translates to:
  /// **'Recall Bill'**
  String get recallBill;

  /// No description provided for @receivedAmount.
  ///
  /// In en, this message translates to:
  /// **'Received Amount'**
  String get receivedAmount;

  /// No description provided for @receivedFrom.
  ///
  /// In en, this message translates to:
  /// **'Received From'**
  String get receivedFrom;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get referenceNumber;

  /// No description provided for @refNo.
  ///
  /// In en, this message translates to:
  /// **'Ref No'**
  String get refNo;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @remainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get remainingBalance;

  /// No description provided for @removeBranchAccess.
  ///
  /// In en, this message translates to:
  /// **'Remove branch access'**
  String get removeBranchAccess;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @reservationCode.
  ///
  /// In en, this message translates to:
  /// **'Reservation Code'**
  String get reservationCode;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordLinkSentSuccessfullyToYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Reset password link sent successfully to your email'**
  String get resetPasswordLinkSentSuccessfullyToYourEmail;

  /// No description provided for @retailPrice.
  ///
  /// In en, this message translates to:
  /// **'Retail Price'**
  String get retailPrice;

  /// No description provided for @retainsExistingItems.
  ///
  /// In en, this message translates to:
  /// **'Retains existing items'**
  String get retainsExistingItems;

  /// No description provided for @retainsTheItemsAndDoesNotImportTheDuplicatesInTheImportFile.
  ///
  /// In en, this message translates to:
  /// **'Retains the items and does not import the duplicates in the import file.'**
  String get retainsTheItemsAndDoesNotImportTheDuplicatesInTheImportFile;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @returnableItem.
  ///
  /// In en, this message translates to:
  /// **'Returnable Item'**
  String get returnableItem;

  /// No description provided for @returnAmount.
  ///
  /// In en, this message translates to:
  /// **'Return Amount'**
  String get returnAmount;

  /// No description provided for @returnDate.
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnDate;

  /// No description provided for @returnInvoice.
  ///
  /// In en, this message translates to:
  /// **'Return Invoice'**
  String get returnInvoice;

  /// No description provided for @returnReason.
  ///
  /// In en, this message translates to:
  /// **'Return Reason'**
  String get returnReason;

  /// No description provided for @revenueProducts.
  ///
  /// In en, this message translates to:
  /// **'Revenue: Products'**
  String get revenueProducts;

  /// No description provided for @revenueServices.
  ///
  /// In en, this message translates to:
  /// **'Revenue: Services'**
  String get revenueServices;

  /// No description provided for @revenueShipping.
  ///
  /// In en, this message translates to:
  /// **'Revenue: Shipping'**
  String get revenueShipping;

  /// No description provided for @reverseCharge.
  ///
  /// In en, this message translates to:
  /// **'Reverse charge'**
  String get reverseCharge;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @roleNameIsAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'Role name is already used'**
  String get roleNameIsAlreadyUsed;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @saleDetails.
  ///
  /// In en, this message translates to:
  /// **'Sale Details'**
  String get saleDetails;

  /// No description provided for @saleDue.
  ///
  /// In en, this message translates to:
  /// **'Sale Due'**
  String get saleDue;

  /// No description provided for @saleList.
  ///
  /// In en, this message translates to:
  /// **'Sale List'**
  String get saleList;

  /// No description provided for @saleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sale not found'**
  String get saleNotFound;

  /// No description provided for @salePersonDetails.
  ///
  /// In en, this message translates to:
  /// **'Sale person details'**
  String get salePersonDetails;

  /// No description provided for @salePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale Price'**
  String get salePrice;

  /// No description provided for @salePriceToolTip.
  ///
  /// In en, this message translates to:
  /// **'The rate at which you are going to sell this item'**
  String get salePriceToolTip;

  /// No description provided for @saleReturn.
  ///
  /// In en, this message translates to:
  /// **'Sale Return'**
  String get saleReturn;

  /// No description provided for @salesDue.
  ///
  /// In en, this message translates to:
  /// **'Sales Due'**
  String get salesDue;

  /// No description provided for @salesEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sales Enabled'**
  String get salesEnabled;

  /// No description provided for @salesInformation.
  ///
  /// In en, this message translates to:
  /// **'Sales Information'**
  String get salesInformation;

  /// No description provided for @salesPerson.
  ///
  /// In en, this message translates to:
  /// **'Salesperson'**
  String get salesPerson;

  /// No description provided for @salespersonDetails.
  ///
  /// In en, this message translates to:
  /// **'Salesperson Details'**
  String get salespersonDetails;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get salesReport;

  /// No description provided for @saleTransactionCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sale Transaction created successfully'**
  String get saleTransactionCreatedSuccessfully;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAndPublish.
  ///
  /// In en, this message translates to:
  /// **'Save and Publish'**
  String get saveAndPublish;

  /// No description provided for @saveNew.
  ///
  /// In en, this message translates to:
  /// **'Save & New'**
  String get saveNew;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchExpense.
  ///
  /// In en, this message translates to:
  /// **'Search Expense'**
  String get searchExpense;

  /// No description provided for @searchForAnItem.
  ///
  /// In en, this message translates to:
  /// **'Search for an item'**
  String get searchForAnItem;

  /// No description provided for @searchIncome.
  ///
  /// In en, this message translates to:
  /// **'Search Income'**
  String get searchIncome;

  /// No description provided for @secondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondary;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectAFileOrDragAndDropHere.
  ///
  /// In en, this message translates to:
  /// **'Select a file or drag and drop here'**
  String get selectAFileOrDragAndDropHere;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @selectedTablesAreNotEnoughForTheParty.
  ///
  /// In en, this message translates to:
  /// **'Selected Tables are not enough for the party'**
  String get selectedTablesAreNotEnoughForTheParty;

  /// No description provided for @selectItemToPrintBarcode.
  ///
  /// In en, this message translates to:
  /// **'Select Item to print barcode'**
  String get selectItemToPrintBarcode;

  /// No description provided for @selectItemType.
  ///
  /// In en, this message translates to:
  /// **'Select Item Type'**
  String get selectItemType;

  /// No description provided for @selectPartySize.
  ///
  /// In en, this message translates to:
  /// **'Select party size'**
  String get selectPartySize;

  /// No description provided for @selectPurchaseInvoice.
  ///
  /// In en, this message translates to:
  /// **'Select Purchase Invoice'**
  String get selectPurchaseInvoice;

  /// No description provided for @selectSaleInvoice.
  ///
  /// In en, this message translates to:
  /// **'Select Sale Invoice'**
  String get selectSaleInvoice;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumber;

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get serviceName;

  /// No description provided for @servicePrice.
  ///
  /// In en, this message translates to:
  /// **'Service Price'**
  String get servicePrice;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @serviceShipping.
  ///
  /// In en, this message translates to:
  /// **'Service / Shipping'**
  String get serviceShipping;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully'**
  String get settingsUpdatedSuccessfully;

  /// No description provided for @settle.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get settle;

  /// No description provided for @settlements.
  ///
  /// In en, this message translates to:
  /// **'Settlements'**
  String get settlements;

  /// No description provided for @setUpYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Set up your Account'**
  String get setUpYourAccount;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @shortName.
  ///
  /// In en, this message translates to:
  /// **'Short Name'**
  String get shortName;

  /// No description provided for @shouldBeSamePassword.
  ///
  /// In en, this message translates to:
  /// **'New password and confirm password should be same'**
  String get shouldBeSamePassword;

  /// No description provided for @showTables.
  ///
  /// In en, this message translates to:
  /// **'Show Tables'**
  String get showTables;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Get started by creating your account or\nsign in to manage your business\neffortlessly.'**
  String get signupTitle;

  /// No description provided for @simplePricingForYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Simple pricing for your business'**
  String get simplePricingForYourBusiness;

  /// No description provided for @skipDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Skip Duplicates'**
  String get skipDuplicates;

  /// No description provided for @slNo.
  ///
  /// In en, this message translates to:
  /// **'SL.No'**
  String get slNo;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @somethingWentWrongTryRefreshingThePageOrCheckingYourInternetConnectionWeLlSeeYouInAMoment.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try\nrefreshing the page or checking your\ninternet connection. We\'ll see you in a\nmoment!'**
  String
      get somethingWentWrongTryRefreshingThePageOrCheckingYourInternetConnectionWeLlSeeYouInAMoment;

  /// No description provided for @sorryThereAreNoResultsForThisSearchPleaseTryAnotherPhrase.
  ///
  /// In en, this message translates to:
  /// **'Sorry, there are no results for this search.\nPlease try another phrase'**
  String get sorryThereAreNoResultsForThisSearchPleaseTryAnotherPhrase;

  /// No description provided for @staffId.
  ///
  /// In en, this message translates to:
  /// **'Staff ID'**
  String get staffId;

  /// No description provided for @standardPriceAtWhichAProductIsOfferedToCustomersInARetailSetting.
  ///
  /// In en, this message translates to:
  /// **'Standard price at which a product is offered to customers in a retail setting.'**
  String get standardPriceAtWhichAProductIsOfferedToCustomersInARetailSetting;

  /// No description provided for @startDateMustBeBeforeEndDate.
  ///
  /// In en, this message translates to:
  /// **'Start date must be before end date'**
  String get startDateMustBeBeforeEndDate;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @stockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Stock Adjustment'**
  String get stockAdjustment;

  /// No description provided for @stockAlert.
  ///
  /// In en, this message translates to:
  /// **'Stock Alert'**
  String get stockAlert;

  /// No description provided for @stockAvailableForSaleAtTheBeginningOfTheAccountingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Stock available for sale at the beginning of the accounting period'**
  String get stockAvailableForSaleAtTheBeginningOfTheAccountingPeriod;

  /// No description provided for @stockReport.
  ///
  /// In en, this message translates to:
  /// **'Stock Report'**
  String get stockReport;

  /// No description provided for @stockValueOpening.
  ///
  /// In en, this message translates to:
  /// **'Stock value a business has at the beginning of the accounting period'**
  String get stockValueOpening;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @subscriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get subscriptionDetails;

  /// No description provided for @subscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plan'**
  String get subscriptionPlan;

  /// No description provided for @subscriptionPlans.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get subscriptionPlans;

  /// No description provided for @subServices.
  ///
  /// In en, this message translates to:
  /// **'Sub Services'**
  String get subServices;

  /// No description provided for @subTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get subTotal;

  /// No description provided for @successfully.
  ///
  /// In en, this message translates to:
  /// **'successfully'**
  String get successfully;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @supplierBalance.
  ///
  /// In en, this message translates to:
  /// **'Supplier Balance'**
  String get supplierBalance;

  /// No description provided for @supplierDue.
  ///
  /// In en, this message translates to:
  /// **'Supplier Due'**
  String get supplierDue;

  /// No description provided for @supplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get supplierName;

  /// No description provided for @supplierPhone.
  ///
  /// In en, this message translates to:
  /// **'Supplier Phone'**
  String get supplierPhone;

  /// No description provided for @supplierWallet.
  ///
  /// In en, this message translates to:
  /// **'Supplier Wallet'**
  String get supplierWallet;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @tax10.
  ///
  /// In en, this message translates to:
  /// **'Tax (10%)'**
  String get tax10;

  /// No description provided for @taxAmount.
  ///
  /// In en, this message translates to:
  /// **'Tax Amount'**
  String get taxAmount;

  /// No description provided for @taxName.
  ///
  /// In en, this message translates to:
  /// **'Tax Name'**
  String get taxName;

  /// No description provided for @taxpayerDetails.
  ///
  /// In en, this message translates to:
  /// **'Taxpayer Details'**
  String get taxpayerDetails;

  /// No description provided for @taxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate'**
  String get taxRate;

  /// No description provided for @taxRates.
  ///
  /// In en, this message translates to:
  /// **'Tax Rates'**
  String get taxRates;

  /// No description provided for @taxSettings.
  ///
  /// In en, this message translates to:
  /// **'Tax Settings'**
  String get taxSettings;

  /// No description provided for @taxType.
  ///
  /// In en, this message translates to:
  /// **'Tax Type'**
  String get taxType;

  /// No description provided for @teamSalesReport.
  ///
  /// In en, this message translates to:
  /// **'Team Sales Report'**
  String get teamSalesReport;

  /// No description provided for @tellMeWhatDoYouWant.
  ///
  /// In en, this message translates to:
  /// **'Tell me what do you want?'**
  String get tellMeWhatDoYouWant;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @textForm.
  ///
  /// In en, this message translates to:
  /// **'Text form'**
  String get textForm;

  /// No description provided for @thankYouVisitAgain.
  ///
  /// In en, this message translates to:
  /// **'Thank You Visit again !'**
  String get thankYouVisitAgain;

  /// No description provided for @theBestMatchToEachFieldOnTheSelectedFileHaveBeenAutoSelected.
  ///
  /// In en, this message translates to:
  /// **'The best match to each field on the selected file have been auto-selected.'**
  String get theBestMatchToEachFieldOnTheSelectedFileHaveBeenAutoSelected;

  /// No description provided for @theFollowingFieldsInYourImportFileHaveNotBeenMappedToAnyFieldTheDataInTheseFieldsWillBeIgnoredDuringTheImport.
  ///
  /// In en, this message translates to:
  /// **'The following fields in your import file have not been mapped to any field. The data in these fields will be ignored during the import.'**
  String
      get theFollowingFieldsInYourImportFileHaveNotBeenMappedToAnyFieldTheDataInTheseFieldsWillBeIgnoredDuringTheImport;

  /// No description provided for @theRateAtWhichThisItemIsPurchased.
  ///
  /// In en, this message translates to:
  /// **'The rate at which this item is purchased.'**
  String get theRateAtWhichThisItemIsPurchased;

  /// No description provided for @thisEmailIsAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get thisEmailIsAlreadyRegistered;

  /// No description provided for @thisEmailWillBeUsedAsTheOfficialEmailOnInvoices.
  ///
  /// In en, this message translates to:
  /// **'this email will be used as the \"official email\" on invoices.'**
  String get thisEmailWillBeUsedAsTheOfficialEmailOnInvoices;

  /// No description provided for @thisNumberWillBeUsedAsTheOfficialNumberOnInvoices.
  ///
  /// In en, this message translates to:
  /// **'this number will be used as the \"official number\" on invoices'**
  String get thisNumberWillBeUsedAsTheOfficialNumberOnInvoices;

  /// No description provided for @thumbnail.
  ///
  /// In en, this message translates to:
  /// **'Thumbnail'**
  String get thumbnail;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @timeSlotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Time Slot Available'**
  String get timeSlotAvailable;

  /// No description provided for @timeSlotAvailables.
  ///
  /// In en, this message translates to:
  /// **'Time Slot Availables'**
  String get timeSlotAvailables;

  /// No description provided for @timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time Zone'**
  String get timeZone;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// No description provided for @topSellingProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Selling Products'**
  String get topSellingProducts;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @totalAmountCurrencyPurchasepagedataGrandtotal.
  ///
  /// In en, this message translates to:
  /// **'Total Amount {currency} {purchasepagedataGrandtotal}'**
  String totalAmountCurrencyPurchasepagedataGrandtotal(
      String currency, String purchasepagedataGrandtotal);

  /// No description provided for @totalBill.
  ///
  /// In en, this message translates to:
  /// **'Total Bill'**
  String get totalBill;

  /// No description provided for @totalDiscount.
  ///
  /// In en, this message translates to:
  /// **'Total Discount %'**
  String get totalDiscount;

  /// No description provided for @totalDiscountAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Discount Amount'**
  String get totalDiscountAmount;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @totalIncomeOther.
  ///
  /// In en, this message translates to:
  /// **'Total Income (Other)'**
  String get totalIncomeOther;

  /// No description provided for @totalItem.
  ///
  /// In en, this message translates to:
  /// **'Total Item'**
  String get totalItem;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @totalItemsSold.
  ///
  /// In en, this message translates to:
  /// **'Total Items Sold'**
  String get totalItemsSold;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @totalPaymentsIn.
  ///
  /// In en, this message translates to:
  /// **'Total Payments In'**
  String get totalPaymentsIn;

  /// No description provided for @totalPaymentsOut.
  ///
  /// In en, this message translates to:
  /// **'Total Payments Out'**
  String get totalPaymentsOut;

  /// No description provided for @totalPurchase.
  ///
  /// In en, this message translates to:
  /// **'Total Purchase'**
  String get totalPurchase;

  /// No description provided for @totalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get totalPurchases;

  /// No description provided for @totalRevenueGenerated.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue Generated'**
  String get totalRevenueGenerated;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @totalSalesRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Sales (Revenue)'**
  String get totalSalesRevenue;

  /// No description provided for @totalStockValue.
  ///
  /// In en, this message translates to:
  /// **'Total Stock Value'**
  String get totalStockValue;

  /// No description provided for @trackInventoryForThisItem.
  ///
  /// In en, this message translates to:
  /// **'Track Inventory for this item'**
  String get trackInventoryForThisItem;

  /// No description provided for @trialPeriod.
  ///
  /// In en, this message translates to:
  /// **'Trial Period'**
  String get trialPeriod;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @typeAReply.
  ///
  /// In en, this message translates to:
  /// **'Type a reply...'**
  String get typeAReply;

  /// No description provided for @unableToDeleteThisCustomer.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete this customer'**
  String get unableToDeleteThisCustomer;

  /// No description provided for @unableToDeleteThisCustomerThereAreTransactionsWithThisCustomerPleaseSettleOrWriteOffTheBalanceFirst.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete this customer, there are transactions with this customer. Please settle or write off the balance first.'**
  String
      get unableToDeleteThisCustomerThereAreTransactionsWithThisCustomerPleaseSettleOrWriteOffTheBalanceFirst;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unitAdded.
  ///
  /// In en, this message translates to:
  /// **'Unit Added Successfully'**
  String get unitAdded;

  /// No description provided for @unitDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Unit Deleted Successfully'**
  String get unitDeletedSuccessfully;

  /// No description provided for @unitName.
  ///
  /// In en, this message translates to:
  /// **'Unit Name'**
  String get unitName;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @unitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Unit Updated Successfully'**
  String get unitUpdated;

  /// No description provided for @unmappedFields.
  ///
  /// In en, this message translates to:
  /// **'Unmapped Fields -'**
  String get unmappedFields;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @updatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated On'**
  String get updatedOn;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated Successfully'**
  String get updatedSuccessfully;

  /// No description provided for @updatePayment.
  ///
  /// In en, this message translates to:
  /// **'Update Payment'**
  String get updatePayment;

  /// No description provided for @updatesExistingItems.
  ///
  /// In en, this message translates to:
  /// **'Updates existing items'**
  String get updatesExistingItems;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @uploadItemImage.
  ///
  /// In en, this message translates to:
  /// **'Upload item image'**
  String get uploadItemImage;

  /// No description provided for @uploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload Logo'**
  String get uploadLogo;

  /// No description provided for @userAccessRevokedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User Access Revoked Successfully'**
  String get userAccessRevokedSuccessfully;

  /// No description provided for @userChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User changed successfully'**
  String get userChangedSuccessfully;

  /// No description provided for @userChangingFailed.
  ///
  /// In en, this message translates to:
  /// **'User changing failed'**
  String get userChangingFailed;

  /// No description provided for @userCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User Created Successfully'**
  String get userCreatedSuccessfully;

  /// No description provided for @userDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get userDeletedSuccessfully;

  /// No description provided for @userDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'User does not exist'**
  String get userDoesNotExist;

  /// No description provided for @userList.
  ///
  /// In en, this message translates to:
  /// **'User List'**
  String get userList;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @userRole.
  ///
  /// In en, this message translates to:
  /// **'User Role'**
  String get userRole;

  /// No description provided for @userRoleName.
  ///
  /// In en, this message translates to:
  /// **'User Role Name'**
  String get userRoleName;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @useWallet.
  ///
  /// In en, this message translates to:
  /// **'Use Wallet'**
  String get useWallet;

  /// No description provided for @vatGst.
  ///
  /// In en, this message translates to:
  /// **'VAT/GST'**
  String get vatGst;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @viewAllStocks.
  ///
  /// In en, this message translates to:
  /// **'View All Stocks'**
  String get viewAllStocks;

  /// No description provided for @viewBy.
  ///
  /// In en, this message translates to:
  /// **'View by'**
  String get viewBy;

  /// No description provided for @viewReport.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get viewReport;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-In Customer'**
  String get walkInCustomer;

  /// No description provided for @walkInCustomerDueAmount.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer should not have due amount'**
  String get walkInCustomerDueAmount;

  /// No description provided for @walkinCustomerIsNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Walkin Customer is not allowed'**
  String get walkinCustomerIsNotAllowed;

  /// No description provided for @walkInCustomerIsNotAllowedInThisBranch.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer is not allowed in this branch.'**
  String get walkInCustomerIsNotAllowedInThisBranch;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @welcomeBackGladToSeeYouAgain.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!\nGlad to see you, Again!'**
  String get welcomeBackGladToSeeYouAgain;

  /// No description provided for @welcomeToDuxbe.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Duxbe!'**
  String get welcomeToDuxbe;

  /// No description provided for @welcomeToOrgPrefix.
  ///
  /// In en, this message translates to:
  /// **'Welcome to '**
  String get welcomeToOrgPrefix;

  /// No description provided for @weWillSendPasswordResetLinkToYourRegisteredEmailId.
  ///
  /// In en, this message translates to:
  /// **'We will send password reset link to your registered email ID'**
  String get weWillSendPasswordResetLinkToYourRegisteredEmailId;

  /// No description provided for @whatsappCustom.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp Custom'**
  String get whatsappCustom;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp Number'**
  String get whatsappNumber;

  /// No description provided for @whatsappNumberId.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp Number ID'**
  String get whatsappNumberId;

  /// No description provided for @whatsappSettings.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp Settings'**
  String get whatsappSettings;

  /// No description provided for @whatsappToken.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp Token'**
  String get whatsappToken;

  /// No description provided for @writeReserveationNotesHere.
  ///
  /// In en, this message translates to:
  /// **'Write Reserveation Notes Here'**
  String get writeReserveationNotesHere;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @youCanUpdateThePrice.
  ///
  /// In en, this message translates to:
  /// **'You can update the price and quantity of items in cart'**
  String get youCanUpdateThePrice;

  /// No description provided for @youHaveReachedTheMaximumNumberOfBranches.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum number of branches'**
  String get youHaveReachedTheMaximumNumberOfBranches;

  /// No description provided for @youHaveReachedTheMaximumNumberOfEmployees.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum number of employees'**
  String get youHaveReachedTheMaximumNumberOfEmployees;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.\nStart adding items from the list'**
  String get yourCartIsEmpty;

  /// No description provided for @youReOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get youReOffline;

  /// No description provided for @yourExampleCom.
  ///
  /// In en, this message translates to:
  /// **'your@example.com'**
  String get yourExampleCom;

  /// No description provided for @yourSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'Your Selected file:'**
  String get yourSelectedFile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
