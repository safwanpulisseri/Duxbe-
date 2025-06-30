import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class LoginScreenMobile extends ConsumerStatefulWidget {
  const LoginScreenMobile({super.key});

  @override
  ConsumerState<LoginScreenMobile> createState() => _LoginScreenMobileState();
}

class _LoginScreenMobileState extends ConsumerState<LoginScreenMobile> {
  final formKey = GlobalKey<FormBuilderState>();
  Future<void> _login() async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      await ref.read(authNotifierProvider.notifier).signIn(
            formKey.currentState!.value['email'].toString().trim(),
            formKey.currentState!.value['password'].toString(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(24),
                height: MediaQuery.sizeOf(context).height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Assets.images.loginBgMobile.provider(),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Assets.icons.duxbeWhiteLogo.svg(height: 48),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.welcomeBackGladToSeeYouAgain,
                      style: AppText.heading5.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.accessYourPersonalizedDashboardByEnteringYourCredentialsBelow,
                      style: AppText.smallN.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextForm<String>(
                            name: 'email',
                            onSubmitted: (value) {
                              _login();
                            },
                            label: context.l10n.emailAddress,
                            hintText: context.l10n.enterYourEmail,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.email(),
                              FormBuilderValidators.required(),
                            ]),
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [LowerCaseTextFormatter()],
                          ),
                          const SizedBox(height: 16),
                          AppTextForm<String>(
                            name: 'password',
                            onSubmitted: (value) {
                              _login();
                            },
                            label: context.l10n.password,
                            hintText: context.l10n.enterYourPassword,
                            enableObscureText: true,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(6),
                            ]),
                            keyboardType: TextInputType.visiblePassword,
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                context.pushNamed(AppRouter.forgotPassword);
                              },
                              child: TextButton(
                                child: Text(
                                  context.l10n.forgotPassword,
                                  style: AppText.largeSB.copyWith(color: AppColors.brandViolet),
                                ),
                                onPressed: () {
                                  context.pushNamed(AppRouter.forgotPassword);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            isLoading: switch (ref.watch(authNotifierProvider).status) {
                              AuthStatus.loading => true,
                              _ => false,
                            },
                            label: Text(context.l10n.login),
                            onPress: _login,
                          ),
                          const SizedBox(height: 30),
                          Text.rich(
                            TextSpan(
                              text: context.l10n.donTHaveAnAccount,
                              style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              children: [
                                TextSpan(
                                  text: context.l10n.signUp,
                                  style: AppText.mediumM.copyWith(color: AppColors.brandViolet),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.pushNamed(AppRouter.signup);
                                    },
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
