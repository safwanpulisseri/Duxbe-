import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class NewPasswordScreenMobile extends ConsumerStatefulWidget {
  const NewPasswordScreenMobile({super.key, this.refreshToken, this.orgId, this.type, this.accessToken});
  final String? refreshToken;
  final String? orgId;
  final String? type;
  final String? accessToken;

  @override
  ConsumerState<NewPasswordScreenMobile> createState() => _NewPasswordScreenMobileState();
}

class _NewPasswordScreenMobileState extends ConsumerState<NewPasswordScreenMobile> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _changePassword() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (widget.refreshToken != null) {
        await ref.read(supabaseProvider).auth.setSession(widget.refreshToken!);
      }
      await ref
          .read(authNotifierProvider.notifier)
          .createPassword(_formKey.currentState!.value['password'].toString())
          .then(
        (value) {
          AppRouter.goNamed(AppRouter.login);
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
                context.l10n.createANewPassword,
                style: AppText.heading5,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.createNewPassSubtitle,
                style: AppText.smallN.copyWith(color: AppColors.greyText),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              AppButton(
                isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
                label: Text(context.l10n.submit),
                onPress: _changePassword,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
