import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PurchasePaymentScreenWeb extends ConsumerStatefulWidget {
  const PurchasePaymentScreenWeb({super.key});

  @override
  ConsumerState<PurchasePaymentScreenWeb> createState() => _PurchasePaymentScreenWebState();
}

class _PurchasePaymentScreenWebState extends ConsumerState<PurchasePaymentScreenWeb> {
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
                style: keyStyle ?? AppText.xLargeM.copyWith(color: AppColors.stormyBlue),
              ),
              if (value != null)
                Text(
                  value,
                  style: valueStyle ?? AppText.xLargeSB.copyWith(color: AppColors.stormyBlue),
                ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      );

  FormFieldState<T> formValue<T>(String name) => _formKey.currentState!.fields[name]! as FormFieldState<T>;

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final purchaseNotifier = ref.watch(purchaseNotifierProvider.notifier);
    final purchaseState = ref.watch(purchaseNotifierProvider);

    final inputDecoration = InputDecoration(
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      prefixIcon: Text(
        currency,
        style: AppText.heading3.copyWith(color: AppColors.stormyBlue),
      ),
    );

    List<DataRow> createRows(List<PurchaseItem> cartItems) {
      return cartItems.asMap().entries.map((entry) {
        final item = entry.value;
        return DataRow(
          cells: [
            DataCell(Text(item.item.name)),
            DataCell(Text(item.quantity.toString())),
            DataCell(Text(item.item.unit?.shortName ?? item.item.unit?.name ?? '')),
            DataCell(Text('$currency${item.unitPrice}')),
            DataCell(
              Text((item.quantity * item.unitPrice).toString()),
            ),
          ],
        );
      }).toList();
    }

    return FormBuilder(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _dataRow(key: DateTime.now().toInvoiceFormat),
                  _dataRow(
                    key: '${context.l10n.supplierName} : ',
                    value: purchaseState.supplier?.name,
                  ),
                  _dataRow(
                    key: context.l10n.phoneNo,
                    value: purchaseState.supplier?.phone,
                  ),
                  const Divider(color: AppColors.borderColor, height: 10),
                  Expanded(
                    child: SingleChildScrollView(
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
                        rows: createRows(purchaseState.purchaseItems),
                        headingTextStyle: AppText.largeM.copyWith(color: AppColors.stormyBlue),
                        dataTextStyle: AppText.largeSB.copyWith(color: AppColors.stormyBlue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 26),
                  _dataRow(
                    key: context.l10n.itemTotal,
                    value: purchaseState.purchaseItems.length.toString(),
                  ),
                  _dataRow(
                    key: context.l10n.subTotal,
                    value: '$currency ${purchaseState.subtotal.toStringAsFixed(2)}',
                  ),
                  _dataRow(
                    key: context.l10n.serviceShipping,
                    value: '$currency ${purchaseState.shipping.toStringAsFixed(2)}',
                  ),
                  _dataRow(
                    key: context.l10n.discount,
                    value: '-$currency ${purchaseState.discountAmount.toStringAsFixed(2)}',
                  ),
                  const Divider(color: AppColors.borderColor, height: 32),
                  _dataRow(
                    key: context.l10n.grandTotal,
                    value: '$currency ${purchaseState.grandTotal}',
                    valueStyle: AppText.heading5.copyWith(color: AppColors.primaryColor),
                  ),
                  AppButton(
                    color: AppColors.green,
                    onPress: () {
                      _formKey.currentState?.save();
                      purchaseNotifier
                          .updatePaymentDetails(formValue<Map<PaymentMode, String>>('payment_details').value!);
                      purchaseNotifier.createPurchaseTransaction().then(
                        (value) {
                          if (mounted) {
                            showDialog<void>(
                              // ignore: use_build_context_synchronously
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => PurchaseSuccessDialogue(purchase: value),
                            );
                          }
                        },
                      );
                    },
                    label: Text(context.l10n.payment),
                    isLoading: purchaseState.status == PurchaseStatus.loading,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: AppStyles.boxDecoration.copyWith(boxShadow: []),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                                  style: e == paymentMode.value ? ButtonStyles.primary : ButtonStyles.secondary,
                                  onPress: () {
                                    final paymentAmounts =
                                        formValue<Map<PaymentMode, String>>('payment_details').value!;
                                    paymentMode.didChange(e);
                                    formValue<String>('amount').didChange(paymentAmounts[paymentMode.value!]);
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
                        },
                        children: PaymentMode.values
                            .where(
                              (e) =>
                                  paymentDetails.value?[e]?.isNotEmpty ??
                                  false || double.tryParse(paymentDetails.value![e].toString()) != null,
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
                                        style: AppText.largeM.copyWith(color: AppColors.stormyBlue),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '$currency ${paymentDetails.value![e]}',
                                        style: AppText.largeM.copyWith(color: AppColors.stormyBlue),
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
                                        paymentDetails.didChange(paymentDetails.value!..remove(e));
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
                  const Spacer(),
                  _dataRow(
                    key: context.l10n.totalAmountCurrencyPurchasepagedataGrandtotal(
                      currency,
                      purchaseState.grandTotal.toStringAsFixed(2),
                    ),
                    keyStyle: AppText.heading4.copyWith(color: AppColors.primaryColor),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.lightPurple),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${context.l10n.supplierWallet} $currency ${purchaseState.supplier?.supplierBalance.toStringAsFixed(2) ?? 0}',
                          style: AppText.mediumSB.copyWith(color: AppColors.primaryColor),
                        ),
                        Expanded(
                          child: AppToggleForm(
                            name: 'supplier_wallet',
                            hint: context.l10n.useWallet,
                            initialValue: purchaseState.useWallet,
                            onChanged: (val) {
                              purchaseNotifier.updateSupplierWallet(useWallet: val ?? false);
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
                                style: AppText.mediumN.copyWith(color: AppColors.greyText),
                              ),
                              const SizedBox(height: 8),
                              AppTextForm<double>(
                                name: 'amount',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [CurrencyInputFormatter()],
                                decoration: inputDecoration,
                                style: AppText.heading3.copyWith(color: AppColors.black),
                                onChanged: (value) {
                                  final paymentAmounts = formValue<Map<PaymentMode, String>>('payment_details').value!;
                                  final currentPaymentMode = formValue<PaymentMode>('payment_mode').value!;
                                  paymentAmounts[currentPaymentMode] = value?.toStringAsFixed(2) ?? '0.00';
                                  formValue<Map<PaymentMode, String>>('payment_details').didChange(paymentAmounts);
                                },
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
                              final paymentAmounts = formValue<Map<PaymentMode, String>>('payment_details').value!;

                              final totalPaid = paymentAmounts.values.fold<double>(0, (sum, amount) {
                                final value = double.tryParse(amount) ?? 0.0;
                                return sum + value;
                              });
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    purchaseState.grandTotal - totalPaid > 0 ? context.l10n.balance : context.l10n.due,
                                    style: AppText.mediumN.copyWith(color: AppColors.greyText),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$currency ${(purchaseState.grandTotal - totalPaid).abs().toStringAsFixed(2)}',
                                    style: AppText.heading3.copyWith(color: AppColors.stormyBlue),
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
                            final paymentAmounts = formValue<Map<PaymentMode, String>>('payment_details').value!;
                            final currentPaymentMode = formValue<PaymentMode>('payment_mode').value!;
                            paymentAmounts[currentPaymentMode] = formattedVal;
                            formValue<Map<PaymentMode, String>>('payment_details').didChange(paymentAmounts);
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
                                      final val = formValue<String>('amount').value ?? '';
                                      final formattedVal = CurrencyInputFormatter()
                                          .formatEditUpdate(
                                            TextEditingValue(text: val),
                                            TextEditingValue(text: val.substring(0, val.length - 1)),
                                          )
                                          .text;
                                      formValue<String>('amount').didChange(formattedVal);
                                      final paymentAmounts =
                                          formValue<Map<PaymentMode, String>>('payment_details').value!;
                                      final currentPaymentMode = formValue<PaymentMode>('payment_mode').value!;
                                      paymentAmounts[currentPaymentMode] = formattedVal;
                                      formValue<Map<PaymentMode, String>>('payment_details').didChange(paymentAmounts);
                                    },
                                    label: Text(context.l10n.clear, style: AppText.xLargeB),
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
                                          formValue<Map<PaymentMode, String>>('payment_details').value!;
                                      final currentPaymentMode = formValue<PaymentMode>('payment_mode').value!;
                                      paymentAmounts[currentPaymentMode] = '';
                                      formValue<Map<PaymentMode, String>>('payment_details').didChange(paymentAmounts);
                                    },
                                    label: Text(context.l10n.reset, style: AppText.xLargeB),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  flex: 2,
                                  child: AppButton(
                                    padding: const EdgeInsets.all(6),
                                    color: AppColors.red,
                                    onPress: () {
                                      context.pop();
                                    },
                                    label: Text(context.l10n.cancel, style: AppText.xLargeB),
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
        ],
      ),
    );
  }
}

class PurchaseSuccessDialogue extends ConsumerStatefulWidget {
  const PurchaseSuccessDialogue({required this.purchase, super.key});
  final PurchaseView purchase;

  @override
  ConsumerState<PurchaseSuccessDialogue> createState() => _SuccessfulPurchaseDialogueBoxState();
}

class _SuccessfulPurchaseDialogueBoxState extends ConsumerState<PurchaseSuccessDialogue> {
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
                widget.purchase.payments.map((e) => e.paymentMethod.name.displayCase).join(', '),
              ),
              style: AppText.heading5.copyWith(color: AppColors.stormyBlue),
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.invoiceNoNo(widget.purchase.purchaseInvoice),
              style: AppText.xLargeM.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 10),
            Text(
              widget.purchase.supplier.name,
              style: AppText.heading4.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TransactionSuccessfullCard(
                  count: '${widget.purchase.totalAmount}',
                  heading: '${context.l10n.totalAmount}:',
                ),
                const SizedBox(width: 16),
                TransactionSuccessfullCard(
                  count: '${widget.purchase.paidAmount}',
                  heading: '${context.l10n.paidAmount}:',
                ),
                const SizedBox(width: 16),
                TransactionSuccessfullCard(
                  heading: (widget.purchase.dueAmount) > 0 ? context.l10n.due : context.l10n.balance,
                  count:
                      '${(widget.purchase.dueAmount) > 0 ? widget.purchase.dueAmount : widget.purchase.totalAmount - widget.purchase.paidAmount}',
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
                      PdfService.printPurchaseInvoice(widget.purchase);
                    },
                    label: Text(context.l10n.printReceipt),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    onPress: () {
                      FormBuilder.of(context)?.reset();
                      ref.read(purchaseNotifierProvider.notifier).resetForm();
                      context
                        ..pop()
                        ..pop()
                        ..pushReplacementNamed(AppRouter.purchasing, queryParameters: {'clear': 'true'});
                    },
                    label: Text(context.l10n.nextPurchase),
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
