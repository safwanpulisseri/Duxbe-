import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class GeneralSettingsScreenMobile extends ConsumerStatefulWidget {
  const GeneralSettingsScreenMobile({super.key});

  @override
  ConsumerState<GeneralSettingsScreenMobile> createState() => _GeneralSettingsScreenMobileState();
}

class _GeneralSettingsScreenMobileState extends ConsumerState<GeneralSettingsScreenMobile> {
  final formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final branch = ref.watch(branchProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          context.l10n.generalSettings,
        ),
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
                  Container(
                    decoration: AppStyles.boxDecoration,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.customerSettings,
                          style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                        ),
                        const SizedBox(height: 16),
                        AppToggleForm(
                          name: 'allow_walkin_customer',
                          hint: context.l10n.allowWalkInCustomers,
                          initialValue: branch?.allowWalkinCustomer,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: AppStyles.boxDecoration,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.inventorySettings,
                          style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                        ),
                        const SizedBox(height: 16),
                        AppToggleForm(
                          name: 'allow_sales_when_outofstock',
                          hint: context.l10n.allowSalesWhenOutOfStock,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          initialValue: branch?.allowSalesWhenOutOfStock,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: AppButton(
                  isLoading: ref.watch(branchNotifierProvider).status == BranchStatus.loading,
                  onPress: () {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      ref.read(branchNotifierProvider.notifier).updateGeneralSettings(
                        data: {
                          'business_id': branch?.businessId,
                          ...?formKey.currentState?.value,
                        },
                      ).then((value) {
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
