import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ExpenseDetailsScreenMobile extends ConsumerStatefulWidget {
  const ExpenseDetailsScreenMobile({required this.expense, super.key});
  final Expense? expense;

  @override
  ConsumerState<ExpenseDetailsScreenMobile> createState() => _ExpenseDetailsScreenMobileState();
}

class _ExpenseDetailsScreenMobileState extends ConsumerState<ExpenseDetailsScreenMobile> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final expenseNotifier = ref.watch(expenseNotifierProvider.notifier);
    final expenseState = ref.watch(expenseNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(widget.expense == null ? context.l10n.addExpense : context.l10n.expenseDetails),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: AppDateTimeForm(
                        name: 'date',
                        label: context.l10n.expenseDate,
                        valueTransformer: (date) => date?.toIso8601String(),
                        initialValue: widget.expense?.date ?? DateTime.now(),
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
                        name: 'expense_category_id',
                        initialValue: widget.expense?.category,
                        selectionToTextTransformer: (e) => e.name,
                        valueTransformer: (e) => e?.categoryId,
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.name),
                          );
                        },
                        suggestionsCallback: (String search) async {
                          return ref
                              .read(expenseCategoryRepoProvider)
                              .getExpenseCategories(
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
                        initialValue: widget.expense?.expenseFor,
                        label: context.l10n.expenseFor,
                        name: 'expense_for',
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
                        initialValue: widget.expense?.paymentType,
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
                        initialValue: widget.expense?.amount,
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
                        initialValue: widget.expense?.referenceNumber,
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
                        initialValue: widget.expense?.note,
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
                    expenseNotifier
                        .upsertExpense(
                          Expense.fromJson(_formKey.currentState!.value).copyWith(
                            expenseId: widget.expense?.expenseId,
                          ),
                        )
                        .then(AppRouter.pop);
                  }
                },
                label: Text(context.l10n.save),
                isLoading: expenseState.status == ExpenseStatus.loading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
