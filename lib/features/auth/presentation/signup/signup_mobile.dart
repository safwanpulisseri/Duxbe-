import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:phone_form_field/phone_form_field.dart';

class SignupScreenMobile extends ConsumerStatefulWidget {
  const SignupScreenMobile({super.key});

  @override
  ConsumerState<SignupScreenMobile> createState() => _SignupScreenMobileState();
}

class _SignupScreenMobileState extends ConsumerState<SignupScreenMobile> {
  final formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      body: Column(
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
                      context.l10n.welcomeToDuxbe,
                      style: AppText.heading5.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.signupTitle,
                      style: AppText.smallN.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 34),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.setUpYourAccount,
                            style: AppText.heading6,
                          ),
                          const SizedBox(height: 20),
                          FormBuilder(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                AppPhoneNumberForm(
                                  name: 'phone_number',
                                  validator: FormBuilderValidators.required(),
                                  initialValue: ref.read(countryCodeProvider),
                                  mobileValidator: PhoneValidator.compose(
                                    [
                                      PhoneValidator.required(context),
                                      PhoneValidator.validMobile(context),
                                    ],
                                  ),
                                  label: context.l10n.phoneNumber,
                                ),
                                const SizedBox(height: 10),
                                AppTextForm<String>(
                                  name: 'email',
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.email(),
                                    FormBuilderValidators.required(),
                                  ]),
                                  label: context.l10n.email,
                                  hintText: 'your@example.com',
                                  inputFormatters: [LowerCaseTextFormatter()],
                                ),
                                const SizedBox(height: 10),
                                AppTextForm<String>(
                                  name: 'password',
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.minLength(6),
                                  ]),
                                  label: context.l10n.createPassword,
                                  hintText: '*******',
                                  enableObscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  isLoading: authState.status == AuthStatus.loading,
                                  onPress: () async {
                                    if (formKey.currentState?.saveAndValidate() ?? false) {
                                      await ref
                                          .read(authNotifierProvider.notifier)
                                          .goToEnterBusiness(formKey.currentState!.value);
                                    }
                                  },
                                  label: Text(context.l10n.proceed),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: context.l10n.alreadyHaveAnAccount,
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                                children: [
                                  TextSpan(
                                    text: context.l10n.login,
                                    style: AppText.mediumM.copyWith(color: AppColors.brandViolet),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.pushNamed(AppRouter.login);
                                      },
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
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
        ],
      ),
    );
  }
}
