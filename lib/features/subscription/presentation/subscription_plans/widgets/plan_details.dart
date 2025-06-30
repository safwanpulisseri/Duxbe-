import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/organization/controller/organization_notifier.dart';
import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanDetailsDialog extends ConsumerWidget {
  const PlanDetailsDialog({
    required this.plan,
    super.key,
  });
  final PlanDetail plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveWidget(
      smallScreen: PlanDetailsDialogMobile(plan: plan),
      largeScreen: PlanDetailsDialogWeb(plan: plan),
    );
  }
}

class PlanDetailsDialogWeb extends ConsumerStatefulWidget {
  const PlanDetailsDialogWeb({required this.plan, super.key});

  final PlanDetail plan;

  @override
  ConsumerState<PlanDetailsDialogWeb> createState() => _PlanDetailsDialogState();
}

class _PlanDetailsDialogState extends ConsumerState<PlanDetailsDialogWeb> {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final countryCode = ref.watch(ipConfigProvider).value?.country ?? 'IN';
    final user = ref.watch(authNotifierProvider).user;
    final business = ref.watch(businessNotifierProvider);
    final org = ref.watch(organizationNotifierProvider);
    return FormBuilder(
      key: formKey,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.planDetails,
                  style: AppText.heading3.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
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
                                  initialValue: user?.email,
                                ),
                                const SizedBox(height: 12),
                                AppTextForm<String>(
                                  name: 'admin_name',
                                  label: context.l10n.adminName,
                                  hintText: context.l10n.enterAdminName,
                                  initialValue: user?.name,
                                ),
                                const SizedBox(height: 12),
                                AppTextForm<String>(
                                  name: 'company_name',
                                  label: context.l10n.companyName,
                                  hintText: context.l10n.enterCompanyName,
                                  initialValue: org?.organizationName,
                                ),
                                if (countryCode == 'IN') ...[
                                  const SizedBox(height: 12),
                                  AppCheckBoxForm(
                                    name: 'is_gst_applicable',
                                    hint: context.l10n.doYouHaveGstNumber,
                                    initialValue: business?.isGstRegistered,
                                  ),
                                  const SizedBox(height: 12),
                                  AppTextForm<String>(
                                    name: 'gst_number',
                                    label: context.l10n.gstNumber,
                                    hintText: context.l10n.enterGstNumber,
                                    initialValue: business?.gstIn,
                                  )
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(26),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.white,
                                    Color(0xffEEEAFF),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    context.l10n.plansInfo,
                                    style:
                                        AppText.heading4.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${widget.plan.planName} ${context.l10n.planAnnually}',
                                        style: AppText.xLargeN
                                            .copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        widget.plan.priceAnnual?.toStringAsFixed(2) ?? '0.00',
                                        style: AppText.xLargeN
                                            .copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: CustomPaint(
                                      painter: DashedLinePainter(),
                                      size: const Size(double.infinity, 1),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.l10n.subTotal,
                                        style: AppText.xLargeSB
                                            .copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        widget.plan.priceAnnual?.toStringAsFixed(2) ?? '0.00',
                                        style: AppText.xLargeSB
                                            .copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: CustomPaint(
                                      painter: DashedLinePainter(),
                                      size: const Size(double.infinity, 1),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.l10n.gst18,
                                        style: AppText.xLargeSB
                                            .copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        ((widget.plan.priceAnnual ?? 0) * 0.18).toStringAsFixed(2),
                                        style: AppText.xLargeSB
                                            .copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: CustomPaint(
                                      painter: DashedLinePainter(),
                                      size: const Size(double.infinity, 1),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.l10n.total,
                                        style: AppText.heading4
                                            .copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        ((widget.plan.priceAnnual ?? 0) * 1.18).toStringAsFixed(2),
                                        style: AppText.heading4
                                            .copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  AppButton(
                                    label: Text(context.l10n.payNow),
                                    isLoading: ref.watch(subscriptionPlansNotifierProvider).status ==
                                        SubscriptionPlansStatus.loading,
                                    onPress: () async {
                                      final subscription =
                                          await ref.read(subscriptionPlansNotifierProvider.notifier).createSubscription(
                                                planId: widget.plan.planId,
                                                // TODO
                                                countryCode: 'IN' ?? countryCode,
                                              );

                                      if (context.mounted) {
                                        final paymentUrl = subscription.paymentUrl;
                                        if (paymentUrl != null) {
                                          unawaited(
                                            launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication),
                                          );
                                        }
                                        context.pop();
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlanDetailsDialogMobile extends ConsumerStatefulWidget {
  const PlanDetailsDialogMobile({required this.plan, super.key});

  final PlanDetail plan;

  @override
  ConsumerState<PlanDetailsDialogMobile> createState() => _PlanDetailsDialogMobileState();
}

class _PlanDetailsDialogMobileState extends ConsumerState<PlanDetailsDialogMobile> {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final countryCode = ref.watch(ipConfigProvider).value?.country ?? 'IN';

    return FormBuilder(
      key: formKey,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.planDetails,
                  style: AppText.heading3.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
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
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.white,
                              Color(0xffEEEAFF),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              context.l10n.plansInfo,
                              style: AppText.heading4.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.plan.planName} ${context.l10n.planAnnually}',
                                  style: AppText.xLargeN.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  widget.plan.priceAnnual?.toStringAsFixed(2) ?? '0.00',
                                  style: AppText.xLargeN.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: CustomPaint(
                                painter: DashedLinePainter(),
                                size: const Size(double.infinity, 1),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.subTotal,
                                  style: AppText.xLargeSB.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  widget.plan.priceAnnual?.toStringAsFixed(2) ?? '0.00',
                                  style: AppText.xLargeSB.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: CustomPaint(
                                painter: DashedLinePainter(),
                                size: const Size(double.infinity, 1),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.gst18,
                                  style: AppText.xLargeSB.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  ((widget.plan.priceAnnual ?? 0) * 0.18).toStringAsFixed(2),
                                  style: AppText.xLargeSB.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: CustomPaint(
                                painter: DashedLinePainter(),
                                size: const Size(double.infinity, 1),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.total,
                                  style: AppText.heading4.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  ((widget.plan.priceAnnual ?? 0) * 1.18).toStringAsFixed(2),
                                  style: AppText.heading4.copyWith(color: AppColors.black, fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: Text(context.l10n.payNow),
                              isLoading: ref.watch(subscriptionPlansNotifierProvider).status ==
                                  SubscriptionPlansStatus.loading,
                              onPress: () async {
                                final subscription =
                                    await ref.read(subscriptionPlansNotifierProvider.notifier).createSubscription(
                                          planId: widget.plan.planId,
                                          countryCode: countryCode,
                                        );

                                if (context.mounted) {
                                  final paymentUrl = subscription.paymentUrl;
                                  if (paymentUrl != null) {
                                    unawaited(
                                      launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication),
                                    );
                                  }
                                  context.pop();
                                }
                              },
                            ),
                          ],
                        ),
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
}
