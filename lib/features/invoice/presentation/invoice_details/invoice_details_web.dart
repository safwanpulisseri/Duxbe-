import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/invoice/presentation/widgets/invoice_details_card.dart';
import 'package:duxbe/features/invoice/presentation/widgets/quote_card.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class InvoiceDetailsScreenWeb extends ConsumerStatefulWidget {
  const InvoiceDetailsScreenWeb({super.key});

  @override
  ConsumerState<InvoiceDetailsScreenWeb> createState() => _InvoiceDetailsScreenWebState();
}

class _InvoiceDetailsScreenWebState extends ConsumerState<InvoiceDetailsScreenWeb> {
  TextEditingController searchController = TextEditingController();
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceNotifierProvider);
    final business = ref.watch(businessNotifierProvider);
    final invoiceNotifier = ref.watch(invoiceNotifierProvider.notifier);

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
                          invoiceNotifier.setFilter(query: v);
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
                      context.pushNamed(AppRouter.createInvoice);
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
                        pagingController: invoiceState.invoiceDetailsPagingController!,
                        builderDelegate: PagedChildBuilderDelegate<Invoice>(
                          itemBuilder: (context, invoice, index) => InvoiceCard(
                            status: invoice.status ?? InvoiceFormStatus.draft,
                            currency: business?.currency?.code ?? '',
                            customerName: invoice.customer?.name ?? '',
                            invoiceCode: invoice.invoiceCode ?? '',
                            createdAt: invoice.createdAt?.toLocal() ?? DateTime.now(),
                            invoiceStatus: invoice.status?.name ?? '',
                            grandTotal: invoice.amount ?? 0,
                            onTap: () {
                              invoiceNotifier.setFilter(
                                selectedInvoiceId: invoice.invoiceId.toString(),
                              );
                            },
                            isSelected: invoice.invoiceId == invoiceState.selectedInvoiceId,
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
                        invoiceDataProvider(invoiceState.selectedInvoiceId),
                      )
                      .when(
                        data: (invoice) => Expanded(
                          flex: 2,
                          child: invoice != null
                              ? Column(
                                  children: [
                                    InvoiceHeader(invoice: invoice),
                                    const SizedBox(height: 10),
                                    // Make InvoiceDetailsCard scrollable inside available space
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: InvoiceDetailsCard(
                                          currencyCode: business?.currency?.code ?? '',
                                          balanceDue: invoice.balanceDue ?? 0,
                                          status: invoice.status ?? InvoiceFormStatus.draft,
                                          invoiceNumber: invoice.invoiceCode ?? '',
                                          quoteDate: invoice.createdAt?.toLocal().toString() ?? '',
                                          expiryDate: invoice.dueDate?.toLocal().toString() ?? '',
                                          customerName: invoice.customer?.name ?? '',
                                          customerAddress:
                                              '${invoice.billingAddress?.address ?? ''}, \n${invoice.billingAddress?.city ?? ''}, ${invoice.billingAddress?.state ?? ''} \n${invoice.billingAddress?.zipcode ?? ''}, ${invoice.billingAddress?.country ?? ''}',
                                          subtotal: invoice.subTotal ?? 0,
                                          cgst: invoice.taxTotal ?? 0,
                                          sgst: invoice.taxTotal ?? 0,
                                          total: invoice.amount ?? 0,
                                          totalInWords: AmountToWordsConverter.convertToWordsOnly(
                                            invoice.amount ?? 0,
                                          ),
                                          note: invoice.notes ?? '',
                                          termsAndConditions: invoice.termsAndConditions ?? '',
                                          items: invoice.invoiceItems
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
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Expanded(
                                  flex: 2,
                                  child: NoDataViewWidget(),
                                ),
                        ),
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
}

class InvoiceHeader extends ConsumerWidget {
  const InvoiceHeader({
    required this.invoice,
    super.key,
  });
  final Invoice invoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceNotifier = ref.watch(invoiceNotifierProvider.notifier);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceCode ?? '',
                    style: AppText.largeSB,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overdue by ${invoice.dueDate?.difference(invoice.createdAt?.toLocal() ?? DateTime.now()).inDays ?? 0} days',
                    style: AppText.mediumN.copyWith(color: AppColors.stormyBlue),
                  ),
                ],
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
                        await PdfService.printInvoicePdf(
                          balanceDue: invoice.balanceDue ?? 0,
                          status: invoice.status ?? InvoiceFormStatus.draft,
                          invoiceNumber: invoice.invoiceCode ?? '',
                          invoiceDate: DateFormat(
                            'dd MMM yyyy',
                          ).format(
                            invoice.createdAt?.toLocal() ?? DateTime.now(),
                          ),
                          dueDate: DateFormat(
                            'dd MMM yyyy',
                          ).format(
                            invoice.dueDate?.toLocal() ?? DateTime.now(),
                          ),
                          customerName: invoice.customer?.name ?? '',
                          customerAddress:
                              '${invoice.billingAddress?.address ?? ''}, \n${invoice.billingAddress?.city ?? ''}, ${invoice.billingAddress?.state ?? ''} \n${invoice.billingAddress?.zipcode ?? ''}, ${invoice.billingAddress?.country ?? ''}',
                          items: invoice.invoiceItems
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
                          subtotal: invoice.subTotal ?? 0,
                          cgst: invoice.taxTotal ?? 0,
                          sgst: invoice.taxTotal ?? 0,
                          total: invoice.amount ?? 0,
                          totalInWords: AmountToWordsConverter.convertToWordsOnly(
                            invoice.amount ?? 0,
                          ),
                          note: invoice.notes ?? '',
                          termsAndConditions: invoice.termsAndConditions ?? '',
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
                      onPressed: () {
                        context.pushNamed(
                          AppRouter.editInvoice,
                          pathParameters: {
                            'id': invoice.invoiceId!,
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
                                      invoiceNotifierProvider,
                                    )
                                    .status ==
                                InvoiceStatus.loading,
                            onPositive: (ref) {
                              ref
                                  .read(
                                    invoiceNotifierProvider.notifier,
                                  )
                                  .deleteInvoice(
                                    invoiceId: invoice.invoiceId!,
                                  );
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
                if (invoice.status?.name == 'draft') const SizedBox(width: 10),
                if (invoice.status?.name == 'draft')
                  AppButton(
                    style: ButtonStyles.secondary,
                    color: AppColors.primaryColor,
                    onPress: () {
                      invoiceNotifier.updateInvoiceStatus(
                        invoiceId: invoice.invoiceId!,
                        status: InvoiceFormStatus.sent.name,
                      );
                    },
                    label: Text(context.l10n.markAsSent),
                  ),
                const SizedBox(width: 10),
                AppButton(
                  style: ButtonStyles.secondary,
                  onPress: () async {
                    // final paymentData = {
                    //     'business_id': ref
                    //         .read(businessNotifierProvider)!
                    //         .businessId, // This should come from your business context
                    //     'customer_id': invoice.customer?.customerId,
                    //     'amount_received': invoice.amount,
                    //     'payment_date':
                    //         invoice.createdAt?.toIso8601String()
                    //             .split('T')[0],
                    //     'payment_mode': PaymentMode.cash.name,
                    //     'deposited_to': 'Petty cash',
                    //     'reference_number':
                    //         invoice.invoiceCode?.toString(),
                    //     'notes': invoice.notes?.toString(),
                    //   };
                    //   await ref
                    //         .read(
                    //           paymentReceivedNotifierProvider.notifier,
                    //         )
                    //         .createPayment(paymentReceived: paymentData);
                    await context.pushNamed(
                      AppRouter.createPaymentFromInvoice,
                      pathParameters: {
                        'id': invoice.invoiceId!,
                      },
                    );
                  },
                  label: Text(context.l10n.recordPayment),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
