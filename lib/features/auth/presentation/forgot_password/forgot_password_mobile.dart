import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ForgotPasswordScreenMobile extends ConsumerStatefulWidget {
  const ForgotPasswordScreenMobile({super.key});

  @override
  ConsumerState<ForgotPasswordScreenMobile> createState() => _ForgotPasswordScreenMobileState();
}

class _ForgotPasswordScreenMobileState extends ConsumerState<ForgotPasswordScreenMobile> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _forgotPassword() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      await ref
          .read(authNotifierProvider.notifier)
          .forgotPassword(
            _formKey.currentState!.value['email'].toString(),
          )
          .then(
        (value) {
          AppRouter.pushNamed(
            AppRouter.enterOTP,
            queryParameters: {'email': _formKey.currentState!.value['email']},
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
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
                context.l10n.forgotYourPassword,
                style: AppText.heading5,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.weWillSendPasswordResetLinkToYourRegisteredEmailId,
                style: AppText.smallN.copyWith(color: AppColors.greyText),
              ),
              const SizedBox(height: 16),
              AppTextForm<String>(
                onSubmitted: (value) => _forgotPassword(),
                name: 'email',
                label: context.l10n.email,
                hintText: context.l10n.enterEmailId,
                initialValue: GoRouterState.of(context).uri.queryParameters['email'],
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.email(),
                  FormBuilderValidators.required(),
                ]),
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [LowerCaseTextFormatter()],
              ),
              const SizedBox(height: 16),
              AppButton(
                isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
                label: Text(context.l10n.submit),
                onPress: _forgotPassword,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
