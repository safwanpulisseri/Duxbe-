import 'package:duxbe/env.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:upgrader/upgrader.dart';

class App extends ConsumerWidget {
  App({required this.environment, super.key});
  final IEnvironment environment;
  // Add upgrader URL
  static const appcastURL = 'https://business.duxbe.com/duxbe_business.upgrader.xml';
  final upgrader = Upgrader(
    storeController: UpgraderStoreController(
      onAndroid: () => UpgraderAppcastStore(appcastURL: appcastURL),
      oniOS: () => UpgraderAppcastStore(appcastURL: appcastURL),
    ),
    debugLogging: true,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    final isMobile = MediaQuery.sizeOf(context).width < tabletSize;
    final router = isMobile ? appRouter.mobileRouter : appRouter.desktopRouter;
    // This is to load initial country settings, sharedPrefs
    ref
      ..watch(authNotifierProvider)
      ..watch(ipConfigProvider)
      ..watch(sharedPrefsProvider)
      ..watch(analyticsProvider)
      ..watch(currentTimeZoneProvider)
      ..watch(printerServiceProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ref.watch(themeProvider),
      title: 'Duxbe',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(localeProvider),
      scrollBehavior: const CustomScrollBehavior(),
      builder: (context, child) {
        // You can wrap Internet connection alert here
        return NewOrderDialog(
          navigatorKey: router.routerDelegate.navigatorKey,
          child: UpgradeAlert(
            navigatorKey: router.routerDelegate.navigatorKey,
            // child: child,
            child: InternetAlert(
              onRetry: () {
                // Handle retry - you might want to refresh data or current page
                ref.invalidate(ipConfigProvider);
              },
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
