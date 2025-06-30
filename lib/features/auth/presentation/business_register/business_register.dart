import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'business_register_mobile.dart';
export 'business_register_web.dart';

class BusinessRegisterScreen extends ConsumerWidget {
  const BusinessRegisterScreen({required this.formValues, super.key});
  final Map<String, dynamic> formValues;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsiveWidget(
        smallScreen: BusinessRegisterScreenMobile(formValues: formValues),
        largeScreen: BusinessRegisterScreenWeb(formValues: formValues),
      ),
    );
  }
}
