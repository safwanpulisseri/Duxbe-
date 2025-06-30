import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/invoice/presentation/payment_refund/widget/payment_recipt.dart';
import 'package:duxbe/features/invoice/presentation/widgets/quote_card.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class PaymentReceivedScreenWeb extends ConsumerStatefulWidget {
  const PaymentReceivedScreenWeb({super.key});

  @override
  ConsumerState<PaymentReceivedScreenWeb> createState() => _PaymentReceivedScreenWebState();
}

class _PaymentReceivedScreenWebState extends ConsumerState<PaymentReceivedScreenWeb> {
  TextEditingController searchController = TextEditingController();
  final debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final paymentReceivedState = ref.watch(paymentReceivedNotifierProvider);
    final paymentReceivedNotifier = ref.watch(paymentReceivedNotifierProvider.notifier);
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
                          paymentReceivedNotifier.setFilter(query: v);
                        });
                      },
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  // const SizedBox(width: 10),
                  // AppButton.icon(
                  //   color: AppColors.primaryColor,
                  //   icon: const Icon(Icons.add),
                  //   onPress: () {
                  //     context.goNamed(AppRouter.paymentRefund);
                  //   },
                  //   label: Text(AppRouter.l10n.create),
                  // ),
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
                        pagingController: paymentReceivedState.paymentReceivedPagingController!,
                        builderDelegate: PagedChildBuilderDelegate<PaymentReceived>(
                          itemBuilder: (context, quote, index) => QuoteCard(
                            currency: business?.currency?.code ?? '',
                            customerName: quote.customer?.name ?? '',
                            quoteCode: quote.paymentCode ?? '',
                            createdAt: quote.paymentDate?.toLocal() ?? DateTime.now(),
                            quoteStatus: quote.paymentStatus?.name ?? '',
                            grandTotal: quote.amountReceived ?? 0,
                            onTap: () {
                              ref.read(paymentReceivedNotifierProvider.notifier).setFilter(
                                    selectedPaymentReceivedId: quote.paymentId.toString(),
                                  );
                            },
                            isSelected: quote.paymentId == paymentReceivedState.selectedPaymentReceivedId,
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
                        paymentReceivedProvider(paymentReceivedState.selectedPaymentReceivedId),
                      )
                      .when(
                        data: (paymentReceived) {
                          return Expanded(
                            flex: 2,
                            child: paymentReceived != null
                                ? Column(
                                    children: [
                                      _paymentRefund(paymentReceived: paymentReceived),
                                      ...paymentReceived.refundDetails.map(
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
                                                        paymentReceivedNotifierProvider.notifier,
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
                                          invCod: paymentReceived.invoiceDetails?.invoiceCode ?? '',
                                          currency: business?.currency?.code ?? '',
                                          refundDetails: e,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: PaymentRecipt(paymentReceived: paymentReceived),
                                        ),
                                      ),
                                    ],
                                  )
                                : const NoDataViewWidget(),
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

  Widget _paymentRefund({required PaymentReceived paymentReceived}) {
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
                paymentReceived.paymentCode ?? '',
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
                    // MenuItemButton(
                    //   leadingIcon: const Icon(
                    //     Icons.print,
                    //     color: AppColors.primaryColor,
                    //   ),
                    //   style: MenuItemButton.styleFrom(
                    //     foregroundColor: AppColors.primaryColor,
                    //   ),
                    //   onPressed: () async {
                    //     // await PdfService.printInvoicePdf(
                    //     //   balanceDue: invoice.balanceDue ?? 0,
                    //     //   status: invoice.status ?? InvoiceFormStatus.draft,
                    //     //   invoiceNumber: invoice.invoiceCode ?? '',
                    //     //   invoiceDate: DateFormat(
                    //     //     'dd MMM yyyy',
                    //     //   ).format(
                    //     //     invoice.createdAt?.toLocal() ?? DateTime.now(),
                    //     //   ),
                    //     //   dueDate: DateFormat(
                    //     //     'dd MMM yyyy',
                    //     //   ).format(
                    //     //     invoice.dueDate?.toLocal() ?? DateTime.now(),
                    //     //   ),
                    //     //   customerName: invoice.customer?.name ?? '',
                    //     //   customerAddress:
                    //     //       '${invoice.billingAddress?.address ?? ''}, \n${invoice.billingAddress?.city ?? ''}, ${invoice.billingAddress?.state ?? ''} \n${invoice.billingAddress?.zipcode ?? ''}, ${invoice.billingAddress?.country ?? ''}',
                    //     //   items: invoice.invoiceItems
                    //     //       .map(
                    //     //         (e) => InvoiceItem(
                    //     //           description: e.item?.name ?? '',
                    //     //           subDescription:
                    //     //               e.item?.itemCategory?.name ?? '',
                    //     //           quantity: e.quantity?.toDouble() ?? 0,
                    //     //           rate: e.unitPrice ?? 0,
                    //     //           tax: 0,
                    //     //           amount: e.totalPrice ?? 0,
                    //     //         ),
                    //     //       )
                    //     //       .toList(),
                    //     //   subtotal: invoice.subTotal ?? 0,
                    //     //   cgst: invoice.taxTotal ?? 0,
                    //     //   sgst: invoice.taxTotal ?? 0,
                    //     //   total: invoice.amount ?? 0,
                    //     //   totalInWords:
                    //     //       AmountToWordsConverter.convertToWordsOnly(
                    //     //     invoice.amount ?? 0,
                    //     //   ),
                    //     //   note: invoice.notes ?? '',
                    //     //   termsAndConditions:
                    //     //       invoice.termsAndConditions ?? '',
                    //     // );
                    //   },
                    //   child: Text(context.l10n.print),
                    // ),

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
                          AppRouter.editPayment,
                          pathParameters: {
                            'id': paymentReceived.paymentId!,
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
                              ref
                                  .read(paymentReceivedNotifierProvider.notifier)
                                  .deletePaymment(paymentReceived.paymentId!);
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
                if (paymentReceived.paymentStatus != PaymentReceivedDataStatus.paid)
                  AppButton.icon(
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
                    onPress: () async {
                      await PdfService.printPaymentReceiptPdf(
                        receivedFrom: paymentReceived.customer?.name ?? '',
                        receiptNumber: '1233321',
                        referenceNumber: paymentReceived.referenceNumber ?? '',
                        paymentMode: paymentReceived.paymentMode?.name.displayCase ?? '',
                        paymentDate: DateFormat(
                          'dd MMM yyyy',
                        ).format(
                          paymentReceived.paymentDate?.toLocal() ?? DateTime.now(),
                        ),
                        amountReceived: paymentReceived.amountReceived ?? 0,
                        amountInWords: AmountToWordsConverter.convertToWordsOnly(
                          paymentReceived.amountReceived ?? 0,
                        ),
                      );
                    },
                    label: Text('${context.l10n.pdf} / ${context.l10n.print}'),
                  ),
                const SizedBox(width: 10),
                AppButton(
                  style: ButtonStyles.secondary,
                  onPress: () {
                    context
                        .goNamed(AppRouter.paymentRefund, pathParameters: {'id': paymentReceived.paymentId.toString()});
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
}
