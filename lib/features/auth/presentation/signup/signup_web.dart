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

class SignupScreenWeb extends ConsumerStatefulWidget {
  const SignupScreenWeb({super.key});

  @override
  ConsumerState<SignupScreenWeb> createState() => _SignupScreenWebState();
}

class _SignupScreenWebState extends ConsumerState<SignupScreenWeb> {
  final formKey = GlobalKey<FormBuilderState>();

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
                    context.l10n.welcomeToDuxbe,
                    style: AppText.heading1.copyWith(
                      fontSize: 80,
                      height: 1.1,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.signupTitle,
                    style: AppText.heading5.copyWith(
                      color: AppColors.white,
                      height: 1.5,
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
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.createAnAccount,
                        style: AppText.heading3.copyWith(color: AppColors.title),
                      ),
                      const SizedBox(height: 14),
                      FormBuilder(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AppPhoneNumberForm(
                              name: 'phone_number',
                              validator: FormBuilderValidators.required(),
                              mobileValidator: PhoneValidator.compose(
                                [
                                  PhoneValidator.required(context),
                                  PhoneValidator.validMobile(context),
                                ],
                              ),
                              onFieldSubmitted: (value) => _toNextPage(),
                              label: context.l10n.phoneNo,
                              initialValue: ref.read(countryCodeProvider),
                            ),
                            const SizedBox(height: 30),
                            AppTextForm<String>(
                              name: 'email',
                              validator: FormBuilderValidators.compose(
                                [
                                  FormBuilderValidators.email(),
                                  FormBuilderValidators.required(),
                                ],
                              ),
                              onSubmitted: (value) => _toNextPage(),
                              label: context.l10n.email,
                              hintText: context.l10n.yourExampleCom,
                              inputFormatters: [LowerCaseTextFormatter()],
                            ),
                            const SizedBox(height: 30),
                            AppTextForm<String>(
                              name: 'password',
                              validator: FormBuilderValidators.compose(
                                [FormBuilderValidators.minLength(6)],
                              ),
                              label: context.l10n.createPassword,
                              hintText: '*******',
                              enableObscureText: true,
                              onSubmitted: (value) => _toNextPage(),
                              keyboardType: TextInputType.visiblePassword,
                            ),
                            const SizedBox(height: 30),
                            AppButton(
                              label: Text(context.l10n.proceed),
                              onPress: _toNextPage,
                              isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
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

  Future<void> _toNextPage() async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      await ref.read(authNotifierProvider.notifier).goToEnterBusiness(formKey.currentState!.value);
    }
  }
}
