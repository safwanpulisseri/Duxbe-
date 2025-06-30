import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class TaxSettingsScreenMobile extends ConsumerStatefulWidget {
  const TaxSettingsScreenMobile({super.key});

  @override
  ConsumerState<TaxSettingsScreenMobile> createState() => _TaxSettingsScreenMobileState();
}

class _TaxSettingsScreenMobileState extends ConsumerState<TaxSettingsScreenMobile> {
  final formKey = GlobalKey<FormBuilderState>();

  void _showOptionsBottomModal(Tax tax) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.black),
                color: AppColors.black.withOpacity(0.05),
                onPress: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return AddTaxDialog(tax: tax);
                    },
                  );
                },
                label: Text(context.l10n.edit, style: AppText.smallSB.copyWith(color: AppColors.black)),
              ),
              const SizedBox(height: 12),
              AppButton.icon(
                icon: const Icon(Icons.delete_outlined, size: 16, color: AppColors.black),
                color: AppColors.black.withOpacity(0.05),
                onPress: () {
                  showDialog<void>(
                    context: AppRouter.rootContext,
                    builder: (context) => ConfirmationDialog(
                      title: AppRouter.l10n.deleteTax,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppRouter.l10n.areYouSureYouWantToDeleteThisTax,
                          style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                        ),
                      ],
                      onPositive: (ref) {
                        ref
                            .read(taxNotifierProvider(tax.businessId!).notifier)
                            .deleteTax(tax.taxId!)
                            .then(AppRouter.pop);
                      },
                    ),
                  );
                },
                label: Text(context.l10n.delete, style: AppText.smallSB.copyWith(color: AppColors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final branch = ref.watch(branchProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title:  Text(context.l10n.taxSettings),
      ),
      body: FormBuilder(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                cacheExtent: 1000,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  Text(
                    context.l10n.gstSettings,
                    style: AppText.mediumN.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 16),
                  AppToggleForm(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    name: 'is_gst_registered',
                    hint: context.l10n.isYourBusinessRegisteredFor,
                    initialValue: branch?.isGstRegistered,
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  if (formKey.currentState?.fields['is_gst_registered']?.value == true) ...[
                    AppTextForm<String>(
                      name: 'gst_in',
                      label: 'GSTIN',
                      initialValue: branch?.gstIn,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    context.l10n.taxpayerDetails,
                    style: AppText.mediumN.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 16),
                  AppTextForm<String>(
                    name: 'legal_business_name',
                    label: context.l10n.businessLegalName,
                    initialValue: branch?.legalBusinessName,
                  ),
                  const SizedBox(height: 16),
                  AppDateTimeForm(
                    inputType: InputType.date,
                    label: context.l10n.gstRegisteredOn,
                    name: 'gst_registered_date',
                    initialValue: branch?.gstRegisteredDate,
                    valueTransformer: (date) => date?.toIso8601String(),
                  ),
                  const SizedBox(height: 16),
                  AppTextForm<String>(
                    name: 'trade_name',
                    label: context.l10n.businessTradeName,
                    initialValue: branch?.tradeName,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.taxRates, style: AppText.largeSB.copyWith(color: AppColors.primaryColor)),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.brandViolet,
                          surfaceTintColor: AppColors.brandViolet,
                          overlayColor: AppColors.brandViolet,
                        ),
                        icon: const Icon(Icons.add),
                        label: Text(context.l10n.addTax, style: AppText.mediumM),
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) {
                              return ProviderScope(
                                overrides: [branchProvider.overrideWith((ref) => branch)],
                                child: const AddTaxDialog(),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (branch?.businessId != null)
                    ...ref.watch(taxNotifierProvider(branch!.businessId)).taxes.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
                              splashColor: Colors.transparent,
                              onLongPress: () {
                                _showOptionsBottomModal(e);
                              },
                              child: Ink(
                                decoration: AppStyles.boxDecoration,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              context.l10n.taxName,
                                              style: AppText.smallN.copyWith(color: AppColors.stormyBlue, height: 1.5),
                                            ),
                                            Text(
                                              e.name,
                                              style:
                                                  AppText.mediumM.copyWith(color: AppColors.primaryColor, height: 1.5),
                                            ),
                                            Text(
                                              context.l10n.taxType,
                                              style: AppText.smallN.copyWith(color: AppColors.stormyBlue, height: 1.5),
                                            ),
                                            Text(
                                              e.type ?? '',
                                              style:
                                                  AppText.mediumM.copyWith(color: AppColors.primaryColor, height: 1.5),
                                            ),
                                            Text(
                                              context.l10n.taxRate,
                                              style: AppText.smallN.copyWith(color: AppColors.stormyBlue, height: 1.5),
                                            ),
                                            Text(
                                              e.rate.toString(),
                                              style:
                                                  AppText.mediumM.copyWith(color: AppColors.primaryColor, height: 1.5),
                                            ),
                                          ],
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
            const SizedBox(height: 16),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: AppButton(
                  isLoading: ref.watch(branchNotifierProvider).status == BranchStatus.loading,
                  onPress: () {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      ref.read(branchNotifierProvider.notifier).updateTaxSettings(
                        data: {
                          'business_id': branch?.businessId,
                          ...?formKey.currentState?.value,
                        },
                      ).then((value) {
                        ref.invalidate(businessProvider(branch?.businessId));
                        // ignore: use_build_context_synchronously
                        if (context.canPop()) context.pop();
                        if (!mounted) return;
                      });
                    }
                  },
                  label: Text(context.l10n.save, style: AppText.largeB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
