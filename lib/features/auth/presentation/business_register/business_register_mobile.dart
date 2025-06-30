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

class BusinessRegisterScreenMobile extends ConsumerStatefulWidget {
  const BusinessRegisterScreenMobile({required this.formValues, super.key});
  final Map<String, dynamic> formValues;
  @override
  ConsumerState<BusinessRegisterScreenMobile> createState() => _BusinessRegisterScreenMobileState();
}

class _BusinessRegisterScreenMobileState extends ConsumerState<BusinessRegisterScreenMobile> {
  List<Currency> currencyModels = [];
  final _formKey = GlobalKey<FormBuilderState>();

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
                            context.l10n.createYourBusiness,
                            style: AppText.heading6,
                          ),
                          const SizedBox(height: 20),
                          FormBuilder(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                AppTextForm<String>(
                                  name: 'name',
                                  label: context.l10n.businessName,
                                  validator: FormBuilderValidators.required(),
                                ),
                                const SizedBox(height: 10),
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
                                const SizedBox(height: 10),
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
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: context.l10n.byRegisterIAgree,
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                                children: [
                                  TextSpan(
                                    text: context.l10n.termsAndConditions,
                                    style: AppText.mediumM.copyWith(color: AppColors.brandViolet),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.pushNamed(AppRouter.termsAndConditions);
                                      },
                                  ),
                                  TextSpan(text: context.l10n.and),
                                  TextSpan(
                                    text: context.l10n.privacyPolicy,
                                    style: AppText.mediumM.copyWith(color: AppColors.brandViolet),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.pushNamed(AppRouter.privacyPolicy);
                                      },
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  isLoading: switch (ref.watch(authNotifierProvider).status) {
                                    AuthStatus.loading => true,
                                    _ => false,
                                  },
                                  label: Text(context.l10n.submit),
                                  onPress: _signup,
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
                                        context.goNamed(AppRouter.login);
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
