import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pinput/pinput.dart';

class EnterOtpScreenMobile extends ConsumerStatefulWidget {
  const EnterOtpScreenMobile({super.key});

  @override
  ConsumerState<EnterOtpScreenMobile> createState() => _EnterOtpScreenMobileState();
}

class _EnterOtpScreenMobileState extends ConsumerState<EnterOtpScreenMobile> {
  final pinTheme = PinTheme(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: AppColors.textfieldFill,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.textfieldOutline),
    ),
  );
  final pinController = TextEditingController();

  Future<void> verifyOTP() async {
    if (pinController.text.length != 6) {
      context.showSnackBar(context.l10n.enter6Digits, type: SnackBarType.warning);
      return;
    }
    await ref
        .read(authNotifierProvider.notifier)
        .verifyResetPassword(
          GoRouterState.of(context).uri.queryParameters['email']!,
          pinController.text,
        )
        .then(
      (value) {
        AppRouter.pushNamed(AppRouter.newPassword);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 90,
            ),
            Assets.images.duxbeLogo.image(),
            const SizedBox(height: 20),
            Text(
              context.l10n.enterOtpVerification,
              style: AppText.heading5,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.enterOTPSubtitle,
              style: AppText.smallN.copyWith(color: AppColors.greyText),
            ),
            const SizedBox(height: 16),
            Pinput(
              defaultPinTheme: pinTheme,
              focusedPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.primaryColor),
                ),
              ),
              length: 6,
              validator: (value) {
                return null;
              },
              onCompleted: (value) {},
              controller: pinController,
            ),
            const SizedBox(height: 16),
            AppButton(
              isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
              label: Text(context.l10n.submit),
              onPress: verifyOTP,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
