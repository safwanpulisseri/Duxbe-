import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pinput/pinput.dart';

class EnterOtpScreenWeb extends ConsumerStatefulWidget {
  const EnterOtpScreenWeb({super.key});

  @override
  ConsumerState<EnterOtpScreenWeb> createState() => _EnterOtpScreenWebState();
}

class _EnterOtpScreenWebState extends ConsumerState<EnterOtpScreenWeb> {
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.loginBg.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 58,
            left: 0,
            right: 0,
            child: Text(
              context.l10n.copyright,
              textAlign: TextAlign.center,
              style: AppText.largeN.copyWith(color: AppColors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Assets.icons.duxbeWhiteLogo.svg(height: 88),
                  const SizedBox(height: 44),
                  Text(
                    context.l10n.loginTitle,
                    style: AppText.heading1.copyWith(
                      fontSize: 80,
                      height: 1.1,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    context.l10n.loginSubtitle,
                    style: AppText.heading5.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 44),
                  ...[
                    context.l10n.feature1,
                    context.l10n.feature2,
                    context.l10n.feature3,
                    context.l10n.feature4,
                  ].map(
                    (e) => Row(
                      children: [
                        const Icon(
                          CupertinoIcons.check_mark_circled,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 6, height: 36),
                        Text(
                          e,
                          style: AppText.xLargeN.copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 220),
              Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.enterOtpVerification,
                        style: AppText.heading3.copyWith(color: AppColors.title),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        context.l10n.enterOTPSubtitle,
                        style: AppText.largeN.copyWith(color: AppColors.stormyBlue),
                      ),
                      const SizedBox(height: 34),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
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
                          const SizedBox(height: 30),
                          AppButton(
                            isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
                            label: Text(context.l10n.submit),
                            onPress: verifyOTP,
                          ),
                          const SizedBox(height: 30),
                          Text.rich(
                            TextSpan(
                              text: context.l10n.alreadyHaveAnAccount,
                              style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              children: [
                                TextSpan(
                                  text: context.l10n.login,
                                  style: AppText.mediumM.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.goNamed(AppRouter.login);
                                    },
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
