import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

enum TransactionCategoryType {
  expense,
  income,
}

class AddTransactionCategoryDialog extends ConsumerStatefulWidget {
  const AddTransactionCategoryDialog({required this.type, super.key, this.category});
  final TransactionCategory? category;
  final TransactionCategoryType type;

  @override
  ConsumerState<AddTransactionCategoryDialog> createState() => _AddTransactionCategoryDialogState();
}

class _AddTransactionCategoryDialogState extends ConsumerState<AddTransactionCategoryDialog> {
  final categoryFormKey = GlobalKey<FormBuilderState>();
  IconData? buttonIcon;

  @override
  void initState() {
    final icon = widget.category?.iconInfo;
    if (icon != null) {
      buttonIcon = IconData(
        icon.code!,
        fontFamily: icon.family,
        fontPackage: icon.package,
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormAddDialog(
      isLoading: widget.type == TransactionCategoryType.expense
          ? ref.watch(expenseCategoryNotifierProvider).status == ExpenseCategoryStatus.loading
          : ref.watch(incomeCategoryNotifierProvider).status == IncomeCategoryStatus.loading,
      onPositive: () {
        if (widget.type == TransactionCategoryType.expense) {
          ref
              .read(expenseCategoryNotifierProvider.notifier)
              .upsertExpenseCategory(
                TransactionCategory(
                  description: categoryFormKey.currentState?.fields['description']?.value as String? ?? '',
                  name: categoryFormKey.currentState!.fields['name']!.value as String,
                  iconInfo: buttonIcon != null
                      ? IconInfo(
                          code: buttonIcon!.codePoint,
                          family: buttonIcon!.fontFamily,
                          package: buttonIcon!.fontPackage,
                        )
                      : const IconInfo(
                          code: 62602,
                          family: 'CupertinoIcons',
                          package: 'cupertino_icons',
                        ),
                  categoryId: widget.category?.categoryId,
                ),
              )
              .then(context.pop);
        }
        if (widget.type == TransactionCategoryType.income) {
          ref
              .read(incomeCategoryNotifierProvider.notifier)
              .upsertIncomeCategory(
                TransactionCategory(
                  description: categoryFormKey.currentState?.fields['description']?.value as String? ?? '',
                  name: categoryFormKey.currentState!.fields['name']!.value as String,
                  iconInfo: buttonIcon != null
                      ? IconInfo(
                          code: buttonIcon!.codePoint,
                          family: buttonIcon!.fontFamily,
                          package: buttonIcon!.fontPackage,
                        )
                      : const IconInfo(
                          code: 62602,
                          family: 'CupertinoIcons',
                          package: 'cupertino_icons',
                        ),
                  categoryId: widget.category?.categoryId,
                ),
              )
              .then(context.pop);
        }
      },
      formKey: categoryFormKey,
      title: context.l10n.addCategory,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FormAddButton(
              icon: Icon(buttonIcon ?? CupertinoIcons.add_circled),
              onTap: () async {
                final icon = await showIconPicker(
                  context,
                  configuration: const SinglePickerConfiguration(
                    iconPackModes: [
                      IconPack.material,
                      IconPack.cupertino,
                    ],
                  ),
                );
                if (icon == null) return;
                setState(() {
                  buttonIcon = icon.data;
                });
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextForm(
                label: context.l10n.categoryName,
                name: 'name',
                initialValue: widget.category?.name,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required<String>(
                    errorText: context.l10n.pleaseEnterTheCategoryName,
                  ),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppTextForm<String>(
                minLines: 5,
                initialValue: widget.category?.description,
                label: context.l10n.description,
                name: 'description',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
