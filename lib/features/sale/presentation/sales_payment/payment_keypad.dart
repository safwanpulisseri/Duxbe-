part of 'sales_payment_mobile.dart';

class SalesKeypadScreen extends ConsumerStatefulWidget {
  const SalesKeypadScreen({super.key});

  @override
  ConsumerState<SalesKeypadScreen> createState() => _SalesKeypadScreenState();
}

class _SalesKeypadScreenState extends ConsumerState<SalesKeypadScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  FormFieldState<T> formValue<T>(String name) => _formKey.currentState!.fields[name]! as FormFieldState<T>;

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final cartState = ref.watch(salesNotifierProvider);
    final cartNotifier = ref.read(salesNotifierProvider.notifier);

    return Scaffold(
      extendBody: true,
      appBar: CustomAppBar(title: Text(context.l10n.paymentMethod)),
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(color: Colors.black12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.totalBill),
                  Text(
                    '$currency ${cartState.grandTotal}',
                    style: AppText.heading5.copyWith(color: AppColors.green),
                  ),
                ],
              ),
              const Divider(color: Colors.black12),
              const SizedBox(width: 10),
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
                                final paymentAmounts = formValue<Map<PaymentMode, String>>('payment_details').value!;
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
              Expanded(
                child: FormBuilderField<Map<PaymentMode, String>>(
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
              ),
              if (cartState.customer != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.lightPurple),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${context.l10n.customerWallet} $currency ${cartState.customer!.customerBalance.toStringAsFixed(2)}',
                        style: AppText.mediumSB.copyWith(color: AppColors.primaryColor),
                      ),
                      Expanded(
                        child: AppToggleForm(
                          initialValue: cartState.useWallet,
                          name: 'customer_wallet',
                          hint: context.l10n.useWallet,
                          onChanged: (val) {
                            cartNotifier.updateCustomerWallet(useWallet: val ?? false);
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textfield,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.amountReceived,
                            style: AppText.mediumN.copyWith(color: AppColors.greyText),
                          ),
                          const SizedBox(height: 8),
                          AppTextForm<double>(
                            name: 'amount',
                            keyboardType: TextInputType.none,
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: true,
                              fillColor: AppColors.textfield,
                              prefixIconConstraints: const BoxConstraints(),
                              isDense: true,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.zero,
                              prefixIcon: Text(
                                '$currency ',
                                style: AppText.heading5.copyWith(color: AppColors.stormyBlue),
                              ),
                            ),
                            style: AppText.xLargeB.copyWith(color: AppColors.black),
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
                        horizontal: 12,
                        vertical: 12,
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
                                cartState.grandTotal - totalPaid > 0 ? context.l10n.balance : context.l10n.due,
                                style: AppText.mediumN.copyWith(color: AppColors.greyText),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$currency ${(cartState.grandTotal - totalPaid).abs().toStringAsFixed(2)}',
                                style: AppText.xLargeB.copyWith(color: AppColors.stormyBlue),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 260,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: TextFieldTapRegion(
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
                                  final paymentAmounts = formValue<Map<PaymentMode, String>>('payment_details').value!;
                                  final currentPaymentMode = formValue<PaymentMode>('payment_mode').value!;
                                  paymentAmounts[currentPaymentMode] = formattedVal;
                                  formValue<Map<PaymentMode, String>>('payment_details').didChange(paymentAmounts);
                                },
                                label: Text(context.l10n.clear, style: AppText.mediumB),
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
                                  final paymentAmounts = formValue<Map<PaymentMode, String>>('payment_details').value!;
                                  final currentPaymentMode = formValue<PaymentMode>('payment_mode').value!;
                                  paymentAmounts[currentPaymentMode] = '';
                                  formValue<Map<PaymentMode, String>>('payment_details').didChange(paymentAmounts);
                                },
                                label: Text(context.l10n.reset, style: AppText.mediumB),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              flex: 2,
                              child: AppButton(
                                padding: const EdgeInsets.all(6),
                                color: AppColors.green,
                                isLoading: cartState.isLoading,
                                onPress: () {
                                  _formKey.currentState?.save();
                                  final paymentAmounts = formValue<Map<PaymentMode, String>>('payment_details').value!;

                                  final totalPaid = paymentAmounts.values.fold<double>(0, (sum, amount) {
                                    final value = double.tryParse(amount) ?? 0.0;
                                    return sum + value;
                                  });
                                  final amount = double.tryParse(formValue<String>('amount').value ?? '0');
                                  // amount should be valid double value
                                  // If customer is not null, amount should be greater than or equal to due amount
                                  // If customer is null, amount should be greater than or equal to grand total
                                  if (amount == null || amount < 0) {
                                    Alert.showSnackBar(context.l10n.invalidAmount, type: SnackBarType.error);
                                    return;
                                  }
                                  if (cartState.customer == null && cartState.grandTotal > totalPaid) {
                                    Alert.showSnackBar(context.l10n.walkInCustomerDueAmount, type: SnackBarType.error);
                                    return;
                                  }

                                  cartNotifier.updatePaymentDetails(
                                    formValue<Map<PaymentMode, String>>('payment_details').value!,
                                  );
                                  cartNotifier
                                      .createSaleTransaction(
                                    formValue<Map<PaymentMode, String>>('payment_details').value!,
                                  )
                                      .then(
                                    (value) {
                                      if (context.mounted) {
                                        context.pushNamed(
                                          AppRouter.saleSuccess,
                                          pathParameters: {
                                            'id': value.saleId,
                                          },
                                        );
                                      }
                                    },
                                  );
                                },
                                label: Text(context.l10n.payment, style: AppText.mediumB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
