import 'package:duxbe/features/accounting/accounting.dart';

abstract class IChartOfAccountsRepository {
  Future<List<ChartOfAccounts>> getChartOfAccountsTree();
  Future<ProfitAndLoss> getProfitAndLoss({
    required DateTime startDate,
    required DateTime endDate,
  });
}
