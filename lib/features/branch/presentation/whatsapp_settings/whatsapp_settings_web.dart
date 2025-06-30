import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class WhatsappSettingsScreenWeb extends ConsumerStatefulWidget {
  const WhatsappSettingsScreenWeb({super.key});

  @override
  ConsumerState<WhatsappSettingsScreenWeb> createState() => _WhatsappSettingsScreenWebState();
}

class _WhatsappSettingsScreenWebState extends ConsumerState<WhatsappSettingsScreenWeb> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final branch = ref.watch(branchProvider);
    return FormBuilder(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Customer Settings Section
          // Container(
          //   decoration: AppStyles.boxDecoration,
          //   padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 38),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       Text(
          //         context.l10n.whatsappSettings,
          //         style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
          //       ),
          //       const SizedBox(height: 26),
          //       FormBuilderDropdown(
          //         name: 'whatsapp_number',
          //         initialValue: 'Duxbe Connect - Whatsapp',
          //         decoration: InputDecoration(
          //           labelText: context.l10n.whatsappNumber,
          //         ),
          //         items: ['Duxbe Connect - Whatsapp']
          //             .map(
          //               (whatsapp) => DropdownMenuItem(
          //                 value: whatsapp,
          //                 child: Text(whatsapp),
          //               ),
          //             )
          //             .toList(),
          //       ),
          //       const SizedBox(height: 26),
          //       AppToggleForm(
          //         initialValue: branch?.whatsappIntegration?.customerSaleInvoice,
          //         name: 'order_notification',
          //         hint: context.l10n.orderNotification,
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       ),
          //       const SizedBox(height: 26),
          //       AppToggleForm(
          //         initialValue: branch?.whatsappIntegration?.customerPaymentReceipt,
          //         name: 'payment_receipt',
          //         hint: context.l10n.paymentReceipt,
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 26),

          // // Admin and Staff Settings Section
          // Container(
          //   decoration: AppStyles.boxDecoration,
          //   padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 38),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       Text(
          //         context.l10n.adminAndStaffSettings,
          //         style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
          //       ),
          //       const SizedBox(height: 26),
          //       FormBuilderDropdown(
          //         name: 'whatsapp_number_admin',
          //         initialValue: 'Duxbe Connect - Whatsapp',
          //         decoration: InputDecoration(
          //           labelText: context.l10n.whatsappNumber,
          //         ),
          //         items: ['Duxbe Connect - Whatsapp']
          //             .map(
          //               (whatsapp) => DropdownMenuItem(
          //                 value: whatsapp,
          //                 child: Text(whatsapp),
          //               ),
          //             )
          //             .toList(),
          //       ),
          //       const SizedBox(height: 26),
          //       FormBuilderDropdown(
          //         initialValue: branch?.whatsappIntegration?.paymentOverdueAlert ?? 'None',
          //         name: 'payment_overdue_alert_interval',
          //         decoration: InputDecoration(
          //           labelText: context.l10n.paymentOverdueAlertInterval,
          //         ),
          //         items: ['None', '15 Days', '30 Days']
          //             .map(
          //               (interval) => DropdownMenuItem(
          //                 value: interval,
          //                 child: Text(interval),
          //               ),
          //             )
          //             .toList(),
          //       ),
          //       const SizedBox(height: 26),
          //       AppToggleForm(
          //         initialValue: branch?.whatsappIntegration?.adminOrderAssignedAlert,
          //         name: 'order_assignation',
          //         hint: context.l10n.orderAssignation,
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       ),
          //       const SizedBox(height: 26),
          //       AppToggleForm(
          //         initialValue: branch?.whatsappIntegration?.adminStockAlert,
          //         name: 'stock_alert',
          //         hint: context.l10n.stockAlert,
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 26),

          // Whatsapp Custom Section
          Container(
            decoration: AppStyles.boxDecoration,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.whatsappCustom,
                  style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                ),
                const SizedBox(height: 26),
                FormBuilderTextField(
                  initialValue: branch?.whatsappIntegration?.whatsappNumberId,
                  name: 'whatsapp_number_id',
                  decoration: InputDecoration(
                    labelText: context.l10n.whatsappNumberId,
                  ),
                ),
                const SizedBox(height: 26),
                FormBuilderTextField(
                  initialValue: branch?.whatsappIntegration?.whatsappToken,
                  name: 'whatsapp_token',
                  decoration: InputDecoration(
                    labelText: context.l10n.whatsappToken,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),

          // Save Button
          Row(
            children: [
              const Spacer(),
              Expanded(
                child: AppButton(
                  onPress: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      ref.read(branchNotifierProvider.notifier).editWhatsappSettings(
                            WhatsappIntegration(
                              businessId: branch!.businessId,
                              customerSaleInvoice: _formKey.currentState!.instantValue['order_notification'] as bool,
                              customerPaymentReceipt: _formKey.currentState!.instantValue['payment_receipt'] as bool,
                              adminOrderAssignedAlert: _formKey.currentState!.instantValue['order_assignation'] as bool,
                              adminStockAlert: _formKey.currentState!.instantValue['stock_alert'] as bool,
                              paymentOverdueAlert: _formKey.currentState!.instantValue['payment_overdue_alert_interval'] as String,
                              whatsappNumberId: _formKey.currentState!.instantValue['whatsapp_number_id'] as String?,
                              whatsappToken: _formKey.currentState!.instantValue['whatsapp_token'] as String?,
                            ),
                          );
                    }
                  },
                  label: Text(context.l10n.save, style: AppText.heading5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
