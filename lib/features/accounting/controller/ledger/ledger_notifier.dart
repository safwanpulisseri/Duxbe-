import 'dart:async';

import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ledger_notifier.freezed.dart';
part 'ledger_notifier.g.dart';
part 'ledger_state.dart';

@Riverpod(keepAlive: false)
class LedgerNotifier extends _$LedgerNotifier {
  late ILedgerRepository _ledgerRepository;

  @override
  LedgerState build() {
    _ledgerRepository = ref.watch(ledgerRepoProvider); // Watch for business changes

    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      state.pagingController?.refresh();
      getParties(pageNumber: 1);
      getLedger();
    });

    state = LedgerState.initial();
    getLedger();
    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Party>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final parties = await getParties(pageNumber: pageKey);
            final isLastPage = parties.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(parties);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(parties, nextPageKey);
            }
          },
        ),
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    getParties();
  }

  Future<void> getLedger() async {
    try {
      final ledger = await _ledgerRepository.getLedger();
      state = state.copyWith(ledger: ledger);
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<List<Party>> getParties({
    String? query,
    int? pageSize,
    int? pageNumber,
    TransactionParty? party,
  }) async {
    try {
      state.stateManager?.setShowLoading(true);
      state = state.copyWith(status: LedgerStatus.loading);
      final parties = await _ledgerRepository.getParties(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        party: party ?? state.party,
      );
      state = state.copyWith(
        status: LedgerStatus.success,
        parties: parties.data,
        pageNumber: pageNumber ?? state.pageNumber,
        count: parties.count,
      );
      unawaited(setTable());
      return parties.data;
    } catch (e) {
      state = state.copyWith(
        status: LedgerStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      return [];
    }
  }

  Future<void> setTable() async {
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      ledgerColumns,
      [
        for (int i = 0; i < state.parties.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'name': PlutoCell(value: state.parties[i].name),
              'type': PlutoCell(value: state.parties[i].type.name.displayCase),
              'amount': PlutoCell(value: state.parties[i].amount),
              'due_amount': PlutoCell(value: state.parties[i].dueAmount),
              'actions': PlutoCell(value: state.parties[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> ledgerColumns = <PlutoColumn>[
    PlutoColumn(
      title: 'SL.No',
      field: 'sl_no',
      width: 24,
      titleSpan: TextSpan(
        text: AppRouter.l10n.slNo,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Name',
      field: 'name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.name,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Type',
      field: 'type',
      titleSpan: TextSpan(
        text: AppRouter.l10n.type,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Amount',
      field: 'amount',
      titleSpan: TextSpan(
        text: AppRouter.l10n.amount,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Due Amount',
      field: 'due_amount',
      titleSpan: TextSpan(
        text: AppRouter.l10n.dueAmount,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      titleTextAlign: PlutoColumnTextAlign.center,
      title: 'Action',
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        return Center(
          child: AppButton(
            padding: const EdgeInsets.all(2),
            label: Text(AppRouter.l10n.view),
            width: 20,
            style: ButtonStyles.secondary,
            onPress: () {
              showDialog<void>(
                context: AppRouter.rootContext,
                builder: (context) => LedgerDetailsDialog(
                  transaction: rendererContext.cell.value as Party,
                ),
              );
            },
          ),
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
