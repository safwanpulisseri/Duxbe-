import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreenWeb extends ConsumerStatefulWidget {
  const LoginScreenWeb({super.key});

  @override
  ConsumerState<LoginScreenWeb> createState() => _LoginScreenWebState();
}

class _LoginScreenWebState extends ConsumerState<LoginScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> login() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      await ref.read(authNotifierProvider.notifier).signIn(
            _formKey.currentState!.value['email'].toString().trim(),
            _formKey.currentState!.value['password'].toString(),
          );
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      initialValue: kDebugMode
          ? {
              'email': 'alfas@hancod.com',
              'password': '123123',
            }
          : {},
      key: _formKey,
      child: Container(
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                              context.l10n.welcomeBack,
                              style: AppText.heading3.copyWith(color: AppColors.title),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              context.l10n.loginDescription,
                              style: AppText.largeN.copyWith(color: AppColors.stormyBlue),
                            ),
                            const SizedBox(height: 34),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                AppTextForm<String>(
                                  onSubmitted: (value) => login(),
                                  name: 'email',
                                  label: context.l10n.email,
                                  hintText: context.l10n.enterEmailId,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.email(),
                                    FormBuilderValidators.required(),
                                  ]),
                                  keyboardType: TextInputType.emailAddress,
                                  inputFormatters: [LowerCaseTextFormatter()],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      child: Text(
                                        context.l10n.forgotPassword,
                                        style: AppText.largeSB.copyWith(
                                          color: AppColors.brandViolet,
                                        ),
                                      ),
                                      onPressed: () {
                                        context.pushNamed(
                                          AppRouter.forgotPassword,
                                          queryParameters: {
                                            'email': _formKey.currentState?.instantValue['email'],
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                AppTextForm<String>(
                                  name: 'password',
                                  label: context.l10n.password,
                                  hintText: context.l10n.enterPassword,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.minLength(6),
                                  ]),
                                  onSubmitted: (value) => login(),
                                  enableObscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                ),
                                const SizedBox(height: 30),
                                AppButton(
                                  isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
                                  label: Text(context.l10n.submit),
                                  onPress: login,
                                ),
                                const SizedBox(height: 30),
                                Text.rich(
                                  TextSpan(
                                    text: context.l10n.donTHaveAnAccount,
                                    style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                                    children: [
                                      TextSpan(
                                        text: context.l10n.signUp,
                                        style: AppText.mediumM.copyWith(
                                          color: AppColors.primaryColor,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            context.goNamed(AppRouter.signup);
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
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            _launchUrl(
                              'https://apps.apple.com/in/app/duxbe-business/id6502827781',
                            );
                          },
                          child: Assets.images.appstore.image(height: 40),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            _launchUrl(
                              'https://play.google.com/store/apps/details?id=com.hancod.duxbe.business',
                            );
                          },
                          child: Assets.images.playStore.image(height: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
