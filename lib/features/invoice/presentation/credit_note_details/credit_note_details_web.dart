import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/invoice/presentation/credit_note_details/widgets/credit_note_card.dart';
import 'package:duxbe/features/invoice/presentation/credit_note_details/widgets/credit_note_details_card.dart';
import 'package:duxbe/features/invoice/presentation/widgets/invoice_details_card.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class CreditNoteDetailsScreenWeb extends ConsumerStatefulWidget {
  const CreditNoteDetailsScreenWeb({super.key});

  @override
  ConsumerState<CreditNoteDetailsScreenWeb> createState() => _CreditNoteDetailsScreenWebState();
}

class _CreditNoteDetailsScreenWebState extends ConsumerState<CreditNoteDetailsScreenWeb> {
  TextEditingController searchController = TextEditingController();
  final debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final creditState = ref.watch(creditNoteNotifierProvider);
    final creditStateNotifier = ref.watch(creditNoteNotifierProvider.notifier);
    final business = ref.watch(businessNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Column(
          children: [
            /// MARK: SEARCH
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: AppStyles.boxDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: AppTextForm<String>(
                      name: 'search',
                      controller: searchController,
                      hintText: context.l10n.search,
                      onChanged: (v) {
                        debouncer.run(() {
                          creditStateNotifier.setFilter(query: v);
                        });
                      },
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppButton.icon(
                    color: AppColors.primaryColor,
                    icon: const Icon(Icons.add),
                    onPress: () {
                      context.pushNamed(AppRouter.createCreditNote);
                    },
                    label: Text(AppRouter.l10n.create),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Expanded to fill remaining height
            Expanded(
              child: Row(
                children: [
                  // Left side list with quotes
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: AppStyles.boxDecoration,
                      child: PagedListView.separated(
                        pagingController: creditState.creditDetailsPagingController!,
                        builderDelegate: PagedChildBuilderDelegate<CreditNote>(
                          itemBuilder: (context, credit, index) => CreditNoteCard(
                            currency: business?.currency?.code ?? '',
                            customerName: credit.customer?.name ?? '',
                            creditCode: credit.creditNoteCode ?? '',
                            createdAt: credit.createdAt?.toLocal() ?? DateTime.now(),
                            creditStatus: credit.status ?? CreditNoteFormStatus.open,
                            grandTotal: credit.grandTotal ?? 0,
                            onTap: () {
                              creditStateNotifier.setFilter(
                                selectedQuoteId: credit.creditNoteId,
                              );
                            },
                            isSelected: credit.creditNoteId == creditState.selectedCreditId,
                          ),
                          noItemsFoundIndicatorBuilder: (context) => const Center(
                            child: NoDataViewWidget(),
                          ),
                        ),
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  // Right side actions

                  ref
                      .watch(
                        creditNoteDataProvider(creditState.selectedCreditId),
                      )
                      .when(
                        data: (creditNoteData) {
                          final refundDetailsList = creditNoteData?.refundDetails ?? [];
                          return Expanded(
                            flex: 2,
                            child: creditNoteData == null
                                ? const NoDataViewWidget()
                                : Column(
                                    children: [
                                      creditNoteHeader(
                                        creditNote: creditNoteData,
                                      ),
                                      const SizedBox(height: 10),
                                      ...refundDetailsList.map(
                                        (e) => RefundTableCard(
                                          onDelete: () {
                                            showDialog<void>(
                                              context: context,
                                              builder: (context) => ConfirmationDialog(
                                                positiveText: context.l10n.delete,
                                                isLoading: ref
                                                        .watch(
                                                          paymentReceivedNotifierProvider,
                                                        )
                                                        .status ==
                                                    PaymentReceivedStatus.loading,
                                                onPositive: (ref) {
                                                  ref
                                                      .read(
                                                        creditNoteNotifierProvider.notifier,
                                                      )
                                                      .deleteRefund(e.refundId);
                                                },
                                                title: context.l10n.deleteQuote,
                                                children: [
                                                  Text(
                                                    context.l10n.areYouSureYouWantToDeleteThisRefund,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          context: context,
                                          invCod: creditNoteData.invoiceDetails?.invoiceCode ?? '',
                                          currency: business?.currency?.code ?? '',
                                          refundDetails: e,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: CreditNoteDetailsCard(
                                            currencyCode: business?.currency?.code ?? '',
                                            type: InvoiceType.credit,
                                            invoiceNumber: creditNoteData.creditNoteCode ?? '',
                                            quoteDate: DateFormat('dd MMM yyyy').format(
                                              creditNoteData.createdAt?.toLocal() ?? DateTime.now(),
                                            ),
                                            expiryDate: DateFormat('dd MMM yyyy').format(
                                              creditNoteData.invoiceDetails?.dueDate?.toLocal() ?? DateTime.now(),
                                            ),
                                            referenceInvoiceNumber: creditNoteData
                                                .invoiceDetails?.invoiceCode, // Reference to original invoice
                                            customerName: creditNoteData.customer?.name ?? '',
                                            customerAddress:
                                                '${creditNoteData.invoiceDetails?.billingAddress?.address ?? ''}, \n${creditNoteData.invoiceDetails?.billingAddress?.city ?? ''}, ${creditNoteData.invoiceDetails?.billingAddress?.state ?? ''} \n${creditNoteData.invoiceDetails?.billingAddress?.zipcode ?? ''}, ${creditNoteData.invoiceDetails?.billingAddress?.country ?? ''}',
                                            items: creditNoteData.creditNoteItems
                                                    ?.map(
                                                      (e) => InvoiceItem(
                                                        description: e.item?.name ?? '',
                                                        subDescription: e.item?.itemCategory?.name ?? '',
                                                        quantity: e.quantity?.toDouble() ?? 0,
                                                        rate: e.unitPrice ?? 0,
                                                        tax: 0,
                                                        amount: e.totalPrice ?? 0,
                                                      ),
                                                    )
                                                    .toList() ??
                                                [],
                                            subtotal: creditNoteData.subTotal ?? 0,
                                            cgst: creditNoteData.taxTotal ?? 0,
                                            sgst: creditNoteData.taxTotal ?? 0,
                                            total: creditNoteData.grandTotal ?? 0,
                                            creaditRemaining: creditNoteData.creditRemaining ?? 0,
                                            totalInWords: AmountToWordsConverter.convertToWordsOnly(
                                              creditNoteData.grandTotal ?? 0,
                                            ),
                                            note: creditNoteData.notes ?? '',
                                            termsAndConditions: creditNoteData.termsAndConditions ?? '',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          );
                        },
                        loading: () => Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Container(
                                decoration: AppStyles.boxDecoration,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    MenuAnchor(
                                      alignmentOffset: const Offset(0, 8),
                                      menuChildren: [
                                        MenuItemButton(
                                          leadingIcon: const Icon(
                                            Icons.print,
                                            color: AppColors.primaryColor,
                                          ),
                                          style: MenuItemButton.styleFrom(
                                            foregroundColor: AppColors.primaryColor,
                                          ),
                                          onPressed: () {},
                                          child: Text(context.l10n.print),
                                        ),
                                        MenuItemButton(
                                          leadingIcon: const Icon(
                                            Icons.edit,
                                            color: AppColors.primaryColor,
                                          ),
                                          style: MenuItemButton.styleFrom(
                                            foregroundColor: AppColors.primaryColor,
                                          ),
                                          onPressed: () {},
                                          child: Text(context.l10n.edit),
                                        ),
                                        MenuItemButton(
                                          leadingIcon: const Icon(
                                            Icons.delete,
                                            color: AppColors.red,
                                          ),
                                          style: MenuItemButton.styleFrom(
                                            foregroundColor: AppColors.red,
                                          ),
                                          onPressed: () {},
                                          child: Text(context.l10n.delete),
                                        ),
                                      ],
                                      builder: (context, controller, child) {
                                        return AppButton.icon(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          style: ButtonStyles.secondary,
                                          color: AppColors.black,
                                          iconLeading: false,
                                          icon: const Icon(
                                            CupertinoIcons.chevron_down,
                                            color: AppColors.purple,
                                          ),
                                          onPress: () {
                                            if (controller.isOpen) {
                                              controller.close();
                                            } else {
                                              controller.open();
                                            }
                                          },
                                          label: Text(context.l10n.moreOptions),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    AppButton(
                                      style: ButtonStyles.secondary,
                                      onPress: () {},
                                      label: Text(context.l10n.convertToInvoice),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Expanded(
                                child: SingleChildScrollView(
                                  child: BuildShimmerCard(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        error: (error, stackTrace) => Expanded(
                          child: Center(
                            child: Text('Error: $error'),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget creditNoteHeader({required CreditNote creditNote}) {
    return Container(
      decoration: AppStyles.boxDecoration,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Text(
                creditNote.creditNoteCode ?? '',
                style: AppText.largeSB,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MenuAnchor(
                  alignmentOffset: const Offset(0, 8),
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: const Icon(
                        Icons.print,
                        color: AppColors.primaryColor,
                      ),
                      style: MenuItemButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                      onPressed: () async {
                        await PdfService.printCreditNotePdf(
                          creditRemaining: creditNote.creditRemaining ?? 0,
                          creditNoteDate:
                              DateFormat('dd MMM yyyy').format(creditNote.creditNoteDate?.toLocal() ?? DateTime.now()),
                          creditNoteNumber: creditNote.creditNoteCode ?? '',
                          referenceInvoiceNumber: creditNote.linkedInvoiceCode ?? '',
                          customerName: creditNote.customerName ?? '',
                          customerAddress:
                              '${creditNote.invoiceDetails?.billingAddress?.address ?? ''}, \n${creditNote.invoiceDetails?.billingAddress?.city ?? ''}, ${creditNote.invoiceDetails?.billingAddress?.state ?? ''} \n${creditNote.invoiceDetails?.billingAddress?.zipcode ?? ''}, ${creditNote.invoiceDetails?.billingAddress?.country ?? ''}',
                          items: creditNote.invoiceDetails!.invoiceItems
                              .map(
                                (e) => InvoiceItem(
                                  description: e.item?.name ?? '',
                                  subDescription: e.item?.itemCategory?.name ?? '',
                                  quantity: e.quantity?.toDouble() ?? 0,
                                  rate: e.unitPrice ?? 0,
                                  tax: 0,
                                  amount: e.totalPrice ?? 0,
                                ),
                              )
                              .toList(),
                          subtotal: creditNote.subTotal ?? 0,
                          cgst: creditNote.taxTotal ?? 0,
                          sgst: creditNote.taxTotal ?? 0,
                          total: creditNote.grandTotal ?? 0,
                          totalInWords: AmountToWordsConverter.convertToWordsOnly(
                            creditNote.grandTotal ?? 0,
                          ),
                          note: creditNote.notes ?? '',
                          termsAndConditions: creditNote.termsAndConditions ?? '',
                        );
                      },
                      child: Text(context.l10n.print),
                    ),
                    MenuItemButton(
                      leadingIcon: const Icon(
                        Icons.edit,
                        color: AppColors.primaryColor,
                      ),
                      style: MenuItemButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                      onPressed: () async {
                        await context.pushNamed(
                          AppRouter.editCreditNote,
                          pathParameters: {
                            'id': creditNote.creditNoteId!,
                          },
                        );
                      },
                      child: Text(context.l10n.edit),
                    ),
                    MenuItemButton(
                      leadingIcon: const Icon(
                        Icons.delete,
                        color: AppColors.red,
                      ),
                      style: MenuItemButton.styleFrom(
                        foregroundColor: AppColors.red,
                      ),
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => ConfirmationDialog(
                            positiveText: context.l10n.delete,
                            isLoading: ref
                                    .watch(
                                      paymentReceivedNotifierProvider,
                                    )
                                    .status ==
                                PaymentReceivedStatus.loading,
                            onPositive: (ref) {
                              ref.read(creditNoteNotifierProvider.notifier).deleteCredit(creditNote.creditNoteId!);
                            },
                            title: context.l10n.deleteQuote,
                            children: [
                              Text(
                                context.l10n.areYouSureYouWantToDeleteThisQuote,
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(context.l10n.delete),
                    ),
                  ],
                  builder: (context, controller, child) {
                    return AppButton.icon(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      style: ButtonStyles.secondary,
                      color: AppColors.stormyBlue,
                      iconLeading: false,
                      icon: const Icon(
                        CupertinoIcons.chevron_down,
                        color: AppColors.purple,
                      ),
                      onPress: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      label: Text(
                        context.l10n.moreOptions,
                        style: AppText.mediumSB.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                AppButton(
                  style: ButtonStyles.secondary,
                  onPress: () {
                    context.goNamed(
                      AppRouter.creditNoteRefund,
                      pathParameters: {
                        'id': creditNote.creditNoteId.toString(),
                      },
                    );
                  },
                  label: Text(context.l10n.refund),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget creditNoteInvoiceTable(
  //   BuildContext context,
  //   RefundPaymentDetails refundDetails,
  //   String invCod,
  //   String currency, {
  //   required VoidCallback onDelete,
  // }) {
  //   return Container(
  //     decoration: AppStyles.boxDecoration,
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  //     child: Column(
  //       children: [
  //         // Header Row
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Center(
  //                 child: Text(
  //                   context.l10n.date,
  //                   style: AppText.largeN.copyWith(color: Colors.grey),
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               child: Center(
  //                 child: Text(
  //                   context.l10n.invoiceNumber,
  //                   style: AppText.largeN.copyWith(color: Colors.grey),
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               child: Center(
  //                 child: Text(
  //                   context.l10n.amountCredited,
  //                   style: AppText.largeN.copyWith(color: Colors.grey),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 48), // for delete icon space
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         // Data Row
  //         Container(
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF9F9F9),
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: const Color(0xFFE0E0E0)),
  //           ),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: Center(
  //                   child: Text(
  //                     refundDetails.refundDate.toDateOnly,
  //                     // '01/01/2025',
  //                     style: AppText.largeSB.copyWith(color: AppColors.black),
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Center(
  //                   child: Text(
  //                     invCod,
  //                     style: AppText.largeSB.copyWith(color: AppColors.black),
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Center(
  //                   child: Text(
  //                     currency + ' ${refundDetails.amountRefunded}',
  //                     style: AppText.largeSB.copyWith(color: AppColors.black),
  //                   ),
  //                 ),
  //               ),
  //               IconButton(
  //                 icon: const Icon(Icons.delete_outline, color: Colors.black),
  //                 onPressed: () {
  //                   onDelete();
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class RefundTableCard extends StatelessWidget {
  const RefundTableCard({
    required this.context,
    required this.refundDetails,
    required this.invCod,
    required this.currency,
    required this.onDelete,
    super.key,
  });

  final BuildContext context;
  final RefundPaymentDetails refundDetails;
  final String invCod;
  final String currency;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.boxDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.date,
                    style: AppText.largeN.copyWith(color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.invoiceNumber,
                    style: AppText.largeN.copyWith(color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.amountCredited,
                    style: AppText.largeN.copyWith(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 48), // for delete icon space
            ],
          ),
          const SizedBox(height: 8),
          // Data Row
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      refundDetails.refundDate.toDateOnly,
                      // '01/01/2025',
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      invCod,
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$currency ${refundDetails.amountRefunded}',
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
