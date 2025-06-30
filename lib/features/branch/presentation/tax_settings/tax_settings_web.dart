import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

part 'add_tax_dialog.dart';

class TaxSettingsScreenWeb extends ConsumerStatefulWidget {
  const TaxSettingsScreenWeb({super.key});

  @override
  ConsumerState<TaxSettingsScreenWeb> createState() =>
      _TaxSettingsScreenWebState();
}

class _TaxSettingsScreenWebState extends ConsumerState<TaxSettingsScreenWeb>
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
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: AppStyles.boxDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (branch?.country == 'India') ...[
                Text(
                  context.l10n.gstSettings,
                  style:
                      AppText.largeSB.copyWith(color: AppColors.primaryColor),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: AppToggleForm(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        name: 'is_gst_registered',
                        hint: context.l10n.isYourBusinessRegisteredFor,
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 20, width: 20),
                    const Spacer(),
                  ],
                ),
                if (formKey.fields['is_gst_registered']?.value == true)
                 const Row(
                    children: [
                      const Expanded(
                        child: AppTextForm<String>(
                          name: 'gst_in',
                          label: 'GSTIN',
                        ),
                      ),
                       SizedBox(height: 24, width: 20),
                      Spacer(),
                      // Expanded(
                      //   child: AppDateTimeForm(
                      //     inputType: InputType.date,
                      //     label: context.l10n.gstRegisteredOn,
                      //     name: 'gst_registered_date',
                      //   ),
                      // ),
                    ],
                  ),
                const SizedBox(height: 26),
              ],
              Text(
                branch?.country == 'India'
                    ? context.l10n.taxpayerDetails
                    : context.l10n.taxSettings,
                style: AppText.largeSB,
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: AppTextForm<String>(
                      name: 'legal_business_name',
                      label: context.l10n.businessLegalName,
                    ),
                  ),
                  const SizedBox(height: 20, width: 20),
                  const Spacer(),
                ],
              ),
              // const SizedBox(height: 20, width: 20),
              // Row(
              //   children: [
              //     Expanded(
              //       child: AppTextForm<String>(
              //         name: 'trade_name',
              //         label: context.l10n.businessTradeName,
              //       ),
              //     ),
              //     const SizedBox(height: 20, width: 20),
              //     const Spacer(),
              //   ],
              // ),
            
            ],
          ),
        ),
        Container(
          decoration: AppStyles.boxDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.taxRates,
                    style:
                        AppText.largeSB.copyWith(color: AppColors.primaryColor),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, color: AppColors.primaryColor),
                    label: Text(
                      context.l10n.addTax,
                      style: AppText.mediumM
                          .copyWith(color: AppColors.primaryColor),
                    ),
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (context) {
                          return ProviderScope(
                            overrides: [
                              branchProvider.overrideWith((ref) => branch)
                            ],
                            child: const AddTaxDialog(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 300, child: Text(context.l10n.taxName)),
                      SizedBox(width: 300, child: Text(context.l10n.taxType)),
                      SizedBox(width: 300, child: Text(context.l10n.taxRate)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...ref
                      .watch(taxNotifierProvider(branch?.businessId ?? ''))
                      .taxes
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 300,
                                child: Text(
                                  e.name,
                                  style: AppText.largeN
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: Text(
                                  e.type ?? '',
                                  style: AppText.largeN.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: Text(
                                  e.rate.toString(),
                                  style: AppText.largeN
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
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
                isLoading: ref.watch(branchNotifierProvider).status ==
                    BranchStatus.loading,
                onPress: () {
                  if (formKey.saveAndValidate()) {
                    ref.read(branchNotifierProvider.notifier).updateTaxSettings(
                      data: {
                        'business_id': branch?.businessId,
                        ...{
                          'is_gst_registered':
                              formKey.value['is_gst_registered'],
                          'gst_in': formKey.value['gst_in'],
                          'legal_business_name':
                              formKey.value['legal_business_name'],
                          'gst_registered_date':
                              formKey.value['gst_registered_date'],
                          'trade_name': formKey.value['trade_name'],
                        },
                      },
                    ).then((value) {
                      ref.invalidate(businessProvider(branch?.businessId));
                      // ignore: use_build_context_synchronously
                      if (context.canPop()) context.pop();
                      if (!mounted) return;
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
