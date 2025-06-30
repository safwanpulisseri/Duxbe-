import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class SalesPaymentScreenWeb extends ConsumerStatefulWidget {
  const SalesPaymentScreenWeb({super.key});

  @override
  ConsumerState<SalesPaymentScreenWeb> createState() =>
      _SalesPaymentScreenWebState();
}

class _SalesPaymentScreenWebState extends ConsumerState<SalesPaymentScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();

  Column _dataRow({
    required String key,
    String? value,
    TextStyle? keyStyle,
    TextStyle? valueStyle,
  }) =>
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                key,
                style: keyStyle ??
                    AppText.xLargeM.copyWith(color: AppColors.stormyBlue),
              ),
              if (value != null)
                Text(
                  value,
                  style: valueStyle ??
                      AppText.xLargeSB.copyWith(color: AppColors.stormyBlue),
                ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      );

  FormFieldState<T> formValue<T>(String name) =>
      _formKey.currentState!.fields[name]! as FormFieldState<T>;

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final salesNotifier = ref.watch(salesNotifierProvider.notifier);
    final salesState = ref.watch(salesNotifierProvider);

    final inputDecoration = InputDecoration(
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      prefixIcon: Text(
        currency,
        style: AppText.heading3.copyWith(color: AppColors.stormyBlue),
      ),
    );

    List<DataRow> createRows(List<SaleItem> cartItems) {
      return cartItems.asMap().entries.map((entry) {
        final item = entry.value;
        return DataRow(
          cells: [
            DataCell(Text(item.item.name)),
            DataCell(Text(item.quantity.toString())),
            DataCell(
              Text(item.item.unit?.shortName ?? item.item.unit?.name ?? ''),
            ),
            DataCell(Text('$currency${item.unitPrice}')),
            DataCell(
              Text((item.quantity * item.unitPrice).toString()),
            ),
          ],
        );
      }).toList();
    }

    final orderMode = salesState.orderMode == false;
    return FormBuilder(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: AppStyles.boxDecoration.copyWith(boxShadow: []),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: DataTable(
                      dividerThickness: 0,
                      horizontalMargin: 2,
                      columns: [
                        DataColumn(label: Text(context.l10n.itemName)),
                        DataColumn(label: Text(context.l10n.quantity)),
                        DataColumn(label: Text(context.l10n.unit)),
                        DataColumn(label: Text(context.l10n.purchasePrice)),
                        DataColumn(label: Text(context.l10n.total)),
                      ],
                      rows: createRows(salesState.saleItems),
                      headingTextStyle:
                          AppText.largeM.copyWith(color: AppColors.stormyBlue),
                      dataTextStyle:
                          AppText.largeSB.copyWith(color: AppColors.stormyBlue),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.paymentMode,
                    style: AppText.mediumM.copyWith(color: AppColors.title),
                  ),
                  const SizedBox(height: 20),
                  FormBuilderField<PaymentMode>(
                    initialValue: PaymentMode.cash,
                    name: 'payment_mode',
                    builder: (paymentMode) {
                      return Row(
                        children: PaymentMode.values
                            .map(
                              (e) => Expanded(
                                child: AppButton(
                                  style: e == paymentMode.value
                                      ? ButtonStyles.primary
                                      : ButtonStyles.secondary,
                                  onPress: () {
                                    final paymentAmounts =
                                        formValue<Map<PaymentMode, String>>(
                                      'payment_details',
                                    ).value!;
                                    paymentMode.didChange(e);
                                    formValue<String>('amount').didChange(
                                      paymentAmounts[paymentMode.value!],
                                    );
                                  },
                                  label: Text(e.name.displayCase),
                                ),
                              ),
                            )
                            .toList(),
                      ).withSpacing(spacing: 10);
                    },
                  ),
                  const SizedBox(height: 10),
                  FormBuilderField<Map<PaymentMode, String>>(
                    // ignore: prefer_const_literals_to_create_immutables
                    initialValue: {
                      PaymentMode.cash: '',
                      PaymentMode.card: '',
                      PaymentMode.bank: '',
                    },
                    name: 'payment_details',
                    onChanged: (value) {
                      setState(() {});
                    },
                    builder: (paymentDetails) {
                      return Table(
                        border: TableBorder.all(color: AppColors.borderColor),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                          2: IntrinsicColumnWidth(),
                        },
                        children: PaymentMode.values
                            .where(
                              (e) =>
                                  paymentDetails.value![e]?.isNotEmpty ??
                                  false ||
                                      double.tryParse(
                                            paymentDetails.value![e].toString(),
                                          ) !=
                                          null,
                            )
                            .toList()
                            .map(
                              (e) => TableRow(
                                children: [
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        e.name.displayCase,
                                        style: AppText.largeM.copyWith(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '$currency ${paymentDetails.value![e]}',
                                        style: AppText.largeM.copyWith(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 22,
                                        color: AppColors.stormyBlue,
                                      ),
                                      onPressed: () {
                                        paymentDetails.didChange(
                                          paymentDetails.value!..remove(e),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  if (salesState.customer?.customerBalance != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.lightPurple,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${context.l10n.customerWallet} $currency ${salesState.customer?.customerBalance.toStringAsFixed(2)}',
                            style: AppText.mediumSB
                                .copyWith(color: AppColors.primaryColor),
                          ),
                          Expanded(
                            child: AppToggleForm(
                              initialValue: salesState.useWallet,
                              name: 'customer_wallet',
                              hint: context.l10n.useWallet,
                              onChanged: (val) {
                                salesNotifier.updateCustomerWallet(
                                  useWallet: val ?? false,
                                );
                              },
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textfield,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.enterAmountReceived,
                                style: AppText.mediumN
                                    .copyWith(color: AppColors.greyText),
                              ),
                              const SizedBox(height: 8),
                              AppTextForm<double>(
                                name: 'amount',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (value) {
                                  final paymentAmounts =
                                      formValue<Map<PaymentMode, String>>(
                                    'payment_details',
                                  ).value!;
                                  final currentPaymentMode =
                                      formValue<PaymentMode>('payment_mode')
                                          .value!;
                                  paymentAmounts[currentPaymentMode] =
                                      value?.toStringAsFixed(2) ?? '0.00';
                                  formValue<Map<PaymentMode, String>>(
                                    'payment_details',
                                  ).didChange(paymentAmounts);
                                },
                                inputFormatters: [CurrencyInputFormatter()],
                                decoration: inputDecoration,
                                style: AppText.heading3
                                    .copyWith(color: AppColors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textfield,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Builder(
                            builder: (context) {
                              final paymentAmounts =
                                  formValue<Map<PaymentMode, String>>(
                                'payment_details',
                              ).value!;

                              final totalPaid = paymentAmounts.values
                                  .fold<double>(0, (sum, amount) {
                                final value = double.tryParse(amount) ?? 0.0;
                                return sum + value;
                              });
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    salesState.grandTotal - totalPaid > 0
                                        ? context.l10n.due
                                        : context.l10n.balance,
                                    style: AppText.mediumN
                                        .copyWith(color: AppColors.greyText),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$currency ${(salesState.grandTotal - totalPaid).abs().toStringAsFixed(2)}',
                                    style: AppText.heading3
                                        .copyWith(color: AppColors.stormyBlue),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      TextFieldTapRegion(
                        child: Keypad(
                          onAmountEntered: (amount) {
                            final val = formValue<String>('amount').value ?? '';
                            final formattedVal = CurrencyInputFormatter()
                                .formatEditUpdate(
                                  TextEditingValue(text: val),
                                  TextEditingValue(text: val + amount),
                                )
                                .text;
                            formValue<String>('amount').didChange(formattedVal);
                            final paymentAmounts =
                                formValue<Map<PaymentMode, String>>(
                              'payment_details',
                            ).value!;
                            final currentPaymentMode =
                                formValue<PaymentMode>('payment_mode').value!;
                            paymentAmounts[currentPaymentMode] = formattedVal;
                            formValue<Map<PaymentMode, String>>(
                              'payment_details',
                            ).didChange(paymentAmounts);
                          },
                          child: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 10),
                                Expanded(
                                  child: AppButton(
                                    padding: const EdgeInsets.all(6),
                                    style: ButtonStyles.secondary,
                                    onPress: () {
                                      final val =
                                          formValue<String>('amount').value ??
                                              '';
                                      final formattedVal =
                                          CurrencyInputFormatter()
                                              .formatEditUpdate(
                                                TextEditingValue(text: val),
                                                TextEditingValue(
                                                  text: val.substring(
                                                    0,
                                                    val.length - 1,
                                                  ),
                                                ),
                                              )
                                              .text;
                                      formValue<String>('amount')
                                          .didChange(formattedVal);
                                      final paymentAmounts =
                                          formValue<Map<PaymentMode, String>>(
                                        'payment_details',
                                      ).value!;
                                      final currentPaymentMode =
                                          formValue<PaymentMode>('payment_mode')
                                              .value!;
                                      paymentAmounts[currentPaymentMode] =
                                          formattedVal;
                                      formValue<Map<PaymentMode, String>>(
                                        'payment_details',
                                      ).didChange(paymentAmounts);
                                    },
                                    label: Text(
                                      context.l10n.clear,
                                      style: AppText.xLargeB,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: AppButton(
                                    padding: const EdgeInsets.all(6),
                                    style: ButtonStyles.secondary,
                                    color: AppColors.red,
                                    onPress: () {
                                      formValue<String>('amount').didChange('');
                                      final paymentAmounts =
                                          formValue<Map<PaymentMode, String>>(
                                        'payment_details',
                                      ).value!;
                                      final currentPaymentMode =
                                          formValue<PaymentMode>('payment_mode')
                                              .value!;
                                      paymentAmounts[currentPaymentMode] = '';
                                      formValue<Map<PaymentMode, String>>(
                                        'payment_details',
                                      ).didChange(paymentAmounts);
                                    },
                                    label: Text(
                                      context.l10n.reset,
                                      style: AppText.xLargeB,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  flex: 2,
                                  child: AppButton(
                                    padding: const EdgeInsets.all(6),
                                    color: AppColors.red,
                                    onPress: () {
                                      Navigator.of(context).pop();
                                    },
                                    label: Text(
                                      context.l10n.cancel,
                                      style: AppText.xLargeB,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (orderMode) ...[
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          height: 2,
                          thickness: 1,
                          color: AppColors.miscellaneous,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsGeometry.symmetric(horizontal: 3),
                        child: Assets.icons.clipboard.svg(height: 15),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsGeometry.symmetric(horizontal: 3),
                        child: Text(context.l10n.orderDetails,style: AppText.mediumSB.copyWith(color: AppColors.miscellaneous),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ],
                  _dataRow(key: DateTime.now().toInvoiceFormat),
                  _dataRow(
                    key: '${context.l10n.customerName} : ',
                    value: salesState.customer?.name ??
                        context.l10n.walkInCustomer,
                  ),
                  _dataRow(
                    key: '${context.l10n.phoneNo} : ',
                    value: salesState.customer?.phone,
                  ),
                  const Divider(color: AppColors.borderColor),
                  _dataRow(
                    key: context.l10n.totalAmount,
                    keyStyle: AppText.heading4
                        .copyWith(color: AppColors.primaryColor),
                    value:
                        '$currency ${salesState.grandTotal.toStringAsFixed(2)}',
                    valueStyle: AppText.heading4
                        .copyWith(color: AppColors.primaryColor),
                  ),
                  _dataRow(
                    key: context.l10n.itemTotal,
                    value: salesState.saleItems.length.toString(),
                  ),
                  _dataRow(
                    key: context.l10n.subTotal,
                    value:
                        '$currency ${salesState.subtotal.toStringAsFixed(2)}',
                  ),
                  _dataRow(
                    key: context.l10n.serviceShipping,
                    value:
                        '$currency ${salesState.shipping.toStringAsFixed(2)}',
                  ),
                  _dataRow(
                    key: context.l10n.discount,
                    value:
                        '-$currency ${salesState.discountAmount.toStringAsFixed(2)}',
                  ),
                  _dataRow(
                    key: context.l10n.vatGst,
                    value:
                        '$currency ${salesState.taxTotal.toStringAsFixed(2)}',
                  ),
                  const Divider(color: AppColors.borderColor),
                  _dataRow(
                    key: context.l10n.grandTotal,
                    value:
                        '$currency ${salesState.grandTotal.toStringAsFixed(2)}',
                    valueStyle: AppText.heading5
                        .copyWith(color: AppColors.primaryColor),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) {
                      final paymentAmounts =
                          formValue<Map<PaymentMode, String>>('payment_details')
                              .value!;

                      final totalPaid =
                          paymentAmounts.values.fold<double>(0, (sum, amount) {
                        final value = double.tryParse(amount) ?? 0.0;
                        return sum + value;
                      });
                      return _dataRow(
                        key: salesState.grandTotal - totalPaid < 0
                            ? context.l10n.balance
                            : context.l10n.due,
                        keyStyle: AppText.heading5
                            .copyWith(color: AppColors.stormyBlue),
                        valueStyle: AppText.heading5
                            .copyWith(color: AppColors.stormyBlue),
                        value:
                            '$currency ${(salesState.grandTotal - totalPaid).abs().toStringAsFixed(2)}',
                      );
                    },
                  ),
                  AppButton(
                    isLoading: salesState.status == SalesStatus.loading,
                    color: AppColors.green,
                    onPress: () {
                      final paymentAmounts =
                          formValue<Map<PaymentMode, String>>('payment_details')
                              .value!;

                      final totalPaid =
                          paymentAmounts.values.fold<double>(0, (sum, amount) {
                        final value = double.tryParse(amount) ?? 0.0;
                        return sum + value;
                      });
                      final amount = double.tryParse(
                        formValue<String>('amount').value ?? '0',
                      );
                      // amount should be valid double value
                      // If customer is not null, amount should be greater than or equal to due amount
                      // If customer is null, amount should be greater than or equal to grand total
                      if (amount == null || amount < 0) {
                        Alert.showSnackBar(
                          context.l10n.invalidAmount,
                          type: SnackBarType.error,
                        );
                        return;
                      }
                      if (salesState.customer == null &&
                          salesState.grandTotal > totalPaid) {
                        Alert.showSnackBar(
                          context.l10n.walkInCustomerDueAmount,
                          type: SnackBarType.error,
                        );
                        return;
                      }
                      salesNotifier
                          .createSaleTransaction(
                        formValue<Map<PaymentMode, String>>('payment_details')
                            .value!,
                      )
                          .then(
                        (value) {
                          if (ref.read(businessNotifierProvider)!.printOnSale ??
                              false) {
                            PdfService.printSaleInvoice(value);
                          }
                          if (mounted) {
                            showDialog<void>(
                              // ignore: use_build_context_synchronously
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  SaleSuccessDialogue(sale: value),
                            );
                          }
                        },
                      );
                    },
                    label: Text(context.l10n.payment),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SaleSuccessDialogue extends ConsumerStatefulWidget {
  const SaleSuccessDialogue({required this.sale, super.key});
  final SaleView sale;

  @override
  ConsumerState<SaleSuccessDialogue> createState() =>
      _SuccessfulSaleDialogueBoxState();
}

class _SuccessfulSaleDialogueBoxState
    extends ConsumerState<SaleSuccessDialogue> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.paymentSuccessfull.image(),
            const SizedBox(height: 18),
            Text(
              context.l10n.paymentSuccessfull,
              style: AppText.heading5.copyWith(color: AppColors.green),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.paymentModePayments(
                widget.sale.payments
                    .map((e) => e.paymentMethod.name.displayCase)
                    .join(', '),
              ),
              style: AppText.heading5.copyWith(color: AppColors.stormyBlue),
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.invoiceNoNo(widget.sale.saleInvoice),
              style: AppText.xLargeM.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 10),
            Text(
              widget.sale.customer?.name ?? context.l10n.walkInCustomer,
              style: AppText.heading4.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TransactionSuccessfullCard(
                  count: widget.sale.totalAmount.toStringAsFixed(2),
                  heading: '${context.l10n.totalAmount}:',
                ),
                const SizedBox(width: 16),
                TransactionSuccessfullCard(
                  count: widget.sale.paidAmount.toStringAsFixed(2),
                  heading: '${context.l10n.paidAmount}:',
                ),
                const SizedBox(width: 16),
                TransactionSuccessfullCard(
                  heading: (widget.sale.dueAmount) > 0
                      ? context.l10n.due
                      : context.l10n.balance,
                  count:
                      '${(widget.sale.dueAmount) > 0 ? widget.sale.dueAmount : (widget.sale.totalAmount - widget.sale.paidAmount).abs().toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    style: ButtonStyles.secondary,
                    onPress: () {
                      PdfService.printSaleInvoice(widget.sale);
                    },
                    label: Text(context.l10n.printReceipt),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    onPress: () {
                      ref.read(salesNotifierProvider.notifier).resetForm();
                      context
                        ..pop()
                        ..goNamed(
                          AppRouter.pos,
                          queryParameters: {'clear': 'true'},
                        );
                    },
                    label: Text(context.l10n.nextSale),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionSuccessfullCard extends ConsumerWidget {
  const TransactionSuccessfullCard({
    required this.heading,
    required this.count,
    super.key,
  });
  final String heading;
  final String count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.textfield,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: AppText.mediumSB.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$currency$count',
              style: AppText.heading5.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
