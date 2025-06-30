import 'package:duxbe/features/accounting/accounting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profit_and_loss_notifier.g.dart';

@Riverpod(keepAlive: false)
Future<ProfitAndLoss> profitAndLoss(
  ProfitAndLossRef ref,
  DateTime startDate,
  DateTime endDate,
) =>
    ref.watch(chartOfAccountsRepoProvider).getProfitAndLoss(startDate: startDate, endDate: endDate);
