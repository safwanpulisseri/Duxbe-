import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'customer_details_mobile.dart';
export 'customer_details_web.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  const CustomerDetailsScreen({super.key, this.customerId});
  final String? customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ref.watch(customerProvider(customerId)).when(
            data: (customer) => ResponsiveWidget(
              smallScreen: CustomerDetailsScreenMobile(customer: customer),
              largeScreen: CustomerDetailsScreenWeb(customer: customer),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
