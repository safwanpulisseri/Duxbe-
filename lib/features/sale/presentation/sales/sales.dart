import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'sales_mobile.dart';
export 'sales_web.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ResponsiveWidget(
        smallScreen: SalesScreenMobile(),
        largeScreen: SalesScreenWeb(),
      ),
    );
  }
}
