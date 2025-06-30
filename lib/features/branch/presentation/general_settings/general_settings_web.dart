import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class GeneralSettingsScreenWeb extends ConsumerStatefulWidget {
  const GeneralSettingsScreenWeb({super.key});

  @override
  ConsumerState<GeneralSettingsScreenWeb> createState() => _GeneralSettingsScreenWebState();
}

class _GeneralSettingsScreenWebState extends ConsumerState<GeneralSettingsScreenWeb>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final formKey = FormBuilder.of(context)!;
    final branch = ref.watch(branchProvider);
    return ListView(
      children: [
        Container(
          decoration: AppStyles.boxDecoration,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.customerSettings,
                style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
              ),
              const SizedBox(height: 26),
              AppToggleForm(
                name: 'allow_walkin_customer',
                hint: context.l10n.allowWalkInCustomers,
                initialValue: branch?.allowWalkinCustomer ?? true,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Container(
          decoration: AppStyles.boxDecoration,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.inventorySettings,
                style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
              ),
              const SizedBox(height: 26),
              AppToggleForm(
                name: 'allow_sales_when_outofstock',
                hint: context.l10n.allowSalesWhenOutOfStock,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                initialValue: branch?.allowSalesWhenOutOfStock ?? true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (context.canPop())
              SizedBox(
                width: 100,
                child: AppButton(
                  onPress: context.pop,
                  label: Text(context.l10n.cancel),
                  style: ButtonStyles.secondary,
                ),
              ),
            const SizedBox(height: 20, width: 20),
            SizedBox(
              width: 200,
              child: AppButton(
                isLoading: ref.watch(branchNotifierProvider).status == BranchStatus.loading,
                onPress: () {
                  if (formKey.saveAndValidate()) {
                    ref.read(branchNotifierProvider.notifier).updateGeneralSettings(
                      data: {
                        'business_id': branch?.businessId,
                        ...{
                          'allow_walkin_customer': formKey.value['allow_walkin_customer'],
                          'allow_sales_when_outofstock': formKey.value['allow_sales_when_outofstock'],
                        },
                      },
                    ).then((value) {
                      ref.read(branchProvider.notifier).state = value;
                      // ignore: use_build_context_synchronously
                      if (context.canPop()) context.pop();
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      DefaultTabController.of(context).animateTo(0);
                    });
                  }
                },
                label: Text(context.l10n.save, style: AppText.heading5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
