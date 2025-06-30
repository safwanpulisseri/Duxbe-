import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class IncomeDetailsScreenMobile extends ConsumerStatefulWidget {
  const IncomeDetailsScreenMobile({required this.income, super.key});
  final Income? income;
  @override
  ConsumerState<IncomeDetailsScreenMobile> createState() => _IncomeDetailsScreenMobileState();
}

class _IncomeDetailsScreenMobileState extends ConsumerState<IncomeDetailsScreenMobile> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final incomeNotifier = ref.watch(incomeNotifierProvider.notifier);
    final incomeState = ref.watch(incomeNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(widget.income == null ? context.l10n.addIncome : context.l10n.incomeDetails),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: AppDateTimeForm(
                        name: 'date',
                        label: context.l10n.incomeDate,
                        valueTransformer: (date) => date?.toIso8601String(),
                        initialValue: widget.income?.date ?? DateTime.now(),
                        validator: FormBuilderValidators.required(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTypeAheadForm<TransactionCategory>(
                        label: context.l10n.category,
                        name: 'income_category_id',
                        initialValue: widget.income?.category,
                        selectionToTextTransformer: (e) => e.name,
                        valueTransformer: (e) => e?.categoryId,
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.name),
                          );
                        },
                        suggestionsCallback: (String search) async {
                          return ref
                              .read(incomeCategoryRepoProvider)
                              .getIncomeCategories(
                                pageSize: 12,
                                pageNumber: 1,
                                query: search,
                              )
                              .then((value) => value.data);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextForm<String>(
                        initialValue: widget.income?.incomeFor,
                        label: context.l10n.incomeFor,
                        name: 'income_for',
                        validator: FormBuilderValidators.required(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppDropDownForm<PaymentMode>(
                        label: context.l10n.paymentType,
                        name: 'payment_type',
                        validator: FormBuilderValidators.required(),
                        valueTransformer: (p0) => p0?.name,
                        initialValue: widget.income?.paymentType,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextForm<double>(
                        initialValue: widget.income?.amount,
                        label: context.l10n.amount,
                        name: 'amount',
                        validator: FormBuilderValidators.required(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextForm<String>(
                        initialValue: widget.income?.referenceNumber,
                        label: context.l10n.referenceNumber,
                        name: 'reference_number',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextForm<String>(
                        initialValue: widget.income?.note,
                        label: context.l10n.note,
                        name: 'note',
                        minLines: 4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                onPress: () {
                  if (_formKey.currentState?.saveAndValidate(focusOnInvalid: false) ?? false) {
                    incomeNotifier
                        .upsertIncome(
                          Income.fromJson(_formKey.currentState!.value).copyWith(
                            incomeId: widget.income?.incomeId,
                          ),
                        )
                        .then(AppRouter.pop);
                  }
                },
                label: Text(context.l10n.save),
                isLoading: incomeState.status == IncomeStatus.loading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
