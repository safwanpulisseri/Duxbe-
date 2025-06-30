import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PaymentRefundScreenWeb extends ConsumerStatefulWidget {
  const PaymentRefundScreenWeb({this.sourceId, this.creditSourceId, super.key});
  final String? sourceId;
  final String? creditSourceId;
  @override
  ConsumerState<PaymentRefundScreenWeb> createState() => _PaymentRefundScreenWebState();
}

class _PaymentRefundScreenWebState extends ConsumerState<PaymentRefundScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  Widget _buildDivider({
    Widget? child,
    double? height,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Container(
      height: height ?? 10,
      decoration: BoxDecoration(
        color: AppColors.textfieldFill,
        border: Border.all(color: AppColors.divider),
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: child,
    );
  }

  void _onCustomerSelected(Customer? customer) {
    if (customer != null) {
      ref.read(paymentReceivedNotifierProvider.notifier).setCustomer(customer: customer);
    }
  }

  @override
  void initState() {
    super.initState();
    // if (widget.paymentReceived != null) {

    // }
    //  Future(
    //     () async {
    //       _formKey.currentState?.fields['payment']
    //           ?.didChange(await ref.read(paymentReceivedRepoProvider).getNextPaymentCode());
    //       setState(() {});
    //     },
    //   );
  }

  @override
  Widget build(BuildContext context) {
    final paymentReceivedState = ref.watch(refundPaymentsNotifierProvider);
    final paymentReceivedNotifier = ref.watch(refundPaymentsNotifierProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FormBuilder(
        key: _formKey,
        child: SizedBox.expand(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// MARK: HEADER
                // Text(
                //   '${context.l10n.paymentFor} INV-2025-26/0004',
                //   style: AppText.xLargeSB,
                // ),
                // const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 28,
                  ),
                  decoration: AppStyles.boxDecoration,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextForm<String>(
                              // initialValue: widget.paymentReceived?.amountReceived?.toString(),
                              name: 'amount_received',
                              label: '${context.l10n.amountReceived}*',
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter a amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          // SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: AppDateTimeForm(
                              initialValue: DateTime.now(),
                              name: 'refund_date',
                              label: 'Refunded On',
                              inputType: InputType.date,
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a date';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: AppDropDownForm<PaymentMode>(
                              label: context.l10n.paymentType,
                              name: 'payment_type',
                              validator: FormBuilderValidators.required(),
                              valueTransformer: (p0) => p0,
                              // initialValue: widget.paymentReceived?.paymentMode,
                              items: PaymentMode.values
                                  .map(
                                    (e) => DropDownItems(
                                      value: e,
                                      child: Text(e.name.displayCase),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: AppDropDownForm<String>(
                              label: 'From Account',
                              name: 'from_account',
                              validator: FormBuilderValidators.required(),
                              valueTransformer: (p0) => p0,
                              // initialValue: widget.paymentReceived?.depositedTo,
                              items: const [
                                DropDownItems(
                                  value: 'Petty cash',
                                  child: Text('Petty cash'),
                                ),
                                DropDownItems(
                                  value: 'Bank',
                                  child: Text('Bank'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: AppTextForm<String>(
                              // initialValue: widget.paymentReceived?.referenceNumber,
                              name: 'reference',
                              label: '${context.l10n.reference}#',
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextForm<String>(
                              // initialValue: widget.paymentReceived?.paymentNotes,
                              name: 'note',
                              label: context.l10n.note,
                              hintText: context.l10n.enterNoteHere,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter note';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Expanded(
                      child: Spacer(),
                    ),
                    AppButton(
                      label: Text(context.l10n.cancel),
                      style: ButtonStyles.secondary,
                      color: AppColors.primaryColor,
                      onPress: () {},
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    AppButton(
                      color: AppColors.primaryColor,
                      label: Text(context.l10n.save),
                      onPress: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final formData = _formKey.currentState!.value;

                          // Create refund data map
                          final refundData = {
                            'source_payment_id': widget.sourceId,
                            'source_credit_note_id': widget.creditSourceId,
                            'amount_refunded': double.parse(
                              formData['amount_received'] as String,
                            ),
                            'refund_date':
                                (formData['refund_date'] as DateTime).toString().split(' ')[0], // Format: YYYY-MM-DD
                            'payment_mode': (formData['payment_type'] as PaymentMode).name,
                            'deposited_to': formData['from_account'] as String,
                            'notes': formData['note'] as String,
                            'created_by': ref.read(authNotifierProvider).user?.employeeId,
                          };

                          try {
                            await ref.read(refundPaymentsNotifierProvider.notifier).createRefund(refundData);

                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            // Error is already handled in the notifier
                            print('Error creating refund: $e');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
