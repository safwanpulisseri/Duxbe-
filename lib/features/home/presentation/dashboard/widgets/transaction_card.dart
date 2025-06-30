import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class TransactionCard extends ConsumerStatefulWidget {
  const TransactionCard({super.key});

  @override
  ConsumerState<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends ConsumerState<TransactionCard> {
  late List<PlutoRow<SaleView>> rows;
  late PlutoGridStateManager stateManager;
  late List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: context.l10n.billNo,
      field: 'bill_no',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: context.l10n.dateTime,
      field: 'date_time',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: context.l10n.pyType,
      field: 'type',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: context.l10n.phoneNumber,
      field: 'phone_no',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: context.l10n.status,
      field: 'status',
      titleTextAlign: PlutoColumnTextAlign.center,
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: context.l10n.amount,
      field: 'amount',
      type: PlutoColumnType.text(),
    ),
  ];
  final pageSize = 50;
  @override
  void initState() {
    super.initState();

    // Pass an empty row to the grid initially.
    rows = [];
  }

  Future<PlutoInfinityScrollRowsResponse> fetch(
    PlutoInfinityScrollRowsRequest request,
  ) async {
    final pageNumber = request.lastRow?.state.index ?? 1;
    final fetchedRows =
        await ref.read(saleRepoProvider).getSales(pageNumber: pageNumber, pageSize: pageSize, orderMode: null);
    final isLast = fetchedRows.data.length < pageSize;
    return Future.value(
      PlutoInfinityScrollRowsResponse(
        isLast: isLast,
        rows: fetchedRows.data
            .map(
              (e) => PlutoRow<SaleView>(
                cells: {
                  'bill_no': PlutoCell(value: e.saleInvoice),
                  'date_time': PlutoCell(value: e.saleDate.toFullFormat),
                  'type': PlutoCell(value: e.payments.map((e) => e.paymentMethod.name.displayCase).join(', ')),
                  'phone_no': PlutoCell(value: e.customer?.phone ?? ''),
                  'status': PlutoCell(value: e.transaction.status.name.displayCase),
                  'amount': PlutoCell(value: e.totalAmount),
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void _update() {
    stateManager.setShowLoading(
      true,
      level: PlutoGridLoadingLevel.rows,
    );

    final request = PlutoInfinityScrollRowsRequest(
      sortColumn: stateManager.getSortedColumn,
      filterRows: stateManager.filterRows,
    );

    fetch(request).then((response) {
      final scrollController = stateManager.scroll.bodyRowsVertical;
      if (scrollController != null && scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
      stateManager
        ..removeAllRows(notify: false)
        ..appendRows(response.rows)
        ..setShowLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      businessNotifierProvider.select(
        (value) => value?.businessId,
      ),
      (previous, next) {
        if (next != null) {
          _update();
        }
      },
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 26),
      decoration: AppStyles.boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.recentTransactions, style: AppText.xLargeSB),
          const SizedBox(height: 12),
          Expanded(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onChanged: print,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              mode: PlutoGridMode.readOnly,
              noRowsWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Assets.icons.emptyBox.svg(width: 200, height: 130),
                  ),
                  Text(
                    context.l10n.noRecentTransaction,
                    textAlign: TextAlign.center,
                    style: AppText.mediumB.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.pleaseAddAnItemFirstToCreateASale,
                    textAlign: TextAlign.center,
                    style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        onPress: () {
                          AppRouter.goNamed(AppRouter.createItem);
                        },
                        label: Text(context.l10n.addItem),
                      ),
                    ],
                  ),
                ],
              ),
              configuration: const PlutoGridConfiguration(
                enterKeyAction: PlutoGridEnterKeyAction.none,
                columnSize: PlutoGridColumnSizeConfig(
                  autoSizeMode: PlutoAutoSizeMode.scale,
                ),
                style: PlutoGridStyleConfig(
                  enableCellBorderVertical: false,
                  borderColor: AppColors.divider,
                  activatedColor: AppColors.divider,
                  activatedBorderColor: AppColors.primaryColor,
                  enableColumnBorderVertical: false,
                  gridBorderColor: Colors.transparent,
                ),
              ),
              createFooter: (s) => PlutoInfinityScrollRows(
                fetch: fetch,
                stateManager: s,
                fetchWithFiltering: false,
                fetchWithSorting: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
