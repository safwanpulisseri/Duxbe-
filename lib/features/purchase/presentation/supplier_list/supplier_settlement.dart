import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class SupplierSettlementDialog extends ConsumerStatefulWidget {
  const SupplierSettlementDialog({required this.supplierId, super.key, this.invoice});
  final String supplierId;
  final PurchaseView? invoice;
  @override
  ConsumerState<SupplierSettlementDialog> createState() => _SupplierSettlementDialogState();
}

class _SupplierSettlementDialogState extends ConsumerState<SupplierSettlementDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    return FormAddDialog(
      title: context.l10n.settlements,
      formKey: _formKey,
      isLoading: ref.watch(purchaseNotifierProvider).isLoading,
      onPositive: () {
        if (_formKey.currentState!.saveAndValidate()) {
          ref
              .read(purchaseNotifierProvider.notifier)
              .settlePurchase(
                purchase: _formKey.currentState?.fields['invoice']?.value as PurchaseView,
                amount: double.parse(_formKey.currentState?.value['paid'].toString() ?? '0'),
                mode: PaymentMode.cash,
                date: _formKey.currentState!.value['settlement_date'] as DateTime,
              )
              .then((value) {
            ref
              ..invalidate(supplierProvider(widget.supplierId))
              ..invalidate(purchaseNotifierProvider)
              ..read(partyDetailsNotifierProvider(TransactionParty.supplier, widget.supplierId).notifier).getPurchases(pageNumber: 1)
              ..read(partyDetailsNotifierProvider(TransactionParty.supplier, widget.supplierId).notifier).getPartyDetails()
              ..read(ledgerNotifierProvider.notifier).getParties(pageNumber: 1)
              ..read(ledgerNotifierProvider.notifier).getLedger();

            if (context.mounted) {
              context.pop();
            }
          });
        }
      },
      children: ref.watch(supplierProvider(widget.supplierId)).when(
            data: (supplier) => [
              AppTextForm<String>(
                enabled: false,
                initialValue: supplier?.name,
                label: context.l10n.supplierName,
                name: 'name',
              ),
              const SizedBox(height: 20),
              AppDateTimeForm(
                name: 'settlement_date',
                label: context.l10n.date,
                initialValue: DateTime.now(),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        AppTypeAheadForm<PurchaseView>(
                          label: context.l10n.invoice,
                          name: 'invoice',
                          validator: FormBuilderValidators.required(),
                          valueTransformer: (value) => value?.purchaseId,
                          initialValue: widget.invoice,
                          enabled: widget.invoice == null,
                          onSuggestionSelected: (suggestion) {
                            _formKey.currentState?.fields['due']?.didChange(suggestion.dueAmount.toStringAsFixed(2));
                            _formKey.currentState?.fields['paid']?.reset();
                            _formKey.currentState?.fields['balance']?.didChange(suggestion.dueAmount);
                          },
                          itemBuilder: (context, itemData) {
                            return ListTile(
                              title: Text(itemData.purchaseInvoice),
                            );
                          },
                          onClear: () {
                            _formKey.currentState?.fields['invoice']?.reset();
                            _formKey.currentState?.fields['due']?.reset();
                            _formKey.currentState?.fields['balance']?.reset();
                            _formKey.currentState?.fields['paid']?.reset();
                          },
                          suggestionsCallback: (pattern) =>
                              ref.read(purchaseRepoProvider).getDuePurchasesWithSupplierId(supplierId: widget.supplierId, query: pattern),
                          selectionToTextTransformer: (suggestion) => suggestion.purchaseInvoice,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppTextForm<double>(
                enabled: false,
                label: context.l10n.dueAmount,
                initialValue: widget.invoice?.dueAmount,
                name: 'due',
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 20),
              AppTextForm<double>(
                label: context.l10n.paidAmount,
                name: 'paid',
                initialValue: 0,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.min(0, inclusive: false),
                  (value) {
                    final max = widget.invoice?.dueAmount ?? double.tryParse(_formKey.currentState?.fields['due']?.value as String) ?? 0;
                    if (value != null) {
                      if (value > max) {
                        return FormBuilderLocalizations.current.maxErrorText(max);
                      }
                    }
                    return null;
                  }
                ]),
                onChanged: (value) {
                  final due = double.tryParse(_formKey.currentState?.fields['due']?.value as String) ?? 0;
                  _formKey.currentState?.fields['balance']?.didChange(due - (value ?? 0));
                },
              ),
              const SizedBox(height: 20),
              AppDropDownForm<PaymentMode>(
                name: 'payment_type',
                valueTransformer: (value) => value?.name,
                label: context.l10n.paymentMode,
                validator: FormBuilderValidators.required(),
                items: PaymentMode.values
                    .map(
                      (e) => DropDownItems(
                        value: e,
                        child: Text(e.name.displayCase),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              FormBuilderField<double>(
                name: 'balance',
                initialValue: widget.invoice?.dueAmount,
                builder: (field) {
                  final balance = field.value ?? 0;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          balance > 0 ? context.l10n.balance : context.l10n.due,
                          style: AppText.largeM.copyWith(color: AppColors.primaryColor),
                        ),
                        Text(
                          '$currency ${balance.abs().toStringAsFixed(2)}',
                          style: AppText.largeM.copyWith(color: AppColors.primaryColor),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            error: (error, stackTrace) => [Center(child: Text(error.toString()))],
            loading: () => [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Loader(),
              ),
            ],
          ),
    );
  }
}
