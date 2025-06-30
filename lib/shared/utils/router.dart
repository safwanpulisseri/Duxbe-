import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/features/home/home.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exposes a [GoRouter] that uses a [Listenable] to refresh its internal state.
///
/// With Riverpod, we can't register a dependency via an Inherited Widget,
/// thus making this implementation the "leanest" possible
///
/// To sync our app state with this our router, we simply update our listenable
/// via `ref.listen`,
/// and pass it to GoRouter's `refreshListenable`.
/// In this example, this will trigger redirects on any authentication change.
///
/// Obviously, more logic could be implemented here, but again, this is meant
/// to be a simple example.
/// You can always build more listenables and even merge more than one
/// into a more complex `ChangeNotifier`,
/// but that's up to your case and out of this scope.

class AppRouter {
  AppRouter(this.ref)
      : _supabaseClient = ref.watch(supabaseProvider),
        _firebaseObserver = ref.watch(analyticsObserverProvider) {
    ref
      ..onDispose(
        () {
          authState.dispose();
          mobileRouter.dispose();
          desktopRouter.dispose();
        },
      )
      ..listen(
        authStateProvider.select(
          (value) => value.asData,
        ),
        (_, next) {
          authState.value = next;
        },
      );
  }
  final AppRouterRef ref;
  final SupabaseClient _supabaseClient;
  final FirebaseAnalyticsObserver _firebaseObserver;
  final authState = ValueNotifier<AsyncValue<AuthState>?>(const AsyncLoading());

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
  static GlobalKey<NavigatorState> get shellKey => _shellKey;

  static BuildContext get rootContext => _rootNavigatorKey.currentContext!;
  static BuildContext get shellContext => _shellKey.currentContext!;

  static AppLocalizations get l10n => rootContext.l10n;
  // Authentication & Onboarding Routes
  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'sign_up';
  static const String businessRegister = 'business_register';
  static const String forgotPassword = 'forgot_password';
  static const String enterOTP = 'enter_otp';
  static const String newPassword = 'new_password';
  static const String changePassword = 'change_password';
  static const String setNewUser = 'set_new_user';

  // Core Navigation Routes
  static const String home = 'home';
  static const String orderHome = 'order_home';
  static const String dashboard = 'dashboard';
  static const String more = 'more';
  static const String aiChat = 'ai_chat';

  // Legal Routes
  static const String termsAndConditions = 'terms_and_conditions';
  static const String privacyPolicy = 'privacy_policy';

  // User Management Routes
  static const String profile = 'profile';
  static const String userSettings = 'user_settings';
  static const String users = 'users';
  static const String userList = 'user_list';
  static const String userRole = 'user_role';
  static const String createUserRole = 'create_user_role';
  static const String userRoleDetails = 'user_role_details';

  // Inventory Management Routes
  static const String inventory = 'inventory';
  static const String itemList = 'item_list';
  static const String createItem = 'create_item';
  static const String importItem = 'import_item';
  static const String itemDetails = 'item_details';
  static const String itemView = 'item_view';
  static const String richText = 'rich_text';
  static const String units = 'units';
  static const String brands = 'brands';
  static const String category = 'category';
  static const String printBarcode = 'print_barcode';
  static const String printBarcodeList = 'print_barcode_list';

  // Stock Management Routes
  static const String manageStock = 'manage_stock';
  static const String singleStockAdjust = 'single_stock_adjust';
  static const String multiStockAdjust = 'multi_stock_adjust';
  static const String stockAdjusments = 'stock_adjustment';
  static const String stockAdjusmentView = 'stock_adjustment_view';

  // Purchase Management Routes
  static const String purchase = 'purchase';
  static const String purchaseMore = 'purchase_more';
  static const String purchasing = 'purchasing';
  static const String purchaseList = 'purchase_list';
  static const String purchaseDetails = 'purchase_details';
  static const String purchasePayment = 'purchase_payment';
  static const String purchasePaymentKeypad = 'purchase_payment_keypad';
  static const String purchaseSuccess = 'purchase_success';
  static const String purchaseReturn = 'purchase_return';
  static const String createPurchaseReturn = 'create_purchase_return';
  static const String purchaseReturnDetails = 'purchase_return_details';

  // Sales Management Routes
  static const String sales = 'sales';
  static const String pos = 'pos';
  static const String saleList = 'sale_list';
  static const String saleDetails = 'sale_details';
  static const String salePayment = 'sale_payment';
  static const String salePaymentKeypad = 'sale_payment_keypad';
  static const String saleSuccess = 'sale_success';
  static const String salesReturn = 'sale_return';
  static const String createSaleReturn = 'create_sale_return';
  static const String orderList = 'order_list';
  static const String orderDetails = 'order_details';
  static const String saleReturnDetails = 'sale_return_details';

  // Reservation Management Routes
  static const String chooseReservationTable = 'choose_reservation_table';
  static const String tableManagement = 'table';

  // Customer Management Routes
  static const String customer = 'customer';
  static const String createCustomer = 'create_customer';
  static const String customerDetails = 'customer_details';

  // Supplier Management Routes
  static const String supplier = 'supplier';
  static const String supplierDetails = 'supplier_details';
  static const String createSupplier = 'create_supplier';

  // Financial Management Routes
  static const String accounting = 'accounting';
  static const String expense = 'expense';
  static const String createExpense = 'create_expense';
  static const String expenseDetails = 'expense_details';
  static const String expenseCategory = 'expense_category';
  static const String income = 'income';
  static const String incomeDetails = 'income_details';
  static const String createIncome = 'create_income';
  static const String incomeCategory = 'income_category';
  static const String ledger = 'ledger';
  static const String chartOfAccounts = 'chart_of_accounts';
  static const String profitAndLoss = 'profit_and_loss';

  // Branch Management Routes
  static const String branch = 'branch';
  static const String createBranch = 'create_branch';
  static const String branchDetails = 'branch_details';
  static const String businessSettings = 'business_settings';
  static const String taxSettings = 'tax_settings';
  static const String printSettings = 'print_settings';
  static const String generalSettings = 'general_settings';
  static const String notificationSettings = 'notification_settings';
  static const String integrationSettings = 'integration_settings';

  // Reporting & Settings Routes
  static const String reports = 'reports';
  static const String dailyTransactions = 'daily_transactions';
  static const String salesReport = 'sales_report';
  static const String purchaseReport = 'purchase_report';
  static const String dueReport = 'due_report';
  static const String currentStockReport = 'current_stock_report';
  static const String teamSalesReport = 'team_sales_report';
  static const String settings = 'settings';

  // Subscription Management Routes
  static const String subscription = 'subscription';
  static const String subscriptionPlans = 'subscription_plans';
  static const String subscriptionDetails = 'subscription_details';
  static const String subscriptionHistory = 'subscription_history';
  static const String subscriptionPayment = 'subscription_payment';

  // Invoice Routes
  static const String invoices = 'invoices';
  static const String invoice = 'invoice';
  static const String quote = 'quote';
  static const String paymentReceived = 'payment_received';
  static const String creditNotes = 'credit_notes';
  static const String createQuote = 'add_new_quote';
  static const String editQuote = 'edit_quote';
  static const String editInvoice = 'edit_invoice';
  static const String createInvoice = 'add_new_invoice';
  static const String createCreditNote = 'add_new_credit_note';
  static const String quoteDetails = 'quote_details';
  static const String invoiceDetails = 'invoice_details';
  static const String creditNoteDetails = 'credit_note_details';
  static const String paymentRefund = 'payment_refund';
  static const String creditNoteRefund = 'credit_note_refund';
  static const String createPayment = 'add_new_payment';
  static const String createPaymentFromInvoice = 'create_payment_from_invoice';
  static const String editPayment = 'edit_payment';
  static const String editCreditNote = 'edit_creditNote';

  late final GoRouter mobileRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [_firebaseObserver],
    routes: [
      GoRoute(
        name: home,
        path: '/',
        redirect: (context, state) => state.fullPath == '/' ? '/$dashboard' : state.uri.toString(),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) =>
                HomeNavigationBar(navigationShell: navigationShell),
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    name: dashboard,
                    path: dashboard,
                    builder: (context, state) => const DashboardScreen(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: aiChat,
                        path: aiChat,
                        builder: (context, state) => const AiChatScreenMobile(),
                      ),
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: subscriptionPlans,
                        path: subscriptionPlans,
                        builder: (context, state) => const SubscriptionPlansScreen(),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    name: orderHome,
                    path: orderHome,
                    builder: (context, state) => const OrderListScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    name: pos,
                    path: pos,
                    builder: (context, state) => const SalesScreen(),
                    routes: [
                      GoRoute(
                        name: salePayment,
                        path: salePayment,
                        builder: (context, state) {
                          return const SalesPaymentScreen();
                        },
                      ),
                      GoRoute(
                        name: salePaymentKeypad,
                        path: salePaymentKeypad,
                        builder: (context, state) => const SalesKeypadScreen(),
                      ),
                      GoRoute(
                        name: saleSuccess,
                        path: ':id',
                        builder: (context, state) {
                          return const SalesSuccessScreen();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    name: more,
                    path: more,
                    builder: (context, state) => const MoreScreen(),
                    routes: [
                      GoRoute(
                        name: termsAndConditions,
                        path: termsAndConditions,
                        builder: (context, state) => const TermsAndConditionsScreen(),
                      ),
                      GoRoute(
                        name: privacyPolicy,
                        path: privacyPolicy,
                        builder: (context, state) => const PrivacyPolicyScreen(),
                      ),
                      GoRoute(
                        name: purchaseMore,
                        path: purchaseMore,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => const PurchaseScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            name: saleList,
            path: saleList,
            builder: (context, state) => const SaleListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: saleDetails,
                builder: (context, state) {
                  final saleId = state.pathParameters['id'];
                  return SaleDetailsScreen(saleId: saleId);
                },
              ),
            ],
          ),
          GoRoute(
            name: orderList,
            path: orderList,
            builder: (context, state) => const OrderListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: orderDetails,
                builder: (context, state) {
                  final saleId = state.pathParameters['id'];
                  return OrderDetailsScreen(saleId: saleId);
                },
              ),
            ],
          ),
          GoRoute(
            name: tableManagement,
            path: tableManagement,
            builder: (context, state) => const TablesScreen(),
          ),
          GoRoute(
            name: purchase,
            path: purchase,
            builder: (context, state) => const PurchaseScreen(),
            routes: [
              GoRoute(
                name: purchasePayment,
                path: purchasePayment,
                builder: (context, state) => const PurchasePaymentScreen(),
              ),
              GoRoute(
                name: purchasePaymentKeypad,
                path: purchasePaymentKeypad,
                builder: (context, state) => const PurchaseKeypadScreen(),
              ),
              GoRoute(
                name: purchaseSuccess,
                path: ':id',
                builder: (context, state) => const PurchaseSuccessScreen(),
              ),
            ],
          ),
          GoRoute(
            name: purchaseList,
            path: purchaseList,
            builder: (context, state) => const PurchaseListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: purchaseDetails,
                builder: (context, state) {
                  final purchaseId = state.pathParameters['id'];
                  return PurchaseDetailsScreen(purchaseId: purchaseId);
                },
              ),
            ],
          ),
          GoRoute(
            name: itemList,
            path: itemList,
            builder: (context, state) => const ItemListScreen(),
            routes: [
              GoRoute(
                path: importItem,
                name: importItem,
                builder: (context, state) => const ItemImportScreen(),
              ),
              GoRoute(
                name: richText,
                path: richText,
                builder: (context, state) {
                  final richText = state.extra as String?;
                  return RichTextScreen(richText: richText);
                },
              ),
              GoRoute(
                name: createItem,
                path: createItem,
                builder: (context, state) => const ItemDetailsScreen(),
              ),
              GoRoute(
                name: itemDetails,
                path: '$itemDetails/:id',
                builder: (context, state) {
                  final itemId = state.pathParameters['id'];
                  return ItemDetailsScreen(itemId: itemId);
                },
              ),
              GoRoute(
                name: itemView,
                path: '$itemView/:id',
                builder: (context, state) {
                  final itemId = state.pathParameters['id'];
                  return ItemViewScreen(itemId: itemId);
                },
              ),
            ],
          ),
          GoRoute(
            name: category,
            path: category,
            builder: (context, state) => const ItemCategoryListScreen(),
          ),
          GoRoute(
            name: units,
            path: units,
            builder: (context, state) => const UnitListScreen(),
          ),
          GoRoute(
            name: brands,
            path: brands,
            builder: (context, state) => const BrandListScreen(),
          ),
          GoRoute(
            name: manageStock,
            path: manageStock,
            builder: (context, state) => const ManageStockScreen(),
            routes: [
              GoRoute(
                name: singleStockAdjust,
                path: '$singleStockAdjust/:id',
                builder: (context, state) {
                  final itemId = state.pathParameters['id'];
                  return SingleStockAdjustScreen(itemId: itemId);
                },
              ),
            ],
          ),
          GoRoute(
            name: stockAdjusments,
            path: stockAdjusments,
            builder: (context, state) => const StockAdjustmentsScreen(),
            routes: [
              GoRoute(
                name: multiStockAdjust,
                path: multiStockAdjust,
                builder: (context, state) => const MultiStockAdjustScreen(),
              ),
              GoRoute(
                path: ':id',
                name: stockAdjusmentView,
                builder: (context, state) {
                  final adjustmentId = state.pathParameters['id'];
                  return StockAdjustmentViewScreen(adjustmentId: adjustmentId);
                },
              ),
            ],
          ),
          GoRoute(
            name: printBarcodeList,
            path: printBarcodeList,
            builder: (context, state) => const PrintBarcodeList(),
            routes: [
              GoRoute(
                name: printBarcode,
                path: printBarcode,
                builder: (context, state) {
                  final itemId = state.uri.queryParameters['id'];
                  return PrintBarcodeScreen(itemId: itemId);
                },
              ),
            ],
          ),
          GoRoute(
            name: income,
            path: income,
            builder: (context, state) => const IncomeScreen(),
            routes: [
              GoRoute(
                name: incomeCategory,
                path: incomeCategory,
                builder: (context, state) => const IncomeCategoryScreen(),
              ),
              GoRoute(
                path: createIncome,
                name: createIncome,
                builder: (context, state) => const IncomeDetailsScreen(),
              ),
              GoRoute(
                path: ':id',
                name: incomeDetails,
                builder: (context, state) {
                  final incomeId = state.pathParameters['id'];
                  return IncomeDetailsScreen(incomeId: incomeId);
                },
              ),
            ],
          ),
          GoRoute(
            name: expense,
            path: expense,
            builder: (context, state) => const ExpenseScreen(),
            routes: [
              GoRoute(
                name: expenseCategory,
                path: expenseCategory,
                builder: (context, state) => const ExpenseCategoryScreen(),
              ),
              GoRoute(
                path: createExpense,
                name: createExpense,
                builder: (context, state) => const ExpenseDetailsScreen(),
              ),
              GoRoute(
                path: ':id',
                name: expenseDetails,
                builder: (context, state) {
                  final expenseId = state.pathParameters['id'];
                  return ExpenseDetailsScreen(expenseId: expenseId);
                },
              ),
            ],
          ),
          GoRoute(
            name: profitAndLoss,
            path: profitAndLoss,
            builder: (context, state) => const ProfitAndLossScreen(),
          ),
          GoRoute(
            name: branch,
            path: branch,
            builder: (context, state) => const BranchScreen(),
            routes: [
              GoRoute(
                name: createBranch,
                path: createBranch,
                builder: (context, state) => const AddBranchScreenMobile(),
              ),
              GoRoute(
                path: ':business_id/$businessSettings',
                name: businessSettings,
                builder: (context, state) => BusinessSettingsScreen(
                  businessId: state.pathParameters['business_id'],
                ),
              ),
              GoRoute(
                path: ':business_id/$taxSettings',
                name: taxSettings,
                builder: (context, state) => TaxSettingsScreen(
                  businessId: state.pathParameters['business_id'],
                ),
              ),
              GoRoute(
                path: ':business_id/$printSettings',
                name: printSettings,
                builder: (context, state) => PrintSettingsScreen(
                  businessId: state.pathParameters['business_id'],
                ),
              ),
              GoRoute(
                path: ':business_id/$generalSettings',
                name: generalSettings,
                builder: (context, state) => GeneralSettingsScreen(
                  businessId: state.pathParameters['business_id'],
                ),
              ),
              GoRoute(
                path: ':business_id/$notificationSettings',
                name: notificationSettings,
                builder: (context, state) => const Scaffold(),
              ),
              GoRoute(
                path: ':business_id/$integrationSettings',
                name: integrationSettings,
                builder: (context, state) => WhatsappSettingsScreen(
                  businessId: state.pathParameters['business_id'],
                ),
              ),
              GoRoute(
                name: branchDetails,
                path: ':id',
                builder: (context, state) {
                  final branchId = state.pathParameters['id'];
                  return BranchDetailsScreen(businessId: branchId);
                },
              ),
            ],
          ),
          GoRoute(
            name: settings,
            path: settings,
            builder: (context, state) {
              final branchId = ref.read(businessNotifierProvider)!.businessId;

              return BranchDetailsScreen(businessId: branchId);
            },
          ),
          GoRoute(
            name: customer,
            path: customer,
            builder: (context, state) => const CustomerListScreen(),
            routes: [
              GoRoute(
                path: createCustomer,
                name: createCustomer,
                builder: (context, state) => const CustomerDetailsScreen(),
              ),
              GoRoute(
                path: ':id',
                name: customerDetails,
                builder: (context, state) {
                  final customerId = state.pathParameters['id'];
                  return CustomerDetailsScreen(customerId: customerId);
                },
              ),
            ],
          ),
          GoRoute(
            name: supplier,
            path: supplier,
            builder: (context, state) => const SupplierListScreen(),
            routes: [
              GoRoute(
                path: createSupplier,
                name: createSupplier,
                builder: (context, state) => const SupplierDetailsScreen(),
              ),
              GoRoute(
                path: ':id',
                name: supplierDetails,
                builder: (context, state) {
                  final supplierId = state.pathParameters['id'];
                  return SupplierDetailsScreen(supplierId: supplierId);
                },
              ),
            ],
          ),
          GoRoute(
            name: users,
            path: users,
            redirect: (context, state) => '/$users/$userList',
            routes: [
              GoRoute(
                name: userList,
                path: userList,
                builder: (context, state) => const EmployeeListScreen(),
              ),
              GoRoute(
                name: userRole,
                path: userRole,
                builder: (context, state) => const EmployeeRoleListScreen(),
                routes: [
                  GoRoute(
                    path: createUserRole,
                    name: createUserRole,
                    builder: (context, state) => const EmployeeRoleDetailsScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: userRoleDetails,
                    builder: (context, state) {
                      final employeeRoleId = state.pathParameters['id'];
                      return EmployeeRoleDetailsScreen(
                        employeeRoleId: employeeRoleId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: userSettings,
            name: userSettings,
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: profile,
                name: profile,
                builder: (context, state) => const PersonalDetails(),
              ),
              GoRoute(
                path: changePassword,
                name: changePassword,
                builder: (context, state) => const PasswordDetails(),
              ),
            ],
          ),
          GoRoute(
            path: reports,
            name: reports,
            builder: (context, state) => const ReportsScreen(),
            routes: [
              GoRoute(
                path: dailyTransactions,
                name: dailyTransactions,
                builder: (context, state) => const DailyTransactionReportScreen(),
              ),
              GoRoute(
                path: salesReport,
                name: salesReport,
                builder: (context, state) => const SalesReportScreen(),
              ),
              GoRoute(
                path: purchaseReport,
                name: purchaseReport,
                builder: (context, state) => const PurchaseReportScreen(),
              ),
              GoRoute(
                path: dueReport,
                name: dueReport,
                builder: (context, state) => const DueReportScreen(),
              ),
              GoRoute(
                path: currentStockReport,
                name: currentStockReport,
                builder: (context, state) => const StockReportScreen(),
              ),
              GoRoute(
                path: teamSalesReport,
                name: teamSalesReport,
                builder: (context, state) => const EmployeeSalesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/$splash',
        name: splash,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      GoRoute(
        path: '/$login',
        name: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: signup,
        path: '/$signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        name: businessRegister,
        path: '/$businessRegister',
        builder: (context, state) {
          final formValues = state.extra! as Map<String, dynamic>;
          return BusinessRegisterScreen(formValues: formValues);
        },
      ),
      GoRoute(
        name: forgotPassword,
        path: '/$forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: enterOTP,
        path: '/$enterOTP',
        builder: (context, state) => const EnterOtpScreen(),
      ),
      GoRoute(
        name: newPassword,
        path: '/$newPassword',
        builder: (context, state) => const NewPasswordScreen(),
      ),
      GoRoute(
        name: setNewUser,
        path: '/$setNewUser',
        builder: (context, state) {
          final refreshToken = state.uri.queryParameters['refresh_token'];
          final orgId = state.uri.queryParameters['org_id'];
          final type = state.uri.queryParameters['type'];
          final accessToken = state.uri.queryParameters['access_token'];
          return NewPasswordScreen(
            refreshToken: refreshToken,
            orgId: orgId,
            type: type,
            accessToken: accessToken,
          );
        },
      ),
    ],
    refreshListenable: Listenable.merge([authState]),
    redirect: (context, state) {
      const loginPath = '/$login';
      const homePath = '/';
      const splashPath = '/$splash';

      /// Preserve extra data during redirects
      final extra = state.extra;

      /// Auth reirection flow
      if (authState.value == null) {
        return null;
      }
      if (authState.value!.unwrapPrevious().hasError) {
        // Return Login Route
        return loginPath;
      }
      if (authState.value!.isLoading || !authState.value!.hasValue) {
        // Return Splash Route
        return splashPath;
      }

      final isAuth = !(authState.value!.value?.session?.isExpired ?? true);

      final isSplash = state.topRoute?.name == splash;
      final isLoggingIn = state.topRoute?.name == login;
      final isRegisterPage = state.topRoute?.name == businessRegister;
      final isSignUpPage = state.topRoute?.name == signup;
      final isForgotPassword = state.topRoute?.name == forgotPassword;
      final isEnterOTP = state.topRoute?.name == enterOTP;
      final isNewPassword = state.topRoute?.name == newPassword;
      final isSetNewUser = state.topRoute?.name == setNewUser;
      // if (isSplash) {
      //   // Use context.go to preserve extra data
      //   if (isAuth) {
      //     context.go(homePath, extra: extra);
      //     return null;
      //   }
      //   return loginPath;
      // }

      // if (isLoggingIn || isRegisterPage || isSignUpPage || isForgotPassword || isEnterOTP || isNewPassword) {
      //   if (isAuth) {
      //     context.go(homePath, extra: extra);
      //     return null;
      //   }
      //   return null;
      // }

      // return isAuth ? null : splashPath;
      if (isSplash) return isAuth ? homePath : loginPath;
      if (isLoggingIn ||
          isRegisterPage ||
          isSignUpPage ||
          isForgotPassword ||
          isEnterOTP ||
          isNewPassword ||
          isSetNewUser) {
        return isAuth ? homePath : null;
      }

      return isAuth ? null : splashPath;
    },
  );

  late final GoRouter desktopRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [_firebaseObserver],
    debugLogDiagnostics: true,
    initialLocation: _supabaseClient.auth.currentSession?.isExpired ?? false ? '/$login' : '/',
    routes: [
      GoRoute(
        name: home,
        path: '/',
        redirect: (context, state) => state.fullPath == '/' ? '/$dashboard' : state.uri.toString(),
        routes: [
          ShellRoute(
            navigatorKey: _shellKey,
            builder: (context, state, child) {
              return HomeScreen(child: child);
            },
            routes: [
              GoRoute(
                path: dashboard,
                name: dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                name: inventory,
                path: inventory,
                redirect: (context, state) => '/$inventory/$units',
                routes: [
                  GoRoute(
                    name: printBarcode,
                    path: printBarcode,
                    builder: (context, state) {
                      final itemId = state.uri.queryParameters['id'];
                      return PrintBarcodeScreen(itemId: itemId);
                    },
                  ),
                  GoRoute(
                    name: units,
                    path: units,
                    builder: (context, state) => const UnitListScreen(),
                  ),
                  GoRoute(
                    name: brands,
                    path: brands,
                    builder: (context, state) => const BrandListScreen(),
                  ),
                  GoRoute(
                    name: category,
                    path: category,
                    builder: (context, state) => const ItemCategoryListScreen(),
                  ),
                  GoRoute(
                    name: manageStock,
                    path: manageStock,
                    builder: (context, state) => const ManageStockScreen(),
                    routes: [
                      GoRoute(
                        name: singleStockAdjust,
                        path: '$singleStockAdjust/:id',
                        builder: (context, state) {
                          final itemId = state.pathParameters['id'];
                          return SingleStockAdjustScreen(itemId: itemId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: stockAdjusments,
                    path: stockAdjusments,
                    builder: (context, state) => const StockAdjustmentsScreen(),
                    routes: [
                      GoRoute(
                        name: multiStockAdjust,
                        path: multiStockAdjust,
                        builder: (context, state) => const MultiStockAdjustScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    name: itemList,
                    path: itemList,
                    builder: (context, state) => const ItemListScreen(),
                    routes: [
                      GoRoute(
                        path: createItem,
                        name: createItem,
                        builder: (context, state) => const ItemDetailsScreen(),
                      ),
                      GoRoute(
                        path: importItem,
                        name: importItem,
                        builder: (context, state) => const ItemImportScreen(),
                      ),
                      GoRoute(
                        name: itemDetails,
                        path: '$itemDetails/:id',
                        builder: (context, state) {
                          final itemId = state.pathParameters['id'];
                          return ItemDetailsScreen(itemId: itemId);
                        },
                      ),
                      GoRoute(
                        name: itemView,
                        path: '$itemView/:id',
                        builder: (context, state) {
                          final itemId = state.pathParameters['id'];
                          return ItemViewScreen(itemId: itemId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                name: tableManagement,
                path: tableManagement,
                builder: (context, state) => const TablesScreen(),
              ),
              GoRoute(
                name: purchase,
                path: purchase,
                redirect: (context, state) => '/$purchase/$supplier',
                routes: [
                  GoRoute(
                    path: purchaseList,
                    name: purchaseList,
                    builder: (context, state) => const PurchaseListScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: purchaseDetails,
                        builder: (context, state) {
                          final purchaseId = state.pathParameters['id'];
                          return PurchaseDetailsScreen(purchaseId: purchaseId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: purchasing,
                    name: purchasing,
                    builder: (context, state) => const PurchaseScreen(),
                    routes: [
                      GoRoute(
                        name: purchasePayment,
                        path: purchasePayment,
                        builder: (context, state) => const PurchasePaymentScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    name: supplier,
                    path: supplier,
                    builder: (context, state) => const SupplierListScreen(),
                    routes: [
                      GoRoute(
                        path: createSupplier,
                        name: createSupplier,
                        builder: (context, state) => const SupplierDetailsScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: supplierDetails,
                        builder: (context, state) {
                          final supplierId = state.pathParameters['id'];
                          return SupplierDetailsScreen(supplierId: supplierId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: purchaseReturn,
                    name: purchaseReturn,
                    builder: (context, state) => const PurchaseReturnListScreen(),
                    routes: [
                      GoRoute(
                        path: createPurchaseReturn,
                        name: createPurchaseReturn,
                        builder: (context, state) {
                          final purchaseId = state.uri.queryParameters['id'];
                          return PurchaseReturnDetailsScreen(
                            purchaseId: purchaseId,
                          );
                        },
                      ),
                      GoRoute(
                        path: ':id',
                        name: purchaseReturnDetails,
                        builder: (context, state) {
                          final purchaseReturnId = state.pathParameters['id'];
                          return PurchaseReturnViewScreen(
                            purchaseReturnId: purchaseReturnId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                name: sales,
                path: sales,
                redirect: (context, state) => '/$sales/$customer',
                routes: [
                  GoRoute(
                    path: pos,
                    name: pos,
                    builder: (context, state) => const SalesScreen(),
                    routes: [
                      GoRoute(
                        name: salePayment,
                        path: salePayment,
                        builder: (context, state) {
                          return const SalesPaymentScreen();
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: saleList,
                    name: saleList,
                    builder: (context, state) => const SaleListScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: saleDetails,
                        builder: (context, state) {
                          final saleId = state.pathParameters['id'];
                          return SaleDetailsScreen(saleId: saleId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: orderList,
                    name: orderList,
                    builder: (context, state) => const OrderListScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: orderDetails,
                        builder: (context, state) {
                          final saleId = state.pathParameters['id'];
                          return OrderDetailsScreen(saleId: saleId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: customer,
                    path: customer,
                    builder: (context, state) => const CustomerListScreen(),
                    routes: [
                      GoRoute(
                        path: createCustomer,
                        name: createCustomer,
                        builder: (context, state) => const CustomerDetailsScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: customerDetails,
                        builder: (context, state) {
                          final customerId = state.pathParameters['id'];
                          return CustomerDetailsScreen(customerId: customerId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: salesReturn,
                    name: salesReturn,
                    builder: (context, state) => const SaleReturnListScreen(),
                    routes: [
                      GoRoute(
                        path: createSaleReturn,
                        name: createSaleReturn,
                        builder: (context, state) {
                          final saleId = state.uri.queryParameters['id'];
                          return SaleReturnDetailsScreen(saleId: saleId);
                        },
                      ),
                      GoRoute(
                        path: ':id',
                        name: saleReturnDetails,
                        builder: (context, state) {
                          final saleReturnId = state.pathParameters['id'];
                          return SaleReturnViewScreen(
                            saleReturnId: saleReturnId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                name: users,
                path: users,
                redirect: (context, state) => '/$users/$userList',
                routes: [
                  GoRoute(
                    name: userList,
                    path: userList,
                    builder: (context, state) => const EmployeeListScreen(),
                  ),
                  GoRoute(
                    name: userRole,
                    path: userRole,
                    builder: (context, state) => const EmployeeRoleListScreen(),
                    routes: [
                      GoRoute(
                        path: createUserRole,
                        name: createUserRole,
                        builder: (context, state) => const EmployeeRoleDetailsScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: userRoleDetails,
                        builder: (context, state) {
                          final employeeRoleId = state.pathParameters['id'];
                          return EmployeeRoleDetailsScreen(
                            employeeRoleId: employeeRoleId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                name: accounting,
                path: accounting,
                redirect: (context, state) => '/$accounting/$expense',
                routes: [
                  GoRoute(
                    name: expense,
                    path: expense,
                    builder: (context, state) => const ExpenseScreen(),
                    routes: [
                      GoRoute(
                        path: createExpense,
                        name: createExpense,
                        builder: (context, state) => const ExpenseDetailsScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: expenseDetails,
                        builder: (context, state) {
                          final expenseId = state.pathParameters['id'];
                          return ExpenseDetailsScreen(expenseId: expenseId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: expenseCategory,
                    path: expenseCategory,
                    builder: (context, state) => const ExpenseCategoryScreen(),
                  ),
                  GoRoute(
                    name: income,
                    path: income,
                    builder: (context, state) => const IncomeScreen(),
                    routes: [
                      GoRoute(
                        path: createIncome,
                        name: createIncome,
                        builder: (context, state) => const IncomeDetailsScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: incomeDetails,
                        builder: (context, state) {
                          final incomeId = state.pathParameters['id'];
                          return IncomeDetailsScreen(incomeId: incomeId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: incomeCategory,
                    path: incomeCategory,
                    builder: (context, state) => const IncomeCategoryScreen(),
                  ),
                  GoRoute(
                    name: ledger,
                    path: ledger,
                    builder: (context, state) => const LedgerScreenWeb(),
                  ),
                  GoRoute(
                    name: chartOfAccounts,
                    path: chartOfAccounts,
                    builder: (context, state) => const ChartOfAccountsScreen(),
                  ),
                  GoRoute(
                    name: profitAndLoss,
                    path: profitAndLoss,
                    builder: (context, state) => const ProfitAndLossScreen(),
                  ),
                ],
              ),

              ///MARK:INVOICE
              GoRoute(
                name: invoice,
                path: invoice,
                redirect: (context, state) => '/$invoice/$invoices',
                routes: [
                  GoRoute(
                    name: invoices,
                    path: invoices,
                    builder: (context, state) => const InvoicesScreen(),
                    routes: [
                      GoRoute(
                        name: invoiceDetails,
                        path: invoiceDetails,
                        builder: (context, state) => const InvoiceDetailsScreen(),
                      ),
                      GoRoute(
                        name: createInvoice,
                        path: createInvoice,
                        builder: (context, state) => const CreateInvoiceScreen(),
                      ),
                      GoRoute(
                        name: editInvoice,
                        path: 'edit_invoice/:id',
                        builder: (context, state) {
                          final invoiceId = state.pathParameters['id'];
                          return CreateInvoiceScreen(invoiceId: invoiceId);
                        },
                      ),
                      GoRoute(
                        name: createPaymentFromInvoice,
                        path: 'create_payment_from_invoice/:id',
                        builder: (context, state) {
                          final paymentReceivedId = state.pathParameters['id'];

                          return CreatePaymentScreen(
                            paymentId: paymentReceivedId,
                          );
                        },
                      ),
                      GoRoute(
                        name: editPayment,
                        path: 'edit_payment/:id',
                        builder: (context, state) {
                          final paymentReceivedId = state.pathParameters['id'];

                          return EditPaymentScreen(
                            paymentId: paymentReceivedId,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: quote,
                    path: quote,
                    builder: (context, state) => const QuoteScreen(),
                    routes: [
                      GoRoute(
                        name: createQuote,
                        path: createQuote,
                        builder: (context, state) => const CreateQuoteScreen(),
                      ),
                      GoRoute(
                        name: editQuote,
                        path: 'edit_quote/:id',
                        builder: (context, state) {
                          final quoteId = state.pathParameters['id'];
                          return CreateQuoteScreen(quoteId: quoteId);
                        },
                      ),
                      GoRoute(
                        name: quoteDetails,
                        path: quoteDetails,
                        builder: (context, state) => const QuoteDetailsScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    name: paymentReceived,
                    path: paymentReceived,
                    builder: (context, state) => const PaymentReceivedScreen(),
                    routes: [
                      GoRoute(
                        name: createPayment,
                        path: 'create_payment/:id',
                        builder: (context, state) {
                          final paymentId = state.uri.queryParameters['id'];
                          return CreatePaymentScreen(paymentId: paymentId);
                        },
                      ),
                      GoRoute(
                        name: paymentRefund,
                        path: 'payment_refund/:id',
                        builder: (context, state) {
                          final paymentReceivedId = state.pathParameters['id'];
                          return PaymentRefundScreen(
                            paymentReceivedId: paymentReceivedId,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: creditNotes,
                    path: creditNotes,
                    builder: (context, state) => const CreditNotesScreen(),
                    routes: [
                      GoRoute(
                        name: createCreditNote,
                        path: createCreditNote,
                        builder: (context, state) => const CreateCreditScreen(),
                      ),
                      GoRoute(
                        name: editCreditNote,
                        path: 'edit_creditNote/:id',
                        builder: (context, state) {
                          final creditId = state.pathParameters['id'];
                          return CreateCreditScreen(
                            creditNoteId: creditId,
                          );
                        },
                      ),
                      GoRoute(
                        name: creditNoteDetails,
                        path: creditNoteDetails,
                        builder: (context, state) => const CreditNoteDetailsScreen(),
                      ),
                      GoRoute(
                        name: creditNoteRefund,
                        path: 'credit_note_refund/:id',
                        builder: (context, state) {
                          final paymentReceivedId = state.pathParameters['id'];
                          return PaymentRefundScreen(
                            sourceCreditId: paymentReceivedId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              GoRoute(
                name: branch,
                path: branch,
                builder: (context, state) => const BranchScreen(),
                routes: [
                  GoRoute(
                    name: createBranch,
                    path: createBranch,
                    builder: (context, state) => const CreatebaranchScreen(),
                  ),
                  GoRoute(
                    name: branchDetails,
                    path: ':id',
                    builder: (context, state) {
                      final branchId = state.pathParameters['id'];
                      return BranchDetailsScreen(businessId: branchId);
                    },
                  ),
                ],
              ),
              GoRoute(
                name: settings,
                path: settings,
                builder: (context, state) {
                  final branchId = ref.read(businessNotifierProvider)!.businessId;

                  return BranchDetailsScreen(businessId: branchId);
                },
              ),
              GoRoute(
                name: profile,
                path: profile,
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: reports,
                name: reports,
                builder: (context, state) => const ReportsScreen(),
              ),
              GoRoute(
                path: subscriptionPlans,
                name: subscriptionPlans,
                builder: (context, state) => const SubscriptionPlansScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/$splash',
            name: splash,
            builder: (context, state) => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          GoRoute(
            path: '/$login',
            name: login,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            name: signup,
            path: '/$signup',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            name: businessRegister,
            path: '/$businessRegister',
            builder: (context, state) {
              final formValues = state.extra! as Map<String, dynamic>;
              return BusinessRegisterScreen(formValues: formValues);
            },
          ),
          GoRoute(
            name: forgotPassword,
            path: '/$forgotPassword',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            name: enterOTP,
            path: '/$enterOTP',
            builder: (context, state) => const EnterOtpScreen(),
          ),
          GoRoute(
            name: newPassword,
            path: '/$newPassword',
            builder: (context, state) => const NewPasswordScreen(),
          ),
          GoRoute(
            name: setNewUser,
            path: '/$setNewUser',
            builder: (context, state) {
              final refreshToken = state.uri.queryParameters['refresh_token'];
              final orgId = state.uri.queryParameters['org_id'];
              final type = state.uri.queryParameters['type'];
              final accessToken = state.uri.queryParameters['access_token'];
              return NewPasswordScreen(
                refreshToken: refreshToken,
                orgId: orgId,
                type: type,
                accessToken: accessToken,
              );
            },
          ),
        ],
      ),
    ],
    refreshListenable: Listenable.merge([authState]),
    redirect: (context, state) {
      const loginPath = '/$login';
      const homePath = '/';
      const splashPath = '/$splash';

      /// Preserve extra data during redirects
      final extra = state.extra;

      /// Auth reirection flow
      if (authState.value == null) {
        return null;
      }
      if (authState.value!.unwrapPrevious().hasError) {
        // Return Login Route
        return loginPath;
      }
      if (authState.value!.isLoading || !authState.value!.hasValue) {
        // Return Splash Route
        return splashPath;
      }

      final isAuth = !(authState.value!.value?.session?.isExpired ?? true);

      final isSplash = state.topRoute?.name == splash;
      final isLoggingIn = state.topRoute?.name == login;
      final isRegisterPage = state.topRoute?.name == businessRegister;
      final isSignUpPage = state.topRoute?.name == signup;
      final isForgotPassword = state.topRoute?.name == forgotPassword;
      final isEnterOTP = state.topRoute?.name == enterOTP;
      final isNewPassword = state.topRoute?.name == newPassword;
      final isSetNewUser = state.topRoute?.name == setNewUser;

      // if (isSplash) {
      //   // Use context.go to preserve extra data
      //   if (isAuth) {
      //     context.go(homePath, extra: extra);
      //     return null;
      //   }
      //   return loginPath;
      // }

      // if (isLoggingIn || isRegisterPage || isSignUpPage || isForgotPassword || isEnterOTP || isNewPassword) {
      //   if (isAuth) {
      //     context.go(homePath, extra: extra);
      //     return null;
      //   }
      //   return null;
      // }

      // return isAuth ? null : splashPath;
      if (isSplash) return isAuth ? homePath : loginPath;
      if (isLoggingIn ||
          isRegisterPage ||
          isSignUpPage ||
          isForgotPassword ||
          isEnterOTP ||
          isNewPassword ||
          isSetNewUser) {
        return isAuth ? homePath : null;
      }

      return isAuth ? null : splashPath;
    },
  );

  CustomTransitionPage<void> fadeTransition(
    GoRouterState state,
    Widget screen,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: screen,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) =>
          FadeTransition(
        opacity: animation.drive(
          Tween<double>(
            begin: 0,
            end: 1,
          ).chain(CurveTween(curve: Curves.easeIn)),
        ),
        child: child,
      ),
    );
  }

  CustomTransitionPage<void> slideTransition(
    GoRouterState state,
    Widget screen,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: screen,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) =>
          SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeIn)),
        ),
        child: child,
      ),
    );
  }

  static void goNamed(
    String route, {
    Object? extra,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
  }) =>
      _rootNavigatorKey.currentState?.context.goNamed(
        route,
        extra: extra,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      );

  static void go(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      _rootNavigatorKey.currentState?.context.go(
        name,
        extra: extra,
      );

  /// Navigate to a named route onto the page stack.
  static Future<T?>? pushNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      _rootNavigatorKey.currentState?.context.pushNamed<T>(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );

  static void pop<T extends Object?>([T? result]) => _rootNavigatorKey.currentContext?.pop(result);

  static T read<T>(ProviderBase<T> provider) {
    return ProviderScope.containerOf(rootContext, listen: false).read(provider);
  }

  static T watch<T>(ProviderBase<T> provider) {
    return ProviderScope.containerOf(rootContext).read(provider);
  }

  static void showConfirmationDialog({
    required String title,
    required List<Widget> children,
    VoidCallback? onPositive,
    VoidCallback? onNegative,
    Widget? icon,
    String? positiveText,
    String? negativeText,
  }) =>
      showDialog<void>(
        context: AppRouter.rootContext,
        builder: (context) => ConfirmationDialog(
          icon: icon,
          title: title,
          positiveText: positiveText,
          negativeText: negativeText,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
          onPositive: (ref) {
            onPositive?.call();
          },
          onNegative: (ref) {
            onNegative?.call();
          },
        ),
      );
}
