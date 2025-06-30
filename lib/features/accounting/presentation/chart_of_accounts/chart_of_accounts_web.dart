import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartOfAccountsScreenWeb extends ConsumerStatefulWidget {
  const ChartOfAccountsScreenWeb({super.key});

  @override
  ConsumerState<ChartOfAccountsScreenWeb> createState() => _ChartOfAccountsScreenWebState();
}

class _ChartOfAccountsScreenWebState extends ConsumerState<ChartOfAccountsScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final chartOfAccountsNotifier = ref.watch(chartOfAccountsNotifierProvider.notifier);
    final chartOfAccountsState = ref.watch(chartOfAccountsNotifierProvider);

    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.success => chartOfAccountsNotifier.when(
          initial: () => const SizedBox(),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (chartOfAccounts) => Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.chartOfAccounts,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: chartOfAccounts.map(_buildAccountTree).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: () => Center(
            child: Text(
              context.l10n.errorLoadingChartOfAccounts,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      _ => const SizedBox(),
    };
  }

  Widget _buildAccountTree(ChartOfAccounts account) {
    return ExpansionTile(
      initiallyExpanded: true,
      backgroundColor: Colors.grey.shade50,
      collapsedBackgroundColor: Colors.grey.shade50,
      title: Text(
        '${account.code} - ${account.name}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        account.description,
        style: TextStyle(color: Colors.grey.shade700),
      ),
      children: [
        if (account.children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: account.children.map(_buildAccountItem).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAccountItem(Accounts account) {
    if (account.isGroup && account.children.isNotEmpty) {
      return ExpansionTile(
        initiallyExpanded: true,
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        title: Text(
          '${account.code} - ${account.name}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          account.description ?? '',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${context.l10n.balance} ${account.children.isEmpty ? account.balance : account.children.fold(0, (previousValue, element) => previousValue + element.balance)}',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        children: account.children
            .map(
              (child) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildAccountItem(child),
              ),
            )
            .toList(),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        '${account.code} - ${account.name}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        account.description ?? '',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${context.l10n.balance} ${account.balance}',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
