import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fiscal_period_notifier.g.dart';

@Riverpod(keepAlive: false)
Future<(DateTime, DateTime)?> currentFiscalPeriod(
  CurrentFiscalPeriodRef ref,
) =>
    ref.watch(businessRepoProvider).getCurrentFiscalPeriod(ref.watch(businessNotifierProvider)?.businessId);
