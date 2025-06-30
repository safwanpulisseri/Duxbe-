import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'income_details_mobile.dart';
export 'income_details_web.dart';

class IncomeDetailsScreen extends ConsumerWidget {
  const IncomeDetailsScreen({super.key, this.incomeId});
  final String? incomeId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(incomeProvider(incomeId)).when(
            data: (income) => ResponsiveWidget(
              smallScreen: IncomeDetailsScreenMobile(income: income),
              largeScreen: IncomeDetailsScreenWeb(income: income),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
