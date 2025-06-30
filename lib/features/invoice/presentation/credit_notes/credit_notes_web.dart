import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class CreditNotesScreenWeb extends ConsumerStatefulWidget {
  const CreditNotesScreenWeb({super.key});

  @override
  ConsumerState<CreditNotesScreenWeb> createState() => _CreditNotesScreenWebState();
}

class _CreditNotesScreenWebState extends ConsumerState<CreditNotesScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final creditNoteNotifier = ref.watch(creditNoteNotifierProvider.notifier);
    final creditNoteState = ref.watch(creditNoteNotifierProvider);

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
                      name: 'credit_note_search',
                      hintText: context.l10n.search,
                      onChanged: (val) {
                        debouncer.run(() {
                          creditNoteNotifier.setFilter(query: val);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppButton.icon(
                    padding: const EdgeInsets.all(16),
                    onPress: () {
                      context.goNamed(AppRouter.createCreditNote);
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
                        columns: creditNoteNotifier.creditNoteColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows:  [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          creditNoteNotifier.setStateManager(stateManager: event.stateManager);
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        creditNoteNotifier.setFilter(pageNumber: value);
                      },
                      totalPages: (creditNoteState.count / creditNoteState.pageSize).ceil(),
                      currentPage: creditNoteState.pageNumber,
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
