import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key, this.category});
  final ItemCategory? category;
  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _categoryFormKey = GlobalKey<FormBuilderState>();
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

  void _createCategory() {
    if (_categoryFormKey.currentState?.saveAndValidate() ?? false) {
      ref
          .read(itemCategoryNotifierProvider.notifier)
          .upsertItemCategory(
            ItemCategory.fromJson(_categoryFormKey.currentState!.value).copyWith(
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
              itemCategoryId: widget.category?.itemCategoryId,
            ),
          )
          .then(AppRouter.pop);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormAddDialog(
      formKey: _categoryFormKey,
      title: context.l10n.addCategory,
      isLoading: ref.watch(itemCategoryNotifierProvider).isLoading,
      onPositive: _createCategory,
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
                initialValue: widget.category?.name,
                label: AppRouter.l10n.categoryName,
                name: 'name',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required<String>(
                    errorText: AppRouter.l10n.pleaseEnterTheCategoryName,
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
                initialValue: widget.category?.description,
                minLines: 5,
                label: AppRouter.l10n.description,
                name: 'description',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
