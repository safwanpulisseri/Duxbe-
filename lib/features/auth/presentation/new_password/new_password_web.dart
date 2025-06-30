import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/organization/organization.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class NewPasswordScreenWeb extends ConsumerStatefulWidget {
  const NewPasswordScreenWeb({super.key, this.refreshToken, this.orgId, this.type, this.accessToken});
  final String? refreshToken;
  final String? orgId;
  final String? type;
  final String? accessToken;

  @override
  ConsumerState<NewPasswordScreenWeb> createState() => _NewPasswordScreenWebState();
}

class _NewPasswordScreenWebState extends ConsumerState<NewPasswordScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _changePassword() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      await ref
          .read(authNotifierProvider.notifier)
          .createPassword(
            _formKey.currentState!.value['password'].toString(),
            refreshToken: widget.refreshToken,
            orgId: widget.orgId,
            type: widget.type,
            accessToken: widget.accessToken,
          )
          .then(
        (value) {
          AppRouter.goNamed(AppRouter.login);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final org = ref.watch(organizationProvider(widget.orgId));
    final error = GoRouterState.of(context).uri.queryParameters['error'];
    final errorDescription = GoRouterState.of(context).uri.queryParameters['error_description'];
    return FormBuilder(
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
                    child: error == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              org.when(
                                data: (org) => org == null
                                    ? const SizedBox.shrink()
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Welcome to ${org.organizationName!}',
                                            style: AppText.heading3.copyWith(color: AppColors.title),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            'By continuing, you will be a part of ${org.organizationName!}',
                                            style: AppText.largeN.copyWith(color: AppColors.title),
                                          ),
                                          const SizedBox(height: 14),
                                        ],
                                      ),
                                error: (error, stack) => Text(error.toString()),
                                loading: () => const SizedBox.shrink(),
                              ),
                              Text(
                                context.l10n.createANewPassword,
                                style: AppText.heading3.copyWith(color: AppColors.title),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                context.l10n.createNewPassSubtitle,
                                style: AppText.largeN.copyWith(color: AppColors.stormyBlue),
                              ),
                              const SizedBox(height: 34),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  AppTextForm<String>(
                                    name: 'password',
                                    label: context.l10n.password,
                                    enableObscureText: true,
                                    onSubmitted: (value) => _changePassword(),
                                    hintText: context.l10n.enterYourPassword,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.minLength(6),
                                      (value) {
                                        if (_formKey.currentState?.fields['confirm_password']?.value != value) {
                                          return context.l10n.passwordsDoesNotMatch;
                                        }
                                        return null;
                                      }
                                    ]),
                                  ),
                                  const SizedBox(height: 12),
                                  AppTextForm<String>(
                                    name: 'confirm_password',
                                    label: context.l10n.confimationPassword,
                                    enableObscureText: true,
                                    onSubmitted: (value) => _changePassword(),
                                    hintText: context.l10n.enterYourPassword,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.minLength(6),
                                      (value) {
                                        if (_formKey.currentState?.fields['password']?.value != value) {
                                          return context.l10n.passwordsDoesNotMatch;
                                        }
                                        return null;
                                      }
                                    ]),
                                  ),
                                  const SizedBox(height: 30),
                                  AppButton(
                                    isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
                                    label: Text(context.l10n.submit),
                                    onPress: _changePassword,
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
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(error.displayCase, style: AppText.heading3.copyWith(color: AppColors.black)),
                              const SizedBox(height: 14),
                              Text(
                                errorDescription ?? 'Something went wrong',
                                style: AppText.largeN.copyWith(color: AppColors.black),
                              ),
                              const SizedBox(height: 22),
                              AppButton(
                                label: const Text('Back to login'),
                                onPress: () {
                                  context.goNamed(AppRouter.login);
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
    );
  }
}
