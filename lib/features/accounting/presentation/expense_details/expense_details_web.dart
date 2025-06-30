import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ExpenseDetailsScreenWeb extends ConsumerStatefulWidget {
  const ExpenseDetailsScreenWeb({required this.expense, super.key});
  final Expense? expense;

  @override
  ConsumerState<ExpenseDetailsScreenWeb> createState() => _ExpenseDetailsScreenWebState();
}

class _ExpenseDetailsScreenWebState extends ConsumerState<ExpenseDetailsScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final expenseNotifier = ref.watch(expenseNotifierProvider.notifier);
    final expenseState = ref.watch(expenseNotifierProvider);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),
      decoration: AppStyles.boxDecoration,
      child: FormBuilder(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppDateTimeForm(
                          name: 'date',
                          label: context.l10n.expenseDate,
                          initialValue: widget.expense?.date ?? DateTime.now(),
                          validator: FormBuilderValidators.required(),
                          valueTransformer: (date) => date?.toIso8601String(),
                        ),
                      ),
                      const SizedBox(height: 26, width: 26),
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
                  const SizedBox(height: 26, width: 26),
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
                      const SizedBox(height: 26, width: 26),
                      Expanded(
                        child: AppDropDownForm<PaymentMode>(
                          label: context.l10n.paymentType,
                          name: 'payment_type',
                          valueTransformer: (p0) => p0?.name,
                          validator: FormBuilderValidators.required(),
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
                  const SizedBox(height: 26, width: 26),
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
                      const SizedBox(height: 26, width: 26),
                      Expanded(
                        child: AppTextForm<String>(
                          initialValue: widget.expense?.referenceNumber,
                          label: context.l10n.referenceNumber,
                          name: 'reference_number',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26, width: 26),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextForm<String>(
                          initialValue: widget.expense?.note,
                          label: context.l10n.note,
                          name: 'note',
                          minLines: 4,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26, width: 26),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          onPress: context.pop,
                          label: Text(context.l10n.cancel),
                          style: ButtonStyles.secondary,
                        ),
                      ),
                      const SizedBox(width: 26),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          onPress: () {
                            if (_formKey.currentState?.saveAndValidate(focusOnInvalid: false) ?? false) {
                              expenseNotifier
                                  .upsertExpense(
                                Expense.fromJson(_formKey.currentState!.value).copyWith(
                                  expenseId: widget.expense?.expenseId,
                                ),
                              )
                                  .then(
                                (e) {
                                  AppRouter.pop();
                                  Alert.showSnackBar(
                                    AppRouter.l10n.expenseUpdatedSuccessfully,
                                    type: SnackBarType.success,
                                  );
                                },
                              );
                            }
                          },
                          label: Text(context.l10n.save),
                          isLoading: expenseState.status == ExpenseStatus.loading,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
