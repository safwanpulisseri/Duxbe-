import 'package:duxbe/features/home/home.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'dashboard_mobile.dart';
export 'dashboard_web.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ResponsiveWidget(
        smallScreen: DashboardScreenMobile(),
        largeScreen: DashboardScreenWeb(),
      ),
    );
  }
}
