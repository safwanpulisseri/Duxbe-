import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/sale/domain/models/customer/customer_model.dart';
import 'package:duxbe/features/sale/domain/repositories/implementations/customer/customer_repository.dart';
import 'package:duxbe/features/sale/presentation/add_customer_dialog.dart';
import 'package:duxbe/shared/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class CreatePaymentScreenWeb extends ConsumerStatefulWidget {
  const CreatePaymentScreenWeb({this.invoice, this.isUpdate, super.key});
  final Invoice? invoice;
  final String? isUpdate;

  @override
  ConsumerState<CreatePaymentScreenWeb> createState() => _CreatePaymentScreenWebState();
}

class _CreatePaymentScreenWebState extends ConsumerState<CreatePaymentScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _onCustomerSelected(Customer? customer) {
    if (customer != null) {
      _formKey.currentState?.fields['customer']?.didChange(customer);
      // paymentReceivedNotifier.setCustomer(customer: customer);
    }
  }

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

  @override
  void initState() {
    Future(
      () async {
        _formKey.currentState?.fields['payment']?.didChange(
          await ref.read(paymentReceivedRepoProvider).getNextPaymentCode(),
        );
        _formKey.currentState?.patchValue({
          'invoice_date': DateTime.now(),
          'discount-percent': '0.00', // Reset discount percent when using fixed amount
          // Summary fields like 'total-items', 'subtotal', etc., will be populated by _updateSummary
        });
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(paymentReceivedNotifierProvider);
    final paymentReceivedNotifier = ref.watch(paymentReceivedNotifierProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FormBuilder(
        key: _formKey,
        initialValue: const {
          'customer-name': '',
          'amount-received': '',
          'payment-date': '',
          'deposit-to': '',
          'reference': '',
          'payment_type': PaymentMode.cash,
        },
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
                            child: AppTypeAheadForm<Customer>(
                              decoration: const InputDecoration(
                                suffixIcon: Icon(
                                  CupertinoIcons.chevron_down,
                                  color: AppColors.brandViolet,
                                  weight: 16,
                                ),
                              ),
                              initialValue: widget.invoice?.customer,
                              name: 'customer',
                              label: '${context.l10n.customer} *',
                              selectionToTextTransformer: (suggestion) => suggestion.name,
                              itemBuilder: (context, suggestion) => ListTile(
                                title: Text(suggestion.name),
                              ),
                              suggestionsCallback: (String search) async {
                                try {
                                  final response = await ref.read(customerRepoProvider).getCustomers(
                                        pageSize: 100,
                                        pageNumber: 1,
                                        query: search,
                                      );
                                  return response.data;
                                } catch (e) {
                                  setState(() {});
                                  return [];
                                }
                              },
                              onSuggestionSelected: _onCustomerSelected,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: AppButton.icon(
                              icon: const Icon(Icons.add),
                              onPress: () async {
                                final customer = await showDialog<Customer>(
                                  context: context,
                                  builder: (context) {
                                    return AddCustomerDialog(
                                      customerName: (_formKey.currentState?.fields['customer']?.value as Customer).name,
                                    );
                                  },
                                );
                                if (customer != null) {
                                  _formKey.currentState?.fields['customer']?.didChange(customer);
                                  paymentReceivedNotifier.setCustomer(
                                    customer: customer,
                                  );
                                }
                              },
                              label: Text(context.l10n.addCustomer),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: AppTextForm<String>(
                              // initialValue: widget.invoice?.invoiceCode,
                              name: 'payment',
                              label: '${context.l10n.payment}#*',
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                              style: AppText.largeM.copyWith(
                                color: AppColors.darkBlue,
                              ),
                              decoration: InputDecoration(
                                fillColor: AppColors.lightPurple,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextForm<String>(
                              initialValue: widget.invoice?.amount?.toString(),
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
                              inputType: InputType.date,
                              initialValue: DateTime.now(),
                              // initialValue: widget.paymentReceived?.paymentDate,
                              name: 'payment_date',
                              label: '${context.l10n.paymentDate}*',
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
                              valueTransformer: (p0) => p0?.name,
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
                              label: '${context.l10n.depositTo} *',
                              name: 'deposit_to',
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
                    const Spacer(),
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
                      label: Text(context.l10n.recordPayment),
                      onPress: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final formData = _formKey.currentState!.value;
                          final customer = formData['customer'] as Customer;
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

                          final paymentData = {
                            'business_id': ref
                                .read(businessNotifierProvider)!
                                .businessId, // This should come from your business context
                            'customer_id': customer.customerId,
                            'invoice_id': widget.invoice?.invoiceId,
                            'amount_received': double.parse(
                              formData['amount_received'].toString(),
                            ),
                            'payment_code': formData['payment'].toString(),
                            'payment_date': (formData['payment_date'] as DateTime).toIso8601String().split('T')[0],
                            'payment_mode': formData['payment_type'],
                            'deposited_to': formData['deposit_to'] as String,
                            'payment_status': PaymentReceivedDataStatus.paid.name,
                            'reference_number': formData['reference']?.toString(),
                            'notes': formData['note']?.toString(),
                          };

                          try {
                            await ref
                                .read(
                                  paymentReceivedNotifierProvider.notifier,
                                )
                                .createPayment(paymentReceived: paymentData);
                            _formKey.currentState?.reset();
                            _formKey.currentState?.fields['customer']?.didChange(null);
                            _formKey.currentState?.fields['amount_received']?.didChange(null);
                            _formKey.currentState?.fields['payment_date']?.didChange(null);

                            ref
                                .read(
                                  paymentReceivedNotifierProvider.notifier,
                                )
                                .setCustomer();
                          } catch (e) {
                            // Error is already handled in the notifier
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
