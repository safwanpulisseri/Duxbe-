import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/invoice/presentation/quote_details/widgets/quote_details_card.dart';
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
import 'package:shimmer/shimmer.dart';

class QuoteDetailsScreenWeb extends ConsumerStatefulWidget {
  const QuoteDetailsScreenWeb({super.key});

  @override
  ConsumerState<QuoteDetailsScreenWeb> createState() => _QuoteDetailsScreenWebState();
}

class _QuoteDetailsScreenWebState extends ConsumerState<QuoteDetailsScreenWeb> {
  TextEditingController searchController = TextEditingController();
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final quoteState = ref.watch(quoteNotifierProvider);
    final business = ref.watch(businessNotifierProvider);
    final quoteNotifier = ref.watch(quoteNotifierProvider.notifier);
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
                          quoteNotifier.setFilter(query: v);
                        });
                        // Handle search input changes
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
                      context.pushNamed(AppRouter.createQuote);
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
                        pagingController: quoteState.quoteDetailsPagingController!,
                        builderDelegate: PagedChildBuilderDelegate<Quote>(
                          itemBuilder: (context, quote, index) => QuoteCard(
                            currency: business?.currency?.code ?? '',
                            customerName: quote.customerName ?? '',
                            quoteCode: quote.quoteCode ?? '',
                            createdAt: quote.createdAt?.toLocal() ?? DateTime.now(),
                            quoteStatus: quote.quoteStatus?.name ?? QuoteFormStatus.draft.name,
                            grandTotal: quote.grandTotal ?? 0,
                            onTap: () {
                              quoteNotifier.setFilter(
                                selectedQuoteId: quote.quoteId.toString(),
                              );
                            },
                            isSelected: quote.quoteId == quoteState.selectedQuoteId,
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
                  ref.watch(quoteProvider(quoteState.selectedQuoteId)).when(
                        data: (quote) => Expanded(
                          flex: 2,
                          child: quote != null
                              ? Column(
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
                                                onPressed: () async {
                                                  await PdfService.printQuotePdf(
                                                    quoteNumber: quote.quoteCode ?? '',
                                                    quoteDate: DateFormat(
                                                      'dd MMM yyyy',
                                                    ).format(
                                                      quote.createdAt?.toLocal() ?? DateTime.now(),
                                                    ),
                                                    expiryDate: DateFormat(
                                                      'dd MMM yyyy',
                                                    ).format(
                                                      quote.validUntilDate?.toLocal() ?? DateTime.now(),
                                                    ),
                                                    customerName: quote.customerName ?? '',
                                                    customerAddress:
                                                        '${quote.billingAddressDetails?.address ?? ''}, \n${quote.billingAddressDetails?.city ?? ''}, ${quote.billingAddressDetails?.state ?? ''} \n${quote.billingAddressDetails?.zipcode ?? ''}, ${quote.billingAddressDetails?.country ?? ''}',
                                                    items: quote.quoteItems
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
                                                    subtotal: quote.subTotal ?? 0,
                                                    cgst: quote.taxTotal ?? 0,
                                                    sgst: quote.taxTotal ?? 0,
                                                    total: quote.grandTotal ?? 0,
                                                    totalInWords: AmountToWordsConverter.convertToWordsOnly(
                                                      quote.grandTotal ?? 0,
                                                    ),
                                                    note: quote.quoteNotes ?? '',
                                                    termsAndConditions: quote.quoteTermsAndConditions ?? '',
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
                                                    AppRouter.editQuote,
                                                    pathParameters: {
                                                      'id': quote.quoteId!,
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
                                                                quoteNotifierProvider,
                                                              )
                                                              .status ==
                                                          QuoteStatus.loading,
                                                      onPositive: (ref) {
                                                        ref
                                                            .read(
                                                              quoteNotifierProvider.notifier,
                                                            )
                                                            .changeQuoteStatus(
                                                              quote.quoteId!,
                                                              QuoteFormStatus.deleted,
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
                                          if (quote.quoteStatus?.name != 'sent') const SizedBox(width: 10),
                                          if (quote.quoteStatus?.name != 'sent')
                                            AppButton(
                                              style: ButtonStyles.secondary,
                                              color: AppColors.primaryColor,
                                              onPress: () {
                                                quoteNotifier.changeQuoteStatus(
                                                  quote.quoteId!,
                                                  QuoteFormStatus.sent,
                                                );
                                              },
                                              label: Text(context.l10n.markAsSent),
                                            ),
                                          const SizedBox(width: 10),
                                          AppButton(
                                            style: ButtonStyles.secondary,
                                            color: AppColors.brandViolet,
                                            onPress: () {
                                              final invoice = {
                                                'quote_id': quote.quoteId,
                                                'invoice_date': quote.createdAt?.toLocal().toString(),
                                                'due_date': quote.validUntilDate?.toLocal().toString(),
                                                'status': QuoteFormStatus.draft.name,
                                                'notes': '',
                                              };
                                              quoteNotifier.recordPayment(invoice);
                                            },
                                            label: Text(
                                              context.l10n.convertToInvoice,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Make InvoiceDetailsCard scrollable inside available space
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: QuoteDetailsCard(
                                          
                                          currencyCode: business?.currency?.code ?? '',
                                          type: InvoiceType.quote,
                                          invoiceNumber: quote.quoteCode ?? '',
                                          quoteDate: DateFormat('dd MMM yyyy').format(
                                            quote.createdAt?.toLocal() ?? DateTime.now(),
                                          ),
                                          expiryDate: DateFormat('dd MMM yyyy').format(
                                            quote.validUntilDate?.toLocal() ?? DateTime.now(),
                                          ),
                                          customerName: quote.customerName ?? '',
                                          customerAddress:
                                              '${quote.billingAddressDetails?.address ?? ''}, \n${quote.billingAddressDetails?.city ?? ''}, ${quote.billingAddressDetails?.state ?? ''} \n${quote.billingAddressDetails?.zipcode ?? ''}, ${quote.billingAddressDetails?.country ?? ''}',
                                          items: quote.quoteItems
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
                                          subtotal: quote.subTotal ?? 0,
                                          cgst: quote.taxTotal ?? 0,
                                          sgst: quote.taxTotal ?? 0,
                                          total: quote.grandTotal ?? 0,
                                          totalInWords: AmountToWordsConverter.convertToWordsOnly(
                                            quote.grandTotal ?? 0,
                                          ),
                                          note: quote.quoteNotes ?? '',
                                          termsAndConditions: quote.quoteTermsAndConditions ?? '',
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

class BuildShimmerCard extends StatelessWidget {
  const BuildShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerHeader(),
            const SizedBox(height: 24),
            _buildShimmerDateSection(),
            const SizedBox(height: 24),
            _buildShimmerCustomerAndItemsSection(),
            const SizedBox(height: 18),
            _buildShimmerNoteAndTerms(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                height: 24,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: 150,
                height: 20,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: 180,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: 140,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: 160,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 120,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerDateSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCustomerAndItemsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 16,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Container(
            width: 150,
            height: 20,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 16,
            color: Colors.white,
          ),
          const SizedBox(height: 24),
          _buildShimmerItemsTable(),
          const SizedBox(height: 24),
          const Divider(
            color: Color(0xFFE0E0E0),
            height: 1,
          ),
          const SizedBox(height: 24),
          _buildShimmerTotalsSection(),
        ],
      ),
    );
  }

  Widget _buildShimmerItemsTable() {
    return Column(
      children: [
        Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Container(
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: List.generate(
                6,
                (index) => Expanded(
                  child: Container(
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerTotalsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: 120,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 160,
              height: 16,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerNoteAndTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 16,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 16,
          color: Colors.white,
        ),
        const SizedBox(height: 24),
        Container(
          width: 120,
          height: 16,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 16,
          color: Colors.white,
        ),
      ],
    );
  }
}
