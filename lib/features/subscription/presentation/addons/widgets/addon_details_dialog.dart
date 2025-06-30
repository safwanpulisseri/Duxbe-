import 'dart:async';

import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:url_launcher/url_launcher.dart';

enum BillingCycle {
  monthly,
  annually,
}

class AddonDetailsDialog extends ConsumerWidget {
  const AddonDetailsDialog({required this.addon, super.key});
  final AddonDetail addon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveWidget(
      smallScreen: AddonDetailsDialogMobile(addon: addon),
      largeScreen: AddonDetailsDialogWeb(addon: addon),
    );
  }
}

class AddonDetailsDialogMobile extends ConsumerStatefulWidget {
  const AddonDetailsDialogMobile({required this.addon, super.key});
  final AddonDetail addon;

  @override
  ConsumerState<AddonDetailsDialogMobile> createState() => _AddonDetailsDialogMobileState();
}

class _AddonDetailsDialogMobileState extends ConsumerState<AddonDetailsDialogMobile> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _quantity = 1;
  BillingCycle _selectedCycle = BillingCycle.annually;

  double get _currentPricePerUnit {
    return _selectedCycle == BillingCycle.annually ? widget.addon.priceAnnual ?? 0 : widget.addon.priceMonthly ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final countryCode = ref.watch(ipConfigProvider).value?.country ?? 'IN';
    final purchaseState = ref.watch(addonPurchaseNotifierProvider);

    final subtotal = _currentPricePerUnit * _quantity;
    final gstAmount = subtotal * 0.18;
    final totalAmount = subtotal + gstAmount;

    return FormBuilder(
      key: _formKey,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Purchase Addon: ${widget.addon.addonName}',
                  style: AppText.heading4.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                // Billing Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Billing Details',
                      style: AppText.heading5.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 12),
                    const AppTextForm<String>(
                      name: 'email',
                      label: 'Email',
                      hintText: 'Enter email',
                    ),
                    const SizedBox(height: 12),
                    const AppCheckBoxForm(
                      name: 'is_gst_applicable',
                      hint: 'Do you have GST number?',
                    ),
                    const SizedBox(height: 12),
                    const AppTextForm<String>(
                      name: 'admin_name',
                      label: 'Admin Name',
                      hintText: 'Enter admin name',
                    ),
                    const SizedBox(height: 12),
                    const AppTextForm<String>(
                      name: 'company_name',
                      label: 'Company Name',
                      hintText: 'Enter company name',
                    ),
                    const SizedBox(height: 12),
                    const AppTextForm<String>(
                      name: 'gst_number',
                      label: 'GST Number',
                      hintText: 'Enter GST Number',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Addon Info and Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppColors.white, Color(0xffEEEAFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border.all(color: AppColors.greyBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Addon Configuration & Summary',
                        style: AppText.heading5.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 16),
                      // Billing Cycle Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Text(
                              'Monthly',
                              style: AppText.mediumSB.copyWith(
                                color:
                                    _selectedCycle == BillingCycle.monthly ? AppColors.white : AppColors.primaryColor,
                              ),
                            ),
                            selected: _selectedCycle == BillingCycle.monthly,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedCycle = BillingCycle.monthly);
                            },
                            selectedColor: AppColors.primaryColor,
                            backgroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: Text(
                              'Annually',
                              style: AppText.mediumSB.copyWith(
                                color:
                                    _selectedCycle == BillingCycle.annually ? AppColors.white : AppColors.primaryColor,
                              ),
                            ),
                            selected: _selectedCycle == BillingCycle.annually,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedCycle = BillingCycle.annually);
                            },
                            selectedColor: AppColors.primaryColor,
                            backgroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Quantity Counter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quantity (${widget.addon.unitName}):', style: AppText.xLargeN),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (_quantity > 1) setState(() => _quantity--);
                                },
                                color: AppColors.primaryColor,
                              ),
                              Text('$_quantity', style: AppText.xLargeSB.copyWith(fontSize: 20)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setState(() => _quantity++),
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Addon',
                        '${widget.addon.addonName} (${_selectedCycle == BillingCycle.annually ? "Annual" : "Monthly"}) x $_quantity',
                      ),
                      _buildSummaryRow(
                        'Price per unit',
                        '${widget.addon.currency}${_currentPricePerUnit.toStringAsFixed(2)}',
                      ),
                      const _DashedDivider(),
                      _buildSummaryRow(
                        'Sub Total',
                        '${widget.addon.currency}${subtotal.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      const _DashedDivider(),
                      _buildSummaryRow('GST (18%)', '${widget.addon.currency}${gstAmount.toStringAsFixed(2)}'),
                      const _DashedDivider(),
                      _buildSummaryRow(
                        'Total Amount',
                        '${widget.addon.currency}${totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                        isHeading: true,
                      ),
                      const SizedBox(height: 20),
                      if (purchaseState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(purchaseState.error!, style: AppText.smallSB.copyWith(color: AppColors.red)),
                        ),
                      AppButton(
                        label: const Text('Pay Now', style: TextStyle(color: AppColors.white)),
                        isLoading: purchaseState.status == AddonPurchaseStatus.loading,
                        onPress: () async {
                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                            final billingDetails = Map<String, dynamic>.from(_formKey.currentState!.value);

                            final paymentUrl =
                                await ref.read(addonPurchaseNotifierProvider.notifier).createAddonSubscription(
                                      addonId: widget.addon.addonId,
                                      quantity: _quantity,
                                      billingCycle: _selectedCycle,
                                      countryCode: countryCode,
                                      billingDetails: billingDetails,
                                    );

                            if (context.mounted) {
                              if (paymentUrl.paymentUrl != null) {
                                unawaited(
                                  launchUrl(
                                    Uri.parse(paymentUrl.paymentUrl!),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                );
                                context.pop();
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isHeading = false}) {
    final style = isHeading ? AppText.xLargeB : (isBold ? AppText.largeM : AppText.largeN);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: style.copyWith(color: AppColors.black, fontWeight: isBold ? FontWeight.w600 : FontWeight.w300),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Text(
              value,
              style: style.copyWith(color: AppColors.black, fontWeight: isBold ? FontWeight.w600 : FontWeight.w300),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CustomPaint(
        painter: DashedLinePainter(),
        size: const Size(double.infinity, 1),
      ),
    );
  }
}

class AddonDetailsDialogWeb extends ConsumerStatefulWidget {
  const AddonDetailsDialogWeb({required this.addon, super.key});

  final AddonDetail addon;

  @override
  ConsumerState<AddonDetailsDialogWeb> createState() => _AddonDetailsDialogWebState();
}

class _AddonDetailsDialogWebState extends ConsumerState<AddonDetailsDialogWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _quantity = 1;
  BillingCycle _selectedCycle = BillingCycle.annually;

  double get _currentPricePerUnit {
    return _selectedCycle == BillingCycle.annually ? widget.addon.priceAnnual ?? 0 : widget.addon.priceMonthly ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final countryCode = ref.watch(ipConfigProvider).value?.country ?? 'IN';
    final purchaseState = ref.watch(addonPurchaseNotifierProvider);

    final subtotal = _currentPricePerUnit * _quantity;
    final gstAmount = subtotal * 0.18; // Assuming 18% GST
    final totalAmount = subtotal + gstAmount;

    return FormBuilder(
      key: _formKey,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 200, vertical: 50), // Adjusted padding
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
               
                Text(
                  '${context.l10n.purchaseAddon}: ${widget.addon.addonName}',
                  style: AppText.heading3.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Billing Details Column
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.billingDetails,
                            style: AppText.heading4.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                          ),
                          const SizedBox(height: 12),
                           AppTextForm<String>(
                            name: 'email',
                            label: context.l10n.email,
                            hintText: context.l10n.enterEmail,
                          ),
                          const SizedBox(height: 12),
                           AppCheckBoxForm(
                            name: 'is_gst_applicable',
                            hint: context.l10n.doYouHaveGstNumber,
                          ),
                          const SizedBox(height: 12),
                           AppTextForm<String>(
                            name: 'admin_name',
                            label: context.l10n.adminName,
                            hintText: context.l10n.enterAdminName,
                          ),
                          const SizedBox(height: 12),
                           AppTextForm<String>(
                            name: 'company_name',
                            label: context.l10n.companyName,
                            hintText: context.l10n.enterCompanyName,
                          ),
                          const SizedBox(height: 12),
                           AppTextForm<String>(
                            name: 'gst_number',
                            label: context.l10n.gstNumber,  
                            hintText: context.l10n.enterGstNumber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Addon Info and Summary Column
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [AppColors.white, Color(0xffEEEAFF)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          border: Border.all(color: AppColors.greyBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              context.l10n.addonConfigurationSummary,
                              style: AppText.heading4.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(height: 16),
                            // Billing Cycle Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ChoiceChip(
                                  label: Text(
                                    'Monthly',
                                    style: AppText.mediumSB.copyWith(
                                      color: _selectedCycle == BillingCycle.monthly
                                          ? AppColors.white
                                          : AppColors.primaryColor,
                                    ),
                                  ),
                                  selected: _selectedCycle == BillingCycle.monthly,
                                  onSelected: (selected) {
                                    if (selected) setState(() => _selectedCycle = BillingCycle.monthly);
                                  },
                                  selectedColor: AppColors.primaryColor,
                                  backgroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: AppColors.primaryColor),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ChoiceChip(
                                  label: Text(
                                    'Annually',
                                    style: AppText.mediumSB.copyWith(
                                      color: _selectedCycle == BillingCycle.annually
                                          ? AppColors.white
                                          : AppColors.primaryColor,
                                    ),
                                  ),
                                  selected: _selectedCycle == BillingCycle.annually,
                                  onSelected: (selected) {
                                    if (selected) setState(() => _selectedCycle = BillingCycle.annually);
                                  },
                                  selectedColor: AppColors.primaryColor,
                                  backgroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: AppColors.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Quantity Counter
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${context.l10n.quantity} (${widget.addon.unitName}):', style: AppText.xLargeN),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () {
                                        if (_quantity > 1) setState(() => _quantity--);
                                      },
                                      color: AppColors.primaryColor,
                                    ),
                                    Text('$_quantity', style: AppText.xLargeSB.copyWith(fontSize: 20)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => setState(() => _quantity++),
                                      color: AppColors.primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow(
                              context.l10n.addon,
                              '${widget.addon.addonName} (${_selectedCycle == BillingCycle.annually ? "Annual" : "Monthly"}) x $_quantity',
                            ),
                            
                            _buildSummaryRow(
                             context.l10n.pricePerUnit ,
                              '${widget.addon.currency}${_currentPricePerUnit.toStringAsFixed(2)}',
                            ),
                            const _DashedDivider(),
                            _buildSummaryRow(
                              context.l10n.subTotal,
                              '${widget.addon.currency}${subtotal.toStringAsFixed(2)}',
                              isBold: true,
                            ),
                            const _DashedDivider(),
                            _buildSummaryRow('GST (18%)', '${widget.addon.currency}${gstAmount.toStringAsFixed(2)}'),
                            const _DashedDivider(),
                            _buildSummaryRow(
                              context.l10n.totalAmount,
                              '${widget.addon.currency}${totalAmount.toStringAsFixed(2)}',
                              isBold: true,
                              isHeading: true,
                            ),
                            const SizedBox(height: 20),
                            if (purchaseState.error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child:
                                    Text(purchaseState.error!, style: AppText.smallSB.copyWith(color: AppColors.red)),
                              ),
                            AppButton(
                              label:  Text(context.l10n.payNow, style: const TextStyle(color: AppColors.white)),
                              isLoading: purchaseState.status == AddonPurchaseStatus.loading,
                              onPress: () async {
                                if (_formKey.currentState?.saveAndValidate() ?? false) {
                                  final billingDetails = Map<String, dynamic>.from(_formKey.currentState!.value);

                                  final paymentUrl =
                                      await ref.read(addonPurchaseNotifierProvider.notifier).createAddonSubscription(
                                            addonId: widget.addon.addonId,
                                            quantity: _quantity,
                                            billingCycle: _selectedCycle,
                                            countryCode: countryCode,
                                            billingDetails: billingDetails,
                                          );

                                  if (context.mounted) {
                                    if (paymentUrl.paymentUrl != null) {
                                      unawaited(
                                        launchUrl(
                                          Uri.parse(paymentUrl.paymentUrl!),
                                          mode: LaunchMode.externalApplication,
                                        ),
                                      );
                                      context.pop();
                                    }
                                  }
                                }
                              },
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
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isHeading = false}) {
    final style = isHeading ? AppText.heading4 : (isBold ? AppText.xLargeSB : AppText.xLargeN);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: style.copyWith(color: AppColors.black, fontWeight: isBold ? FontWeight.w600 : FontWeight.w300),
          ),
          Text(
            value,
            style: style.copyWith(color: AppColors.black, fontWeight: isBold ? FontWeight.w600 : FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
