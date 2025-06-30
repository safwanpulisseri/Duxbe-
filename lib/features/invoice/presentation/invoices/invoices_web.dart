import 'package:duxbe/features/auth/controller/auth/auth_notifier.dart';
import 'package:duxbe/features/invoice/controller/invoice/invoice_notifier.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class InvoicesScreenWeb extends ConsumerStatefulWidget {
  const InvoicesScreenWeb({super.key});

  @override
  ConsumerState<InvoicesScreenWeb> createState() => _InvoicesScreenWebState();
}

class _InvoicesScreenWebState extends ConsumerState<InvoicesScreenWeb> {
  Debouncer debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final invoiceNotifier = ref.watch(invoiceNotifierProvider.notifier);
    final invoiceState = ref.watch(invoiceNotifierProvider);

    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.success => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: AppStyles.boxDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextForm<String>(
                      name: 'invoice_search',
                      hintText: context.l10n.search,
                      onChanged: (val) {
                        debouncer.run(() {
                          invoiceNotifier.setFilter(query: val);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppButton.icon(
                    padding: const EdgeInsets.all(16),
                    onPress: () {
                      context.goNamed(AppRouter.createInvoice);
                    },
                    label: Text(context.l10n.create),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                   Expanded(
                      child: PlutoGrid(
                        mode: PlutoGridMode.readOnly,
                        columns: invoiceNotifier.invoiceColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows:  [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          invoiceNotifier.setStateManager(
                              stateManager: event.stateManager,);
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        invoiceNotifier.setFilter(pageNumber: value);
                      },
                      totalPages: (invoiceState.count / invoiceState.pageSize).ceil(),
                      currentPage: invoiceState.pageNumber,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      _ => const SizedBox(),
    };
  }
}