import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'expense_details_mobile.dart';
export 'expense_details_web.dart';

class ExpenseDetailsScreen extends ConsumerWidget {
  const ExpenseDetailsScreen({super.key, this.expenseId});
  final String? expenseId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(expenseProvider(expenseId)).when(
            data: (expense) => ResponsiveWidget(
              smallScreen: ExpenseDetailsScreenMobile(expense: expense),
              largeScreen: ExpenseDetailsScreenWeb(expense: expense),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
