import 'package:collection/collection.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class BusinessRegisterScreenWeb extends ConsumerStatefulWidget {
  const BusinessRegisterScreenWeb({required this.formValues, super.key});
  final Map<String, dynamic> formValues;
  @override
  ConsumerState<BusinessRegisterScreenWeb> createState() => _BusinessRegisterScreenWebState();
}

class _BusinessRegisterScreenWebState extends ConsumerState<BusinessRegisterScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<Currency> currencyModels = [];

  @override
  void initState() {
    super.initState();
    currencyModels = currencies.map(Currency.fromJson).toList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  Future<void> _signup() async {
    final routeData = widget.formValues;
    if (_formKey.currentState!.saveAndValidate()) {
      await ref.read(authNotifierProvider.notifier).signUp(
        {...routeData, ..._formKey.currentState!.value},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ipConfig = ref.watch(ipConfigProvider).value;
    final currency = currencyModels.firstWhereOrNull(
      (element) => element.countryCode.contains(ipConfig?.country),
    );
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
                        context.l10n.setUpYourAccount,
                        style: AppText.heading3.copyWith(color: AppColors.title),
                      ),
                      const SizedBox(height: 14),
                      FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AppTextForm<String>(
                              name: 'name',
                              label: context.l10n.businessName,
                              validator: FormBuilderValidators.required(),
                              onSubmitted: (value) => _signup(),
                            ),
                            const SizedBox(height: 30),
                            AppDropDownForm<BusinessType>(
                              label: context.l10n.businessType,
                              validator: FormBuilderValidators.required(),
                              onChanged: print,
                              items: BusinessType.values
                                  .map(
                                    (e) => DropDownItems(
                                      value: e,
                                      child: Text(e.title),
                                    ),
                                  )
                                  .toList(),
                              name: 'business_type',
                              valueTransformer: (val) => val?.name,
                            ),
                            const SizedBox(height: 30),
                            AppTypeAheadForm<Currency>(
                              name: 'currency',
                              label: context.l10n.currency,
                              initialValue: currency,
                              selectionToTextTransformer: (e) => '${e.code}   ${e.symbol}',
                              itemBuilder: (context, e) => ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.name),
                                    Text('${e.code}   ${e.symbol}'),
                                  ],
                                ),
                              ),
                              suggestionsCallback: (search) => currencyModels
                                  .where(
                                    (e) => e.name.toLowerCase().contains(search.toLowerCase()),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 30),
                            AppButton(
                              isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
                              label: Text(context.l10n.submit),
                              onPress: _signup,
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
}
